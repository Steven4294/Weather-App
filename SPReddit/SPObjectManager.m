//
//  SPObjectManager.m
//  SPReddit
//
//  Created by Steven Petteruti on 2/15/18.
//  Copyright © 2018 Steven Petteruti. All rights reserved.
//

#import "SPObjectManager.h"
#import "SBJson5.h"
#import "SPDay.h"

@implementation SPObjectManager

+ (id)sharedManager {
    static SPObjectManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (instancetype)init{
    if (self = [super init]) {
        // Initialize self
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    }
    return self;
}

- (void)fetchDataForCurrentLocation:(void (^)(NSArray *, NSError *, CLLocation *))aCallback{
    [self.locationManager startUpdatingLocation];

    if (self.currentLocation == nil) {

        CLLocation *loc = [[CLLocation alloc] initWithLatitude:42.3601 longitude:-71.0589];
        // the device may havent enabled location services. lets just load Boston's weather anyway
        [self fetchDataWithCallback:^(NSArray *data, NSError *err, CLLocation *loc) {
            aCallback(data,err,loc);
        } forLocation:loc] ;
    }else{
        // proceed normally
        [self fetchDataWithCallback:^(NSArray *data, NSError *err, CLLocation *loc) {
            aCallback(data,err,loc);
        } forLocation:self.currentLocation];
    }
}
    
- (void)fetchDataWithCallback:(void (^)(NSArray *, NSError *, CLLocation *))aCallback forLocation:(CLLocation *)location{
    CGFloat lat = location.coordinate.latitude;
    CGFloat lon = location.coordinate.longitude;

    NSString *targetUrl = [NSString stringWithFormat:@"https://api.darksky.net/forecast/82f7771669e5fd73f266eb18bddf86a9/%f,%f?units=us&exclude=minutely,hourly,alerts,flags", lat, lon];
    [self makeApiRequest:^(NSArray *data, NSError *err, CLLocation *loc) {
        aCallback(data,err,loc);
    } forUrl:targetUrl forLocation:location];
    
}

// this where the magic happens
- (void)makeApiRequest:(void (^)(NSArray *, NSError *, CLLocation *))aCallback forUrl:(NSString *)url forLocation:(CLLocation *)location{

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    // handle the parsed response
    SBJson5ValueBlock block = ^(id v, BOOL *stop) {

        if ([v isKindOfClass:[NSMutableDictionary class]]) {

            
            SPDay *currentDay = [[SPDay alloc] initWithTime:[v[@"currently"][@"time"] intValue]
                                             andCurrentTemp:[v[@"currently"][@"temperature"] floatValue]
                                                 andSummary:v[@"currently"][@"summary"]];
            

            NSArray *payload  = v[@"daily"][@"data"];

            NSMutableArray *days = [[NSMutableArray alloc] init];
            [days addObject:currentDay];
            
            
            int index = 0;
            for (id day in payload) {
                
                // the first day is also the current day, we dont need this
                if (index > 0){
                    SPDay *forecast = [[SPDay alloc] initWithTime:[day[@"time"] intValue]
                                                           andLow:[day[@"temperatureLow"] floatValue]
                                                          andHigh:[day[@"temperatureHigh"] floatValue]
                                                       andSummary:day[@"summary"]];
                    
                    [days addObject:forecast];
                }
                index++;
                
            }
            aCallback([days copy], nil, location); //copy creates an immutable version (since we want an NSArray and not an NSMutableArray)
            
        }
    };
    
    SBJson5ErrorBlock eh = ^(NSError* err) {
        aCallback(nil, err, location);
    };
    
    // create a url request and parse it into objective c objects
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:
      ^(NSData * _Nullable data,
        NSURLResponse * _Nullable response,
        NSError * _Nullable error) {
          
          // parse the data into a nsdictionary
          id parser = [SBJson5Parser parserWithBlock:block
                                        errorHandler:eh];
          
          [parser parse:data];
          
      }] resume];
};

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    self.currentLocation = newLocation;
}

@end
