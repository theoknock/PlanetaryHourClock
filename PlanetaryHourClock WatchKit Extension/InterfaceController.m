//
//  InterfaceController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "InterfaceController.h"
#import "PlanetaryHourDataSource.h"


@interface InterfaceController ()
{
    dispatch_source_t interfaceUpdateTimer;
}

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];    

    // Configure interface objects here.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface) name:@"PlanetaryHoursDataSourceUpdatedNotification" object:nil];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

//- (void)updateInterface
//{
////    if (interfaceUpdateTimer)
////        dispatch_suspend(interfaceUpdateTimer);
////    __weak typeof(dispatch_source_t) w_interfaceUpdateTimer = interfaceUpdateTimer;
//    [[PlanetaryHourDataSource sharedDataSource] currentPlanetaryHourUsingBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.planetaryHourSymbolLabel setAttributedText:symbol];
//            [self.planetaryHourNameLabel setText:name];
//            [self.planetaryHourDurationCountupTimerLabel setDate:startDate];
//            [self.planetaryHourDurationCountdownTimerLabel setDate:endDate];
//        });
//        //        NSTimeInterval timer_countdown = [endDate timeIntervalSinceDate:startDate];
////        __strong dispatch_source_t s_interfaceUpdateTimer = w_interfaceUpdateTimer;
////        s_interfaceUpdateTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, PlanetaryHourDataSource.sharedDataSource.planetaryHourDataRequestQueue);
////        dispatch_source_set_timer(s_interfaceUpdateTimer, DISPATCH_TIME_NOW, timer_countdown * NSEC_PER_SEC, 1.0 * NSEC_PER_SEC);
////        dispatch_source_set_event_handler(s_interfaceUpdateTimer, ^{
////            [self updateInterface];
////        });
////        dispatch_resume(s_interfaceUpdateTimer);
//    }];
//}

@end



