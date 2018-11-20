//
//  ComplicationController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ComplicationController.h"
#import "PlanetaryHourDataSource.h"

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
//    handler([PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil].sunrise);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
//    handler([PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil].sunset);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    // Call the handler with the current timeline entry
//    [[PlanetaryHourDataSource sharedDataSource] currentPlanetaryHour]([PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil], ^(NSString *symbol, NSString *name, NSDate *entryDate) {
//        CLKSimpleTextProvider *planetaryHourTextProvider;
//        [planetaryHourTextProvider setText:name];
//        [planetaryHourTextProvider setShortText:symbol];
//        [self getLocalizableSampleTemplateForComplication:complication withHandler:^(CLKComplicationTemplate * _Nullable complicationTemplate) {
//            [(CLKComplicationTemplateModularLargeStandardBody *)complicationTemplate setHeaderTextProvider:planetaryHourTextProvider];
//            [(CLKComplicationTemplateModularLargeStandardBody *)complicationTemplate setBody1TextProvider:planetaryHourTextProvider];
//            CLKComplicationTimelineEntry *currentPlanetaryHourTimelineEntry = [CLKComplicationTimelineEntry entryWithDate:entryDate complicationTemplate:complicationTemplate];
//            handler(currentPlanetaryHourTimelineEntry);
//        }];
//    });
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after the given date
    handler(nil);
}

#pragma mark - Placeholder Templates

- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
    // This method will be called once per supported complication, and the results will be cached
//    handler([CLKComplicationTemplateModularLargeStandardBody new]);
    handler(nil);
}

@end
