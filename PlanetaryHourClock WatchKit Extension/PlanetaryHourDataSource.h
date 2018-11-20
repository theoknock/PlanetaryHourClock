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

typedef void(^CurrentPlanetaryHourCompletionBlock)(NSAttributedString *symbol, NSString *name, NSDate *date);
typedef void(^CurrentPlanetaryHourBlock)(FESSolarCalculator *solarCalculation, CurrentPlanetaryHourCompletionBlock planetaryHour);


@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>

+ (nonnull PlanetaryHourDataSource *)sharedDataSource;

@property (strong, nonatomic) CLLocationManager *locationManager;

- (FESSolarCalculator *)solarCalculationForDate:(NSDate  * _Nullable)date location:(CLLocation * _Nullable)location;
- (void)currentPlanetaryHourUsingBlock:(CurrentPlanetaryHourCompletionBlock)currentPlanetaryHour;

//@property (strong, nonatomic) void(^currentPlanetaryHour)(FESSolarCalculator *solarCalculation, CurrentPlanetaryHourCompletionBlock planetaryHour);

@end

NS_ASSUME_NONNULL_END
