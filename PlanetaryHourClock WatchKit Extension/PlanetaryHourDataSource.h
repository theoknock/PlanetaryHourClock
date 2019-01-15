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


NS_ASSUME_NONNULL_BEGIN

typedef void(^PlanetaryHourCompletionBlock)(NSAttributedString *symbol, NSString *name, NSDate *startDate, NSDate *endDate, NSInteger hour, BOOL current);
typedef void(^SolarTransitData)(NSDictionary<NSString *, NSDate *> *);
@interface PlanetaryHourDataSource : NSObject <CLLocationManagerDelegate>

+ (nonnull PlanetaryHourDataSource *)sharedDataSource;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) dispatch_queue_t planetaryHourDataRequestQueue;
- (NSDictionary *)currentPlanetaryHour;

- (void)planetaryHours:(PlanetaryHourCompletionBlock)planetaryHour;

@end

NS_ASSUME_NONNULL_END
