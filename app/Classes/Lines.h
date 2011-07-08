//
//  Routes.h
//  bjbus
//
//  Created by ibz on 10-02-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Lines : UITableViewController {
	IBOutlet UITableView *linesTableView;
	IBOutlet UISearchBar *linesSearchBar;

	NSArray *lines;
	NSMutableArray *filteredLines;

	BOOL searching;
}

@end
