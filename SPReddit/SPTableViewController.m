//
//  SPTableViewController.m
//  SPReddit
//
//  Created by Steven Petteruti on 2/15/18.
//  Copyright © 2018 Steven Petteruti. All rights reserved.
//

#import "SPTableViewController.h"
#import "SPTableViewCell.h"
#import "SPObjectManager.h"
#import "SPDay.h"
#import "SPReddit-Bridging-Header.h"
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <CoreLocation/CLGeocoder.h>
#import <CoreLocation/CLPlacemark.h>

@interface SPTableViewController ()

@property NSMutableArray *days;

@end

@implementation SPTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

    [self.tableView layoutSubviews];
    
    // fetch the data
    SPObjectManager *sharedManager = [SPObjectManager sharedManager];
    
    [sharedManager fetchDataForCurrentLocation:^(NSArray *data, NSError *err, CLLocation *loc) {
        if (err == nil) {
            [self recievedData:data forLocation:loc];
        }
        else{
            NSLog(@"error fetching data: %@", err);
        }
    }];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitle:@"Edit" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(settingsBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    
}

- (void)settingsBtnClicked{
    
    UIStoryboard *st =  [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LocationPicker *vc =   [st instantiateViewControllerWithIdentifier:@"locationPicker"];
    vc.pickCompletion = ^(LocationItem * _Nonnull item) {
        float longitude = item.mapItem.placemark.location.coordinate.longitude;
        float latitude = item.mapItem.placemark.location.coordinate.latitude;

        SPObjectManager *sharedManager = [SPObjectManager sharedManager];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [sharedManager fetchDataWithCallback:^(NSArray *data, NSError *err, CLLocation *location) {
            if (err == nil) {
                [self recievedData:data forLocation:location];
            }
            else{
                NSLog(@"error fetching data: %@", err);
            }
        } forLocation:loc] ;
        
    };

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)recievedData:(NSArray *)data forLocation:(CLLocation *)loc{
    
    CLGeocoder* reverseGeocoder = [[CLGeocoder alloc] init];
    if (reverseGeocoder) {
        [reverseGeocoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
            CLPlacemark* placemark = [placemarks firstObject];
            if (placemark) {
                NSString* city = [placemark.addressDictionary objectForKey:(NSString *)kABPersonAddressCityKey];
                self.title = city;
            }
        }];
    }
    
    self.days = [[NSMutableArray alloc] init];
    
    for (SPDay *day in data) {
        [self.days addObject:day];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.days count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *MyIdentifier = @"SPIdentifier";

    SPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier forIndexPath:indexPath];

    if (cell == nil) {
        cell = [[SPTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle  reuseIdentifier:MyIdentifier];
    }
    
    SPDay *day = [self.days objectAtIndex:indexPath.row];
    cell.contentLabel.text = day.summary;
    
    if (!day.currentTemp) {
        // it's a forecast
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:day.time];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"EEEE | MMM d"];
        NSString *theDate = [dateFormatter stringFromDate:epochNSDate];
        cell.commentsLabel.text = theDate;
        
        cell.secondaryLabel.text = [NSString stringWithFormat:@"%.0f° to %.0f°", day.low, day.high];

        
    }else{
        // its the current day
        cell.commentsLabel.text = @"Today";
        
        cell.secondaryLabel.text = [NSString stringWithFormat:@"Currently %.0f°", day.currentTemp];
        [cell.secondaryLabel setFont:[cell.commentsLabel.font fontWithSize:30]];
        
    }
    if ((indexPath.row % 2) == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:1 alpha:.9];
    }else{
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    [cell updateConstraintsIfNeeded];
    [cell layoutIfNeeded];

    return cell;
}

// this is for the variable height tableview cell
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return UITableViewAutomaticDimension;
}


@end
