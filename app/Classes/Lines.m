//
//  Routes.m
//  bjbus
//
//  Created by ibz on 10-02-20.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <sqlite3.h>

#import "CustomCell.h"
#import "Lines.h"
#import "Line.h"

@implementation Lines

- (void)viewDidLoad {
	[super viewDidLoad];

	[self loadLines];

	searching = NO;

	[linesTableView reloadData];
}

- (NSArray *) getRoutes:line_id {
	NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"bjbus.db"];

	sqlite3 *db;
	if(sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
		return;
	}

	sqlite3_stmt *stmt;
	sqlite3_prepare_v2(db, [[NSString stringWithFormat: @"SELECT id, fixed_fare, fare, start_time, end_time, length FROM route WHERE line_id = '%@'", line_id]UTF8String], -1, &stmt, NULL);
	NSMutableArray *routes = [[NSMutableArray alloc] init];
	while(sqlite3_step(stmt) == SQLITE_ROW) {
		int route_id = sqlite3_column_int(stmt, 0);
		BOOL fixed_fare = sqlite3_column_int(stmt, 1);
		float fare = sqlite3_column_double(stmt, 2);
		NSString *start_time = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 3)];
		NSString *end_time = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 4)];
		float length = sqlite3_column_double(stmt, 5);

		NSDictionary *route = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:route_id], @"id", [NSNumber numberWithInt: fixed_fare], @"fixed_fare", [NSNumber numberWithFloat: fare], @"fare", start_time, @"start_time", end_time, @"end_time", [NSNumber numberWithFloat: length], @"length", [[NSMutableArray alloc] init], @"stations", nil];

		[routes addObject: route];
	}
	sqlite3_finalize(stmt);

	for (NSDictionary *route in routes) {
		int route_id = [[route objectForKey:@"id"] intValue];
		NSMutableArray* stations = [route objectForKey: @"stations"];
		sqlite3_prepare_v2(db, [[NSString stringWithFormat: @"SELECT s.name, s.pinyin_name FROM station s JOIN route_station rs ON s.id = rs.station_id WHERE rs.route_id = %d ORDER BY rs.i;", route_id] UTF8String], -1, &stmt, NULL);
		while(sqlite3_step(stmt) == SQLITE_ROW) {
			NSString *name = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 0)];
			NSString *pinyin_name = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
			NSDictionary *station = [[NSDictionary alloc] initWithObjectsAndKeys: name, @"name", pinyin_name, @"pinyin_name", nil];
			[stations addObject: station];
		}
		sqlite3_finalize(stmt);
	}

	sqlite3_close(db);
	return routes;
}

- (void)loadLines {	
	NSString *dbPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: @"bjbus.db"];

	sqlite3 *db;
	if(sqlite3_open([dbPath UTF8String], &db) != SQLITE_OK) {
		return;
	}

	sqlite3_stmt *stmt;
	sqlite3_prepare_v2(db, [@"SELECT id, number, pinyin_number FROM line ORDER BY CAST(number as INTEGER)" UTF8String], -1, &stmt, NULL);
	lines = [[NSMutableArray alloc] init];
	while(sqlite3_step(stmt) == SQLITE_ROW) {
		int line_id = sqlite3_column_int(stmt, 0);
		NSString *number = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 1)];
		NSString *pinyin_number = [NSString stringWithUTF8String: (char *)sqlite3_column_text(stmt, 2)];

		NSDictionary *line = [[NSDictionary alloc] initWithObjectsAndKeys: [NSNumber numberWithInt:line_id], @"id", number, @"number", pinyin_number, @"pinyin_number", nil];

		[lines addObject: line];
	}
	sqlite3_finalize(stmt);

	sqlite3_close(db);

	filteredLines = [[NSMutableArray alloc] init];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (searching) {
		return [filteredLines count];
	} else {
		return [lines count];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"line_cell";

	CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil) {
		NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"CustomCell" owner:self options:nil];

		for (id currentObject in topLevelObjects){
			if ([currentObject isKindOfClass:[UITableViewCell class]]){
				cell = (CustomCell *) currentObject;
				break;
			}
		}
	}
	NSDictionary *line;
	if (searching) {
		line = [filteredLines objectAtIndex: indexPath.row];
	} else {
		line = [lines objectAtIndex: indexPath.row];
	}
	NSString *number = [line objectForKey:@"number"];
	NSString *pinyin_number = [line objectForKey:@"pinyin_number"];

	cell.nameLabel.text = number;
	if (![number isEqualToString: pinyin_number]) {
		cell.pinyinNameLabel.text = pinyin_number;
	}

	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *line;

	if(searching)
		line = [filteredLines objectAtIndex:indexPath.row];
	else {
		line = [lines objectAtIndex:indexPath.row];
	}

	NSArray *routes = [self getRoutes: [line objectForKey: @"id"]];
	Line *lineView = [[[Line alloc] initWithNibName:@"Line" bundle: [NSBundle mainBundle]] autorelease];
	lineView.line = line;
	lineView.routes = routes;
	[self.navigationController pushViewController:lineView animated:YES];
}


- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	if([searchText length] > 0) {
		searching = YES;
		[self searchTableView];
	} else {
		searching = NO;
	}
	
	[linesTableView reloadData];
}

- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {	
	[searchBar resignFirstResponder];
	[linesTableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	searchBar.text = @"";
	searching = NO;
	[linesTableView reloadData];
}

- (void)searchTableView {
	NSString *searchText = linesSearchBar.text;
	[filteredLines removeAllObjects];
	for (NSDictionary *line in lines)
	{
		NSString *number = [line objectForKey: @"number"];
		if ([number rangeOfString: searchText].location != NSNotFound) {
			[filteredLines addObject: line];
		}
	}
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.

    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[lines release];
	[filteredLines release];
    [super dealloc];
}


@end
