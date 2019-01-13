//
//  PlanetaryHourDataSource.h
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/18/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

#import "FESSolarCalculator.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, Planet) {
    Sun,
    Moon,
    Mars,
    Mercury,
    Jupiter,
    Venus,
    Saturn,
    Earth
};

NSString *(^nameForPlanet)(Planet) = ^(Planet planet)
{
    switch (planet) {
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
        default:
            break;
    }
};

NSString *(^symbolForPlanet)(Planet) = ^(Planet planet) {
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
        default:
            break;
    }
};

UIColor *(^colorForPlanet)(Planet) = ^(Planet planet) {
    switch (planet) {
        case Sun:
            return [UIColor yellowColor];
            break;
        case Moon:
            return [UIColor whiteColor];
            break;
        case Mars:
            return [UIColor redColor];
            break;
        case Mercury:
            return [UIColor brownColor];
            break;
        case Jupiter:
            return [UIColor orangeColor];
            break;
        case Venus:
            return [UIColor greenColor];
            break;
        case Saturn:
            return [UIColor grayColor];
            break;
        case Earth:
            return [UIColor blueColor];
        default:
            break;
    }
};

typedef NS_ENUM(NSUInteger, SolarTransit) {
    Sunrise,
    Sunset
};

typedef void(^PlanetaryHourCompletionBlock)(NSAttributedString *symbol, NSString *name, NSDate *startDate, NSDate *endDate, NSInteger hour, BOOL current);

@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>

+ (nonnull PlanetaryHourDataSource *)sharedDataSource;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) dispatch_queue_t planetaryHourDataRequestQueue;
- (Planet)currentPlanetaryHour;

- (void)planetaryHours:(PlanetaryHourCompletionBlock)planetaryHour;
- (FESSolarCalculator *)solarCalculationForDate:(NSDate *)date location:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
