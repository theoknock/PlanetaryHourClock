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
    // TO-DO: Use this to store user-preferred complication template for a given template family
    NSMutableDictionary<NSNumber *, CLKComplicationTemplate *> *templates;
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

#pragma mark - Data Providers

// CLKDateTextProvider
// A formatted string that conveys a date without any time information.

// CLKImageProvider
// An image displayed by a complication.

// CLKFullColorImageProvider
// A full-color image displayed by a complication.

// CLKRelativeDateTextProvider
// A formatted string that conveys the difference in time between the current date and a date that you specify.

// CLKSimpleTextProvider
// A single line of text to display in your complication interface.

// CLKTextProvider
// The common behavior for displaying text-based data in a complication.

// CLKTimeIntervalTextProvider
// A formatted time range.

// CLKTimeTextProvider
// A formatted time value.

// CLKSimpleGaugeProvider
// A gauge that shows a fractional value.

// CLKTimeIntervalGaugeProvider
// A gauge that tracks time intervals.

// CLKGaugeProvider
// An abstract superclass that provides all the common behaviors for the gauge providers.

// CLKSimpleGaugeProviderFillFractionEmpty
// A fill value indicating an empty gauge.

// CLKGaugeProviderStyle
// Visual styles available for gauges.

#pragma mark - Complication Templates

// -------------------------------------------------------------
//
// CLKComplicationFamilyModularLarge
// A large rectangular area used in the Modular clock face.
//
// -------------------------------------------------------------

// Body Templates
// CLKComplicationTemplateModularLargeTallBody
// A template for displaying a header row and a tall row of body text.
CLKComplicationTemplateModularLargeTallBody *(^complicationTemplateModularLargeTallBody)(Planet) = ^(Planet planet)
{
    CLKComplicationTemplateModularLargeTallBody *template = [[CLKComplicationTemplateModularLargeTallBody alloc] init] ;
    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = nameForPlanet(planet);
    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = symbolForPlanet(planet);
    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).tintColor = colorForPlanet(planet);
    
    return template;
};

// CLKComplicationTemplateModularLargeStandardBody
// A template for displaying a header row and two lines of text

// Table Templates
// CLKComplicationTemplateModularLargeColumns
// A template for displaying multiple columns of data.

// CLKComplicationTemplateModularLargeTable
// A template for displaying a header row and columns

// -------------------------------------------------------------
//
// CLKComplicationFamilyModularSmall
// A small square area used in the Modular clock face.
//
// -------------------------------------------------------------

// Image Templates
// CLKComplicationTemplateModularSmallRingImage
// A template for displaying an image encircled by a configurable progress ring

// CLKComplicationTemplateModularSmallSimpleImage
// A template for displaying an image.

// CLKComplicationTemplateModularSmallStackImage
// A template for displaying a single image with a short line of text below it.

// Text Templates
// CLKComplicationTemplateModularSmallColumnsText
// A template for displaying two rows and two columns of text

// CLKComplicationTemplateModularSmallRingText
// A template for displaying text encircled by a configurable progress ring

// CLKComplicationTemplateModularSmallSimpleText
// A template for displaying a small amount of text.
CLKComplicationTemplateModularSmallSimpleText *(^complicationTemplateModularSmallSimpleText)(Planet) = ^(Planet planet)
{
    CLKComplicationTemplateModularSmallSimpleText *template = [[CLKComplicationTemplateModularSmallSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:symbolForPlanet(planet)];
    
    return template;
};

// CLKComplicationTemplateModularSmallStackText
// A template for displaying two strings stacked one on top of the other.

// -------------------------------------------------------------
//
//      CLKComplicationFamilyExtraLarge
//      A large square area used in the X-Large clock face.
//
// -------------------------------------------------------------

// Image Templates
// CLKComplicationTemplateExtraLargeRingImage
// A template for displaying an image encircled by a configurable progress ring.

// CLKComplicationTemplateExtraLargeSimpleImage
// A template for displaying an image.

// CLKComplicationTemplateExtraLargeStackImage
// A template for displaying a single image with a short line of text below it.

// Text Templates
// CLKComplicationTemplateExtraLargeColumnsText
// A template for displaying two rows and two columns of text.

// CLKComplicationTemplateExtraLargeRingText
// A template for displaying text encircled by a configurable progress ring.

// CLKComplicationTemplateExtraLargeSimpleText
// A template for displaying a small amount of text
CLKComplicationTemplateExtraLargeSimpleText *(^complicationTemplateModularLargeSimpleText)(Planet) = ^(Planet planet)
{
    CLKComplicationTemplateExtraLargeSimpleText *template = [[CLKComplicationTemplateExtraLargeSimpleText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:symbolForPlanet(planet)];
    
    return template;
};

// CLKComplicationTemplateExtraLargeStackText
// A template for displaying two strings stacked one on top of the other.

// -------------------------------------------------------------
//
//      CLKComplicationFamilyCircularSmall
//      A small circular area used in the Color clock face.
//
// -------------------------------------------------------------

// Image Templates
// CLKComplicationTemplateCircularSmallRingImage
// A template for displaying a single image surrounded by a configurable progress ring.

// CLKComplicationTemplateCircularSmallSimpleImage
// A template for displaying a single image.

// CLKComplicationTemplateCircularSmallStackImage
// A template for displaying an image with a line of text below it.

// Text Templates
// CLKComplicationTemplateCircularSmallRingText
// A template for displaying a short text string encircled by a configurable progress ring.
CLKComplicationTemplateCircularSmallRingText *(^complicationTemplateCircularSmallRingText)(Planet) = ^(Planet planet)
{
    CLKComplicationTemplateCircularSmallRingText *template = [[CLKComplicationTemplateCircularSmallRingText alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:symbolForPlanet(planet)];
    
    return template;
};

// CLKComplicationTemplateCircularSmallSimpleText
// A template for displaying a short text string.

// CLKComplicationTemplateCircularSmallStackText
// A template for displaying two text strings stacked on top of each other.

// -------------------------------------------------------------
//
//      CLKComplicationFamilyUtilitarianLarge
//      A large rectangular area that spans the width of the screen in the Utility and Mickey clock faces.
//
// -------------------------------------------------------------

// CLKComplicationTemplateUtilitarianLargeFlat
// A template for displaying an image and string in a single long line.

CLKComplicationTemplateUtilitarianLargeFlat *(^complicationTemplateUtilitarianLargeFlat)(Planet) = ^(Planet planet)
{
    CLKComplicationTemplateUtilitarianLargeFlat *template = [[CLKComplicationTemplateUtilitarianLargeFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:symbolForPlanet(planet)];
    
    return template;
};

// -------------------------------------------------------------
//
//      CLKComplicationFamilyUtilitarianSmall
//      A small square or rectangular area used in the Utility, Mickey, Chronograph, and Simple clock faces.
//
// -------------------------------------------------------------

// CLKComplicationTemplateUtilitarianSmallRingImage
// A template for displaying an image encircled by a configurable progress ring.

// CLKComplicationTemplateUtilitarianSmallRingText
// A template for displaying text encircled by a configurable progress ring.

// CLKComplicationTemplateUtilitarianSmallSquare
// A template for displaying a single square image.

// -------------------------------------------------------------
//
//      CLKComplicationFamilyUtilitarianSmallFlat
//      A small rectangular area used in the in the Photos, Motion, and Timelapse clock faces.
//
// -------------------------------------------------------------

// CLKComplicationTemplateUtilitarianSmallFlat
// A template for displaying an image and text in a single line
CLKComplicationTemplateUtilitarianSmallFlat *(^complicationTemplateUtilitarianSmallFlat)(Planet) = ^(Planet planet)
{
    CLKComplicationTemplateUtilitarianSmallFlat *template = [[CLKComplicationTemplateUtilitarianSmallFlat alloc] init];
    template.textProvider = [CLKSimpleTextProvider textProviderWithText:symbolForPlanet(planet)];
    
    return template;
};

CLKComplicationTemplate *(^templateForComplicationFamily)(CLKComplicationFamily) = ^(CLKComplicationFamily family)
{
    CLKComplicationTemplate *template = nil;
    
    Planet planet = [PlanetaryHourDataSource.sharedDataSource currentPlanetaryHour];
    //    if (!templates) {
    //        templates = [NSMutableDictionary dictionary];
    //    }
    //
    //    if (family) {
    //        template = [templates objectForKey:[NSNumber numberWithInteger:family]];
    //    } else {
    //        return nil;
    //    }
    //
    //    if (template) {
    //        return template;
    //    }
    
    switch (family) {
            //      CLKComplicationFamilyModularLarge
            //      A large rectangular area used in the Modular clock face.
        case CLKComplicationFamilyModularLarge:
            template = complicationTemplateModularLargeTallBody(planet);
            break;
            
            //      CLKComplicationFamilyModularSmall
            //      A small square area used in the Modular clock face.
        case CLKComplicationFamilyModularSmall:
            template = complicationTemplateModularSmallSimpleText(planet);
            break;
            
            
            //      CLKComplicationFamilyUtilitarianLarge
            //      A large rectangular area that spans the width of the screen in the Utility and Mickey clock faces.
        case CLKComplicationFamilyUtilitarianLarge:
            template = complicationTemplateUtilitarianLargeFlat(planet);
            break;
            
            //      CLKComplicationFamilyUtilitarianSmall
            //      A small square or rectangular area used in the Utility, Mickey, Chronograph, and Simple clock faces.
        case CLKComplicationFamilyUtilitarianSmall:
            template = complicationTemplateUtilitarianSmallFlat(planet);
            break;
            
            //      CLKComplicationFamilyUtilitarianSmallFlat
            //      A small rectangular area used in the in the Photos, Motion, and Timelapse clock faces.
        case CLKComplicationFamilyUtilitarianSmallFlat:
            template = complicationTemplateUtilitarianSmallFlat(planet);
            break;
            
            //      CLKComplicationFamilyExtraLarge
            //      A large square area used in the X-Large clock face.
        case CLKComplicationFamilyExtraLarge:
            template = complicationTemplateModularLargeSimpleText(planet);
            break;
            
            //      CLKComplicationFamilyCircularSmall
            //      A small circular area used in the Color clock face.
        case CLKComplicationFamilyCircularSmall:
            template = complicationTemplateCircularSmallRingText(planet);
            break;
            
            //      CLKComplicationFamilyGraphicCircular
            //      A circular area used in the Infograph and Infograph Modular clock faces.
            
            //      CLKComplicationFamilyGraphicBezel
            //      A circular area with optional curved text placed along the bezel of the Infograph clock face.
            
            //      CLKComplicationFamilyGraphicRectangular
            //      A large rectangular area used in the Infograph Modular clock face.
            
        default:
            break;
    }
    
    //    if (template) {
    //        [templates setObject:template forKey:[NSNumber numberWithInteger:family]];
    //    }
    
    return template;
};


//- (CLKComplicationTemplate *)populateTimelineEntryForComplication:(CLKComplication *)complication date:(NSDate *)date {
//    CLKComplicationTemplate *template = templateForComplicationFamily(complication.family);
//    if (!template) {
//        return nil ;
//    } else {
//        [PlanetaryHourDataSource.sharedDataSource planetaryHours:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull startDate, NSDate * _Nonnull endDate, NSInteger hour, BOOL current) {
//            switch (complication.family) {
//                case CLKComplicationFamilyModularLarge:
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).headerTextProvider).text = name;
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularLargeTallBody *)template).bodyTextProvider).text = [symbol string];
//                    break ;
//                case CLKComplicationFamilyModularSmall:
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateModularSmallSimpleText *)template).textProvider).text = [symbol string];
//                    break ;
//                case CLKComplicationFamilyUtilitarianLarge:
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianLargeFlat *)template).textProvider).text = [symbol string];
//                    break ;
//                case CLKComplicationFamilyUtilitarianSmall:
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateUtilitarianSmallFlat *)template).textProvider).text = [symbol string];
//                    break ;
//                case CLKComplicationFamilyExtraLarge:
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateExtraLargeSimpleText *)template).textProvider).text = [symbol string];
//                    break;
//                case CLKComplicationFamilyCircularSmall:
////                    ((CLKImageProvider *)((CLKComplicationTemplateCircularSmallRingImage *)template).imageProvider).onePieceImage = [UIImage new];
//                    ((CLKSimpleTextProvider *)((CLKComplicationTemplateCircularSmallRingText *)template).textProvider).text = [symbol string];
//                    break;
//                default:
//                    break ;
//            }
//        }];
//    }
//    return template ;
//}

//- (UIImage *)imageFromText:(NSString *)text
//{
//    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//    style.alignment = NSTextAlignmentCenter;
//    NSDictionary *attr = [NSDictionary dictionaryWithObject:style forKey:NSParagraphStyleAttributeName];
//
//    UIGraphicsBeginImageContextWithOptions(CGSize size, FALSE, 1.0);
//
//    [myString drawInRect:someRect withAttributes:attr];
//
//    // transfer image
//    CGContextSetShouldAntialias(UIGraphicsGetCurrentContext(), YES);
//    CGContextSetAllowsAntialiasing(UIGraphicsGetCurrentContext(), YES);
//
//    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//
//    return image;
//}


- (void)getCurrentTimelineEntryForComplication:(CLKComplication *)complication withHandler:(void(^)(CLKComplicationTimelineEntry * __nullable))handler {
    CLKComplicationTemplate *template = templateForComplicationFamily(complication.family); //[self populateTimelineEntryForComplication:complication date:[NSDate date]] ;
    
    if (!template) {
        handler(nil);
        return;
    }
    
    CLKComplicationTimelineEntry *tle = [CLKComplicationTimelineEntry entryWithDate:[NSDate date] complicationTemplate:template] ;
    handler(tle);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication beforeDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries prior to the given date
    handler(nil);
}

- (void)getTimelineEntriesForComplication:(CLKComplication *)complication afterDate:(NSDate *)date limit:(NSUInteger)limit withHandler:(void(^)(NSArray<CLKComplicationTimelineEntry *> * __nullable entries))handler {
    // Call the handler with the timeline entries after the given date
    handler(nil);
}

- (void)getPlaceholderTemplateForComplication:(CLKComplication *)complication withHandler:(void (^)(CLKComplicationTemplate * _Nullable))handler
{
    CLKComplicationTemplate *template = templateForComplicationFamily(complication.family);
    handler(template);
}

@end


