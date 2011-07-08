//
//  Stations.m
//  bjbus
//
//  Created by ibz on 10-02-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>
#import "Stations.h"


@implementation Stations

- (void)viewDidLoad {
	[self loadStations];

	searching = NO;

	[stationsTableView reloadData];

    [super viewDidLoad];
}

- (void)loadStations {
	NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"bjbus.db"];

	sqlite3 *db;
	if(sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
		return;
	}

	sqlite3_stmt *stmt;
	sqlite3_prepare_v2(db, [@"SELECT name, ename FROM station" UTF8String], -1, &stmt, NULL);
	stations = [[NSMutableArray alloc] init];
	filteredStations = [[NSMutableArray alloc] init];
	while(sqlite3_step(stmt) == SQLITE_ROW) {
		NSString *name = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
		NSString *ename = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
		[stations addObject: [[[NSDictionary alloc] initWithObjectsAndKeys: name, @"name", ename, @"ename", nil] autorelease]];
	}
	sqlite3_finalize(stmt);

	sqlite3_close(db);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (searching) {
		return [filteredStations count];
	} else {
		return [stations count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {	
	static NSString *cellIdentifier = @"station_cell";

	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:cellIdentifier] autorelease];
	}

	NSDictionary *station;
	if (searching) {
		station = [filteredStations objectAtIndex: indexPath.row];
	} else {
		station = [stations objectAtIndex: indexPath.row];
	}

	cell.text = [NSString stringWithFormat: @"%@ (%@)", [station objectForKey: @"name"], [station objectForKey: @"ename"]];

	return cell;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if([searchText length] > 0) {
		searching = YES;
		[self searchTableView];
	} else {
		searching = NO;
	}

	[stationsTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {	
	[searchBar resignFirstResponder];
	[stationsTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	searchBar.text = @"";
	searching = NO;
	[stationsTableView reloadData];
}

- (void) searchTableView {
	NSString *searchText = stationsSearchBar.text;

	[filteredStations removeAllObjects];
	for (NSDictionary *station in stations)
	{
		if ([[station objectForKey: @"ename"] rangeOfString: searchText].location != NSNotFound) {
			[filteredStations addObject: station];
		}
	}
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)dealloc {
	[stations release];
	[filteredStations release];

    [super dealloc];
}


@end
