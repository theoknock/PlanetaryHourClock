//
//  InterfaceController.h
//  PlanetaryHourClock WatchKit Extension
//
//  Created by Xcode Developer on 11/17/18.
//  Copyright © 2018 The Life of a Demoniac. All rights reserved.
//

#import <WatchKit/WatchKit.h>
#import <Foundation/Foundation.h>

@interface InterfaceController : WKInterfaceController

@property (weak, nonatomic) IBOutlet WKInterfaceLabel *planetaryHourSymbolLabel;
@property (weak, nonatomic) IBOutlet WKInterfaceLabel *planetaryHourNameLabel;

@end
