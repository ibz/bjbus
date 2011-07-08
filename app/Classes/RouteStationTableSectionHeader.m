//
//  RouteStationTableSectionHeader.m
//  bjbus
//
//  Created by ibz on 10-03-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "RouteStationTableSectionHeader.h"


@implementation RouteStationTableSectionHeader

@synthesize startStationLabel;
@synthesize endStationLabel;
@synthesize detailsLabel;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
    [super dealloc];
}


@end
