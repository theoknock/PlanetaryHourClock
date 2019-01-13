//
//  PlanetaryHourDataSource.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/18/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "PlanetaryHourDataSource.h"
#import "FESSolarCalculator.h"

@implementation PlanetaryHourDataSource

static PlanetaryHourDataSource *sharedDataSource = NULL;
+ (nonnull PlanetaryHourDataSource *)sharedDataSource
{
    static dispatch_once_t onceSecurePredicate;
    dispatch_once(&onceSecurePredicate,^
                  {
                      if (!sharedDataSource)
                      {
                          sharedDataSource = [[self alloc] init];
                      }
                  });
    
    return sharedDataSource;
}

- (instancetype)init
{
    if (self == [super init])
    {
        self.planetaryHourDataRequestQueue = dispatch_queue_create_with_target("Planetary Hour Data Request Queue", DISPATCH_QUEUE_CONCURRENT, dispatch_get_main_queue());
    }
    
    return self;
}

#pragma mark - Location Services

- (CLLocationManager *)locationManager
{
    CLLocationManager *lm = self->_locationManager;
    if (!lm)
    {
        lm = [[CLLocationManager alloc] init];
        lm.desiredAccuracy = kCLLocationAccuracyKilometer;
        lm.distanceFilter = 100;
        if ([lm respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [lm requestWhenInUseAuthorization];
        }
        lm.delegate = self;
        
        self->_locationManager = lm;
        
        NSLog(@"%s", __PRETTY_FUNCTION__);
    }
    
    return lm;
}

#pragma mark <CLLocationManagerDelegate methods>

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%s\n%@", __PRETTY_FUNCTION__, error.localizedDescription);
    [manager requestLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted)
    {
        NSLog(@"Failure to authorize location services\t%d", status);
//        [manager stopUpdatingLocation];
    }
    else
    {
        if (status == kCLAuthorizationStatusAuthorizedWhenInUse ||
            status == kCLAuthorizationStatusAuthorizedAlways)
        {
            NSLog(@"Location services authorized\t%d", status);
//            [manager startUpdatingLocation];
        } else {
            NSLog(@"Location services authorization status code:\t%d", status);
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlanetaryHoursDataSourceUpdatedNotification"
                                                        object:nil
                                                      userInfo:nil];
}

#pragma mark - Solar transits

double const FESSolarCalculationZenithOfficial = 90.83;
double const toRadians = M_PI / 180;
double const toDegrees = 180 / M_PI;

NSDate *(^dateFromJulianDayNumber)(double) = ^(double julianDayValue)
{
    // calculation of Gregorian date from Julian Day Number ( http://en.wikipedia.org/wiki/Julian_day )
    int JulianDayNumber = (int)floor(julianDayValue);
    int J = floor(JulianDayNumber + 0.5);
    int j = J + 32044;
    int g = j / 146097;
    int dg = j - (j/146097) * 146097; // mod
    int c = (dg / 36524 + 1) * 3 / 4;
    int dc = dg - c * 36524;
    int b = dc / 1461;
    int db = dc - (dc/1461) * 1461; // mod
    int a = (db / 365 + 1) * 3 / 4;
    int da = db - a * 365;
    int y = g * 400 + c * 100 + b * 4 + a;
    int m = (da * 5 + 308) / 153 - 2;
    int d = da - (m + 4) * 153 / 5 + 122;
    NSDateComponents *components = [NSDateComponents new];
    components.timeZone = [NSTimeZone timeZoneWithName:@"GMT"];
    components.year = y - 4800 + (m + 2) / 12;
    components.month = ((m+2) - ((m+2)/12) * 12) + 1;
    components.day = d + 1;
    double timeValue = ((julianDayValue - floor(julianDayValue)) + 0.5) * 24;
    components.hour = (int)floor(timeValue);
    double minutes = (timeValue - floor(timeValue)) * 60;
    components.minute = (int)floor(minutes);
    components.second = (int)((minutes - floor(minutes)) * 60);
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *returnDate = [calendar dateFromComponents:components];
    
    return returnDate;
};

int (^julianDayNumberFromDate)(NSDate *) = ^(NSDate *inDate)
{
    // calculation of Julian Day Number (http://en.wikipedia.org/wiki/Julian_day ) from Gregorian Date
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:inDate];
    int a = (14 - (int)[components month]) / 12;
    int y = (int)[components year] +  4800 - a;
    int m = (int)[components month] + (12 * a) - 3;
    int JulianDayNumber = (int)[components day] + (((153 * m) + 2) / 5) + (365 * y) + (y/4) - (y/100) + (y/400) - 32045;
    
    return JulianDayNumber;
};

NSArray<NSDate *> *(^calculateSolarData)(NSDate *, CLLocationCoordinate2D) = ^(NSDate *startDate, CLLocationCoordinate2D coordinate)
{
    // math in this method comes directly from http://users.electromagnetic.net/bu/astro/sunrise-set.php
    // with a change to calculate twilight times as well (that information comes from
    // http://williams.best.vwh.net/sunrise_sunset_algorithm.htm ). The math in the first url
    // is sourced from http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html which no longer exists
    // but a copy was found on the Wayback Machine at
    // http://web.archive.org/web/20110723172451/http://www.astro.uu.nl/~strous/AA/en/reken/zonpositie.html
    // All constants can be referenced and are explained on the archive.org page
    
    // run the calculations based on the users criteria at initalization time
    //    int JulianDayNumber = [FESSolarCalculator julianDayNumberFromDate:self.startDate];
    int JulianDayNumber = julianDayNumberFromDate(startDate);
    double JanuaryFirst2000JDN = 2451545.0;
    
    // this formula requires west longitude, thus 75W = 75, 45E = -45
    // convert to get it there
    double westLongitude = coordinate.longitude * -1.0;
    
    // define some of our mathmatical values;
    double Nearest = 0.0;
    double ElipticalLongitudeOfSun = 0.0;
    double ElipticalLongitudeRadians = ElipticalLongitudeOfSun * toRadians;
    double MeanAnomoly = 0.0;
    double MeanAnomolyRadians = MeanAnomoly * toRadians;
    double MAprev = -1.0;
    double Jtransit = 0.0;
    
    // we loop through our calculations for Jtransit
    // Running the loop the first time we then re-run it with Jtransit
    // as the input to refine MeanAnomoly. Once MeanAnomoly is equal
    // to the previous run's MeanAnomoly calculation we can continue
    while (MeanAnomoly != MAprev) {
        MAprev = MeanAnomoly;
        Nearest = round(((double)JulianDayNumber - JanuaryFirst2000JDN - 0.0009) - (westLongitude/360.0));
        double Japprox = JanuaryFirst2000JDN + 0.0009 + (westLongitude/360.0) + Nearest;
        if (Jtransit != 0.0) {
            Japprox = Jtransit;
        }
        double Ms = (357.5291 + 0.98560028 * (Japprox - JanuaryFirst2000JDN));
        MeanAnomoly = fmod(Ms, 360.0);
        MeanAnomolyRadians = MeanAnomoly * toRadians;
        double EquationOfCenter = (1.9148 * sin(MeanAnomolyRadians)) + (0.0200 * sin(2.0 * (MeanAnomolyRadians))) + (0.0003 * sin(3.0 * (MeanAnomolyRadians)));
        double eLs = (MeanAnomoly + 102.9372 + EquationOfCenter + 180.0);
        ElipticalLongitudeOfSun = fmod(eLs, 360.0);
        ElipticalLongitudeRadians = ElipticalLongitudeOfSun * toRadians;
        if (Jtransit == 0.0) {
            Jtransit = Japprox + (0.0053 * sin(MeanAnomolyRadians)) - (0.0069 * sin(2.0 * ElipticalLongitudeRadians));
        }
    }
    
    double DeclinationOfSun = asin( sin(ElipticalLongitudeRadians) * sin(23.45 * toRadians) ) * toDegrees;
    double DeclinationOfSunRadians = DeclinationOfSun * toRadians;
    
    // We now have solar noon for our day
    //    NSDate *solarNoon = dateFromJulianDayNumber(Jtransit);
    
    // create a block to run our per-zenith calculations based on solar noon
    double H1 = (cos(FESSolarCalculationZenithOfficial * toRadians) - sin(coordinate.latitude * toRadians) * sin(DeclinationOfSunRadians));
    double H2 = (cos(coordinate.latitude * toRadians) * cos(DeclinationOfSunRadians));
    double HourAngle = acos( (H1  * toRadians) / (H2  * toRadians) ) * toDegrees;
    
    double Jss = JanuaryFirst2000JDN + 0.0009 + ((HourAngle + westLongitude)/360.0) + Nearest;
    
    // compute the setting time from Jss approximation
    double Jset = Jss + (0.0053 * sin(MeanAnomolyRadians)) - (0.0069 * sin(2.0 * ElipticalLongitudeRadians));
    // calculate the rise time based on solar noon and the set time
    double Jrise = Jtransit - (Jset - Jtransit);
    
    // assign the rise and set dates to the correct properties
    NSDate *riseDate = dateFromJulianDayNumber(Jrise);
    NSDate *setDate = dateFromJulianDayNumber(Jset);
    
    return @[riseDate, setDate];
};

#pragma mark - Planetary Hour Calculation definitions and enumerations

#define SECONDS_PER_DAY 86400.00f
#define HOURS_PER_SOLAR_TRANSIT 12
#define HOURS_PER_DAY 24
#define NUMBER_OF_PLANETS 7

typedef NS_ENUM(NSUInteger, Day) {
    SUN,
    MON,
    TUE,
    WED,
    THU,
    FRI,
    SAT
};

typedef NS_ENUM(NSUInteger, Meridian) {
    AM,
    PM
};

NSString *(^planetSymbolForPlanet)(Planet) = ^(Planet planet) {
    planet = planet % NUMBER_OF_PLANETS;
    switch (planet) {
        case Sun:
            return @"☉";
            break;
        case Moon:
            return @"☽";
            break;
        case Mars:
            return @"♂︎";
            break;
        case Mercury:
            return @"☿";
            break;
        case Jupiter:
            return @"♃";
            break;
        case Venus:
            return @"♀︎";
            break;
        case Saturn:
            return @"♄";
            break;
        case Earth:
            return @"㊏";
            break;
        default:
            break;
    }
};

Planet(^planetForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date) {
    if (!date) date = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    Planet planet = [calendar component:NSCalendarUnitWeekday fromDate:date] - 1;
    
    return planet;
};

Planet(^planetForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    hour = hour % HOURS_PER_DAY;
    Planet planet = (planetForDay(date) + hour) % NUMBER_OF_PLANETS;
    
    return planet;
};

NSString *(^planetNameForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date)
{
    Day day = (Day)planetForDay(date);
    switch (day) {
        case SUN:
            return @"Sun";
            break;
        case MON:
            return @"Moon";
            break;
        case TUE:
            return @"Mars";
            break;
        case WED:
            return @"Mercury";
            break;
        case THU:
            return @"Jupiter";
            break;
        case FRI:
            return @"Venus";
            break;
        case SAT:
            return @"Saturn";
            break;
        default:
            break;
    }
};

NSString *(^planetSymbolForDay)(NSDate * _Nullable) = ^(NSDate * _Nullable date) {
    return planetSymbolForPlanet(planetForDay(date));
};

NSString *(^planetNameForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour)
{
    switch (planetForHour(date, hour)) {
        case Sun:
            return @"Sun";
            break;
        case Moon:
            return @"Moon";
            break;
        case Mars:
            return @"Mars";
            break;
        case Mercury:
            return @"Mercury";
            break;
        case Jupiter:
            return @"Jupiter";
            break;
        case Venus:
            return @"Venus";
            break;
        case Saturn:
            return @"Saturn";
            break;
        case Earth:
            return @"Earth";
            break;
        default:
            break;
    }
};

NSString *(^planetSymbolForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    return planetSymbolForPlanet(planetForHour(date, hour));
};

- (UIImage *)imageFromString:(NSString *)text
{
    NSMutableParagraphStyle *centerAlignedParagraphStyle  = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment                 = NSTextAlignmentCenter;
    NSDictionary *centerAlignedTextAttributes             = @{NSForegroundColorAttributeName : [UIColor grayColor],
                                                              NSFontAttributeName            : [UIFont systemFontOfSize:48.0 weight:UIFontWeightBold],
                                                              NSParagraphStyleAttributeName  : centerAlignedParagraphStyle};
    CGSize size = [text sizeWithAttributes:centerAlignedTextAttributes];
          UIGraphicsBeginImageContext(size);
    [text drawAtPoint:CGPointZero withAttributes:centerAlignedTextAttributes];
                                        
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

typedef NS_ENUM(NSUInteger, PlanetColor) {
    Yellow,
    White,
    Red,
    Brown,
    Orange,
    Green,
    Grey
};

//UIColor *(^colorForPlanetSymbol)(NSString *) = ^(NSString *planetarySymbol) {
//    if ([planetarySymbol isEqualToString:@"☉"])
//        return [UIColor yellowColor];
//    else if ([planetarySymbol isEqualToString:@"☽"])
//        return [UIColor whiteColor];
//    else if ([planetarySymbol isEqualToString:@"♂︎"])
//        return [UIColor redColor];
//    else if ([planetarySymbol isEqualToString:@"☿"])
//        return [UIColor brownColor];
//    else if ([planetarySymbol isEqualToString:@"♃"])
//        return [UIColor orangeColor];
//    else if ([planetarySymbol isEqualToString:@"♀︎"])
//        return [UIColor greenColor];
//    else if ([planetarySymbol isEqualToString:@"♄"])
//        return [UIColor grayColor];
//    else
//        return [UIColor whiteColor];
//};

NSAttributedString *(^attributedPlanetSymbol)(NSString *) = ^(NSString *symbol) {
    NSMutableParagraphStyle *centerAlignedParagraphStyle  = [[NSMutableParagraphStyle alloc] init];
    centerAlignedParagraphStyle.alignment                 = NSTextAlignmentCenter;
    NSDictionary *centerAlignedTextAttributes             = @{NSForegroundColorAttributeName : colorForPlanetSymbol(symbol),
                                                              NSFontAttributeName            : [UIFont systemFontOfSize:48.0 weight:UIFontWeightBold],
                                                              NSParagraphStyleAttributeName  : centerAlignedParagraphStyle};
    
    NSAttributedString *attributedSymbol = [[NSAttributedString alloc] initWithString:symbol attributes:centerAlignedTextAttributes];
    
    return attributedSymbol;
};

#pragma Planetary Hour Calculation methods

- (FESSolarCalculator *)solarCalculationForDate:(NSDate *)date location:(CLLocation *)location
{
    location = (!location) ? self.locationManager.location : location;
    date     = (!date)     ? [NSDate date]                 : date;
    FESSolarCalculator *solarCalculator = [[FESSolarCalculator alloc] initWithDate:date location:location];
    
    NSDate *earlierDate = [solarCalculator.sunrise earlierDate:date];
    if ([earlierDate isEqualToDate:date])
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [[NSDateComponents alloc] init];
        components.day = -1;
        NSDate *yesterday = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
        solarCalculator = [[FESSolarCalculator alloc] initWithDate:yesterday location:location];
    }
    
    return solarCalculator;
}

NSArray<NSNumber *> *(^hourDurations)(NSTimeInterval) = ^(NSTimeInterval daySpan)
{
    NSTimeInterval dayHourDuration = daySpan / HOURS_PER_SOLAR_TRANSIT;
    NSTimeInterval nightSpan = fabs(SECONDS_PER_DAY - daySpan);
    NSTimeInterval nightHourDuration = nightSpan / HOURS_PER_SOLAR_TRANSIT;
    NSArray<NSNumber *> *hourDurations = @[[NSNumber numberWithDouble:dayHourDuration], [NSNumber numberWithDouble:nightHourDuration]];
    
    return hourDurations;
};

- (void)planetaryHours:(PlanetaryHourCompletionBlock)planetaryHour
{
    FESSolarCalculator *solarCalculation = [self solarCalculationForDate:nil location:nil];
    NSTimeInterval daySpan         = [solarCalculation.sunset timeIntervalSinceDate:solarCalculation.sunrise];
    NSArray<NSNumber *> *durations = hourDurations(daySpan);
    
    __block NSInteger hour         = 0;
    __block dispatch_block_t planetaryHoursDictionaries;
    
    void(^planetaryHoursDictionary)(void) = ^(void) {
        Meridian meridian                 = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
        SolarTransit transit              = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
        NSInteger mod_hour                = hour % 12;
        NSTimeInterval startTimeInterval  = durations[meridian].doubleValue * mod_hour;
        NSDate *sinceDate                 = (transit == Sunrise) ? solarCalculation.sunrise : solarCalculation.sunset;
        NSDate *startTime                 = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:sinceDate];
        NSTimeInterval endTimeInterval    = durations[meridian].doubleValue * (mod_hour + 1);
        NSDate *endTime                   = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:sinceDate];
        NSDateInterval *dateInterval      = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
        
        NSAttributedString *symbol        = attributedPlanetSymbol(planetSymbolForHour(solarCalculation.sunrise, hour));
        NSString *name                    = planetNameForHour(solarCalculation.sunrise, hour);
        planetaryHour(symbol, name, startTime, endTime, hour, ([dateInterval containsDate:[NSDate date]]) ? YES : NO);
        
        hour++;
        if (hour < HOURS_PER_DAY)
            planetaryHoursDictionaries();
    };
    
    planetaryHoursDictionaries = ^{
        
            planetaryHoursDictionary();
    };
    planetaryHoursDictionaries();
}

- (Planet)currentPlanetaryHour
{
    __block Planet planet = 8;
    CLLocation *location = _locationManager.location;
    if (CLLocationCoordinate2DIsValid(location.coordinate))
    {
        dispatch_async(self.planetaryHourDataRequestQueue, ^{
            NSDate *date = [NSDate date];
            NSArray<NSDate *> *solarCalculator = calculateSolarData(date, location.coordinate);
            NSDate *earlierDate = [solarCalculator[Sunrise] earlierDate:date];
            if ([earlierDate isEqualToDate:date])
            {
                NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                NSDateComponents *components = [[NSDateComponents alloc] init];
                components.day = -1;
                date = [calendar dateByAddingComponents:components toDate:date options:NSCalendarMatchNextTimePreservingSmallerUnits];
                solarCalculator = calculateSolarData(date, location.coordinate);
            }
            NSTimeInterval daySpan = [solarCalculator[Sunset] timeIntervalSinceDate:solarCalculator[Sunrise]];
            NSArray<NSNumber *> *durations = hourDurations(daySpan);
    
            __block NSInteger hour         = 0;
            __block dispatch_block_t planetaryHoursDictionaries;
            
            void(^planetaryHoursDictionary)(void) = ^(void) {
                Meridian meridian                 = (hour < HOURS_PER_SOLAR_TRANSIT) ? AM : PM;
                SolarTransit transit              = (hour < HOURS_PER_SOLAR_TRANSIT) ? Sunrise : Sunset;
                NSInteger mod_hour                = hour % 12;
                NSTimeInterval startTimeInterval  = durations[meridian].doubleValue * mod_hour;
                NSDate *sinceDate                 = (transit == Sunrise) ? solarCalculator[Sunrise] : solarCalculator[Sunset];
                NSDate *startTime                 = [[NSDate alloc] initWithTimeInterval:startTimeInterval sinceDate:sinceDate];
                NSTimeInterval endTimeInterval    = durations[meridian].doubleValue * (mod_hour + 1);
                NSDate *endTime                   = [[NSDate alloc] initWithTimeInterval:endTimeInterval sinceDate:sinceDate];
                NSDateInterval *dateInterval      = [[NSDateInterval alloc] initWithStartDate:startTime endDate:endTime];
                
                if ([dateInterval containsDate:date])
                {
                    planet = hour % 7;
                } else {
                    hour++;
                    if (hour < HOURS_PER_DAY)
                        planetaryHoursDictionaries();
                }
            };
            
            planetaryHoursDictionaries = ^{
                planetaryHoursDictionary();
            };
            
            planetaryHoursDictionaries();
        });
    } else {
        [_locationManager requestLocation];
    }
    
    return planet;
}


@end
