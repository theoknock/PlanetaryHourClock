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

#pragma mark - Planetary Hour Calculation definitions and enumerations

#define SECONDS_PER_DAY 86400.00f
#define HOURS_PER_SOLAR_TRANSIT 12
#define HOURS_PER_DAY 24
#define NUMBER_OF_PLANETS 7

typedef NS_ENUM(NSUInteger, Planet) {
    Sun,
    Moon,
    Mars,
    Mercury,
    Jupiter,
    Venus,
    Saturn
};

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

typedef NS_ENUM(NSUInteger, SolarTransit) {
    Sunrise,
    Sunset
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
            return @"Venus";
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
            return @"Venus";
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
        default:
            break;
    }
};

NSString *(^planetSymbolForHour)(NSDate * _Nullable, NSUInteger) = ^(NSDate * _Nullable date, NSUInteger hour) {
    return planetSymbolForPlanet(planetForHour(date, hour));
};

typedef NS_ENUM(NSUInteger, PlanetColor) {
    Yellow,
    White,
    Red,
    Brown,
    Orange,
    Green,
    Grey
};

UIColor *(^colorForPlanetSymbol)(NSString *) = ^(NSString *planetarySymbol) {
    if ([planetarySymbol isEqualToString:@"☉"])
        return [UIColor yellowColor];
    else if ([planetarySymbol isEqualToString:@"☽"])
        return [UIColor whiteColor];
    else if ([planetarySymbol isEqualToString:@"♂︎"])
        return [UIColor redColor];
    else if ([planetarySymbol isEqualToString:@"☿"])
        return [UIColor brownColor];
    else if ([planetarySymbol isEqualToString:@"♃"])
        return [UIColor orangeColor];
    else if ([planetarySymbol isEqualToString:@"♀︎"])
        return [UIColor greenColor];
    else if ([planetarySymbol isEqualToString:@"♄"])
        return [UIColor grayColor];
    else
        return [UIColor whiteColor];
};

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


@end
