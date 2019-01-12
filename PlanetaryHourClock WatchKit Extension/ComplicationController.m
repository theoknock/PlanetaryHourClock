//
//  ComplicationController.m
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import "ComplicationController.h"
#import "PlanetaryHourDataSource.h"

@interface ComplicationController () {
    NSMutableDictionary<NSNumber *, CLKComplicationTemplate *> *templates ;
}

@end

@implementation ComplicationController

#pragma mark - Timeline Configuration

- (void)getSupportedTimeTravelDirectionsForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimeTravelDirections directions))handler {
    handler(CLKComplicationTimeTravelDirectionForward|CLKComplicationTimeTravelDirectionBackward);
}

- (void)getTimelineStartDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    NSDate *startDate = [PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil].sunrise;
    handler(startDate);
    NSLog(@"Timeline start date\t%@", [startDate description]);
}

- (void)getTimelineEndDateForComplication:(CLKComplication *)complication withHandler:(void(^)(NSDate * __nullable date))handler {
    NSDate *endDate = [PlanetaryHourDataSource.sharedDataSource solarCalculationForDate:nil location:nil].sunset;
    handler(endDate);
    NSLog(@"Timeline end date\t%@", [endDate description]);
}

- (void)getPrivacyBehaviorForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationPrivacyBehavior privacyBehavior))handler {
    handler(CLKComplicationPrivacyBehaviorShowOnLockScreen);
}

#pragma mark - Timeline Population

- (CLKComplicationTemplate *)populateTimelineEntryForComplication:(CLKComplication *)complication date:(NSDate *)date {
    CLKComplicationTemplate *template = [self templateForeComplication:complication] ;
    if (!template) {
        return nil ;
    } else {

    [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = name;
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = [symbol string];
            break ;
        case CLKComplicationFamilyModularSmall:
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider).text = [symbol string];
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider).text = [symbol string];
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider).text = [symbol string];
            break ;
        case CLKComplicationFamilyExtraLarge:
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider).text = [symbol string];
            break;
        case CLKComplicationFamilyCircularSmall:
            ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallRingText *)template).textProvider).text = [symbol string];
            break;
        default:
            break ;
    }
    }];
    }
    return template ;
}

- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    CLKComplicationTemplate *template = [self populateTimelineEntryForComplication:complication date:[NSDate date]] ;
    
    if (!template) {
        handler(nil) ;
        return ;
    }
    
    CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    handler(tle);
}

//- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
//    [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
////        if (complication.family == CLKComplicationFamilyModularLarge)
////        {
////            CLKComplicationTemplateModularLargeTallBody *tallBody = [CLKComplicationTemplateModularLargeTallBody new];
////            tallBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:name];
////            tallBody.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:[symbol string]];
////            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:tallBody];
////            handler(entry);
////        } else
//        if (complication.family == CLKComplicationFamilyExtraLarge)
//        {
//            CLKComplicationTemplateModularLargeStandardBody *standardBody = [CLKComplicationTemplateModularLargeStandardBody new];
//            standardBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:name];
//            standardBody.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:[symbol string]];
//            standardBody.body2TextProvider = [CLKSimpleTextProvider textProviderWithText:[NSString stringWithFormat:@"Hour %ld", (long)hour]];
//            CLKComplicationTimelineEntry *entry = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:standardBody];
//            handler(entry);
//        }
//    }];
//    // Call the handler with the current timeline entry
//    //    [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
//    //    CLKSimpleTextProvider *planetaryHourTextProvider;
//    //        [planetaryHourTextProvider setText:name];
//    //        [planetaryHourTextProvider setShortText:[symbol string]];
//    //        [self getLocalizableSampleTemplateForComplication:complication withHandler:^(CLKComplicationTemplate * _Nullable complicationTemplate) {
//    //            [(CLKComplicationTemplateModularLargeStandardBody *)complicationTemplate setHeaderTextProvider:[CLKSimpleTextProvider textProviderWithText:@"S"]];
//    //            CLKComplicationTimelineEntry *currentPlanetaryHourTimelineEntry = [CLKComplicationTimelineEntry entryWithDate:startDate complicationTemplate:complicationTemplate];
//    //            handler(currentPlanetaryHourTimelineEntry);
//    //            NSLog(@"Symbol\t%@", [symbol string]);
//    //        }];
//    //    }];
//}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after the given date
    handler(nil);
}

#pragma mark - Placeholder Templates

- (CLKComplicationTemplateModularLargeTallBody *)complicationTemplateModularLargeTallBody {
    CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init] ;
    template.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Earth"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateModularSmallSimpleText *)complicationTemplateModularSmallSimpleText {
    CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}


- (CLKComplicationTemplateUtilitarianLargeFlat *)complicationTemplateUtilitarianLargeFlat {
    CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateUtilitarianSmallFlat *)complicationTemplateUtilitarianSmallFlat {
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateExtraLargeSimpleText *)complicationTemplateModularLargeSimpleText {
    CLKComplicationTemplateExtraLargeSimpleText *template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}

- (CLKComplicationTemplateCircularSmallRingText *)complicationTemplateCircularSmallRingText {
    CLKComplicationTemplateCircularSmallRingText *template = [[CLKComplicationTemplateCircularSmallRingText alloc] init] ;
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:@"㊏"] ;
    template.tintColor = [UIColor yellowColor] ;
    return template ;
}


- (CLKComplicationTemplate *)templateForeComplication:(CLKComplication *)complication {
    CLKComplicationTemplate *template = nil ;
    
    if (!templates) {
        templates = [NSMutableDictionary dictionary] ;
    }
    
    NSNumber *family = [NSNumber numberWithInt:complication.family] ;
    if (family) {
        template = [templates objectForKey:family] ;
    } else {
        return nil ;
    }
    
    if (template) {
        return template ;
    }
    
    switch (complication.family) {
        case CLKComplicationFamilyModularLarge:
            template = [self complicationTemplateModularLargeTallBody] ;
            break ;
        case CLKComplicationFamilyModularSmall:
            template = [self complicationTemplateModularSmallSimpleText] ;
            break ;
        case CLKComplicationFamilyUtilitarianLarge:
            template = [self complicationTemplateUtilitarianLargeFlat] ;
            break ;
        case CLKComplicationFamilyUtilitarianSmall:
            template = [self complicationTemplateUtilitarianSmallFlat];
            break;
        case CLKComplicationFamilyExtraLarge:
            template = [self complicationTemplateModularLargeSimpleText];
            break;
        case CLKComplicationFamilyCircularSmall:
            template = [self complicationTemplateCircularSmallRingText];
            break;
        default:
            break ;
    }
    
    if (template) {
        [templates setObject:template forKey:family] ;
    }
    
    return template ;
}

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    CLKComplicationTemplate *template = [self templateForeComplication:complication] ;
    handler(template) ;
}

//- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
//{
//    if (complication.family == CLKComplicationFamilyModularLarge)
//    {
//        CLKComplicationTemplateModularLargeTallBody *tallBody = [CLKComplicationTemplateModularLargeTallBody new];
//        tallBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"S"];
//        tallBody.bodyTextProvider = [CLKSimpleTextProvider textProviderWithText:@"Symbol"];
//        handler(tallBody);
//    } else if (complication.family == CLKComplicationFamilyExtraLarge)
//    {
//        CLKComplicationTemplateModularLargeStandardBody *standardBody = [CLKComplicationTemplateModularLargeStandardBody new];
//        standardBody.headerTextProvider = [CLKSimpleTextProvider textProviderWithText:@"S"];
//        standardBody.body1TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Symbol"];
//        standardBody.body2TextProvider = [CLKSimpleTextProvider textProviderWithText:@"Hour"];
//        handler(standardBody);
//    }
//}
//
//- (void)getLocalizableSampleTemplateForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTemplate * __nullable complicationTemplate))handler {
//    // This method will be called once per supported complication, and the results will be cached
//    //    switch (complication.family) {
//    //        case CLKComplicationFamilyModularSmall:
//    //        {
//    //            CLKSimpleTextProvider *textProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"headerTextProvider"];
//    //            CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
//    //            [template setTextProvider:textProvider];
//    //            handler(template);
//    //            break;
//    //        }
//    //        case CLKComplicationFamilyModularLarge:
//    //        {
//    //            CLKSimpleTextProvider *headerTextProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"headerTextProvider"];
//    //            CLKSimpleTextProvider *body1TextProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"body1TextProvider"];
//    //            CLKSimpleTextProvider *body2TextProvider = [CLKSimpleTextProvider localizableTextProviderWithStringsFileTextKey:@"body2TextProvider"];
//    //            CLKComplicationTemplateModularLargeStandardBody *template = [[CLKComplicationTemplateModularLargeStandardBody alloc] init];
//    //            [template setHeaderTextProvider:headerTextProvider];
//    //            [template setBody1TextProvider:body1TextProvider];
//    //            [template setBody2TextProvider:body2TextProvider];
//    //            handler(template);
//    //            break;
//    //        }
//    //        default:
//    //        {
//    //            CLKComplicationTemplate *template = [CLKComplicationTemplate new];
//    //            handler(template);
//    //        }
//    //            break;
//    //    }
//
//    handler(nil);
//}

@end

