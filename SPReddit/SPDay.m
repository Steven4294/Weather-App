//
//  SPDay.m
//  SPReddit
//
//  Created by Steven Petteruti on 2/26/18.
//  Copyright © 2018 Steven Petteruti. All rights reserved.
//

#import "SPDay.h"

@implementation SPDay

- (instancetype)initWithTime:(int)time andLow:(float)low andHigh:(float)high andSummary:(NSString *)summary
{
    self = [super init];
    if (self != nil)
    {
        // Further initialization if needed
        _time = time;
        _low = low;
        _high = high;
        _summary = summary;
    }
    return self;
}

- (instancetype)initWithTime:(int)time andCurrentTemp:(float)temperature andSummary:(NSString *)summary{
    
    self = [super init];
    if (self != nil)
    {
        // Further initialization if needed
        _time = time;
        _currentTemp = temperature;
        _summary = summary;
    }
    return self;
}


@end
