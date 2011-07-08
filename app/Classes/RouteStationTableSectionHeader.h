//
//  RouteStationTableSectionHeader.h
//  bjbus
//
//  Created by ibz on 10-03-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteStationTableSectionHeader : UIView {
	IBOutlet UILabel* startStationLabel;
	IBOutlet UILabel* endStationLabel;
	IBOutlet UILabel* detailsLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* startStationLabel;
@property (nonatomic, retain) IBOutlet UILabel* endStationLabel;
@property (nonatomic, retain) IBOutlet UILabel* detailsLabel;

@end
