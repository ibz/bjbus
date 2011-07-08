//
//  Stations.h
//  bjbus
//
//  Created by ibz on 10-02-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Stations : UIViewController {
	IBOutlet UITableView *stationsTableView;
	IBOutlet UISearchBar *stationsSearchBar;

	NSMutableArray *stations;
	NSMutableArray *filteredStations;

	BOOL searching;
}

@end
