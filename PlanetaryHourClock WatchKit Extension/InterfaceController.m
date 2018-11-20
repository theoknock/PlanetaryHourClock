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

@end


@implementation InterfaceController

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];    

    // Configure interface objects here.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface) name:@"PlanetaryHoursDataSourceUpdatedNotification" object:nil];
}

- (void)willActivate {
    // This method is called when watch view controller is about to be visible to user
    [super willActivate];
    
}

- (void)didDeactivate {
    // This method is called when watch view controller is no longer visible
    [super didDeactivate];
}

- (void)updateInterface
{
    [[PlanetaryHourDataSource sharedDataSource] currentPlanetaryHourUsingBlock:^(NSAttributedString * _Nonnull symbol, NSString * _Nonnull name, NSDate * _Nonnull date) {
        [self.planetaryHourSymbolLabel setAttributedText:symbol];
        [self.planetaryHourNameLabel setText:name];
    }];
}

@end



