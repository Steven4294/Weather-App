//
//  SPDay.h
//  SPReddit
//
//  Created by Steven Petteruti on 2/26/18.
//  Copyright © 2018 Steven Petteruti. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPDay : NSObject

@property NSString *summary; // this is the id we'll have to reference for pagination
@property float low;
@property float high;
@property float currentTemp;
@property int time;

// use this for a forecasted day
- (instancetype)initWithTime:(int)time andLow:(float)low andHigh:(float)high andSummary:(NSString *)summary;

// use this for the current day
- (instancetype)initWithTime:(int)time andCurrentTemp:(float)temperature andSummary:(NSString *)summary;

@end
