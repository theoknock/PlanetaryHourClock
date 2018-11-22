//
//  NotificationController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "NotificationController.h"
#import "PlanetaryHourDataSource.h"


@interface NotificationController ()

@end


@implementation NotificationController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Initialize variables here.
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // Enable or disable features based on authorization.
                                  if (granted)
                                  {
                                      [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
                                          UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                                          content.title                         = [symbol string];
                                          content.subtitle                      = name;
                                          content.body                          = [NSString stringWithFormat:@"%@\n%@", startDate.description, endDate.description];
                                          
                                          NSDateComponents *dateComponents       = [[NSDateComponents alloc] init];
                                          dateComponents.calendar                = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
                                          dateComponents.hour                    = [dateComponents.calendar component:NSCalendarUnitHour   fromDate:startDate];
                                          dateComponents.minute                  = [dateComponents.calendar component:NSCalendarUnitMinute fromDate:startDate];
                                          dateComponents.second                  = [dateComponents.calendar component:NSCalendarUnitSecond fromDate:startDate];
                                          dateComponents.month                   = [dateComponents.calendar component:NSCalendarUnitMonth  fromDate:startDate];
                                          dateComponents.day                     = [dateComponents.calendar component:NSCalendarUnitDay    fromDate:startDate];
                                          dateComponents.year                    = [dateComponents.calendar component:NSCalendarUnitYear   fromDate:startDate];
                                          UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:dateComponents repeats:FALSE];
                                          
                                          NSString *uuidString = [[NSDate date] description];
                                          
                                          UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:uuidString content:content trigger:trigger];
                                          
                                          [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                                              if (!error) {
                                                  NSLog(@"Added notification request %ld to notification center", (long)hour);
                                              } else {
                                                  NSLog(@"Error adding notification request to notification center:\t%@", error.description);
                                              }
                                          }];
                                      }];
                                  }
                              }];
        
        // Configure interface objects here.
        
    }
    return self;
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    // This method is called when a notification needs to be presented.
    // Implement it if you use a dynamic notification interface.
    // Populate your dynamic notification interface as quickly as possible.
}

@end



