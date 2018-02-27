//
//  SPObjectManager.h
//  SPReddit
//
//  Created by Steven Petteruti on 2/15/18.
//  Copyright © 2018 Steven Petteruti. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface SPObjectManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong)  CLLocationManager *locationManager;
@property (nonatomic, strong)  CLLocation *currentLocation;



+ (id)sharedManager;

- (void)fetchDataWithCallback:(void (^)(NSArray *, NSError *, CLLocation *))aCallback forLocation:(CLLocation *)location;

- (void)fetchDataForCurrentLocation:(void (^)(NSArray *, NSError *,  CLLocation *))aCallback;

@end
