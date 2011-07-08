//
//  Route.m
//  bjbus
//
//  Created by ibz on 10-02-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CustomCell.h"
#import "RouteStationTableSectionHeader.h"
#import "Line.h"


@implementation Line

@synthesize line;
@synthesize routes;

- (void)viewDidLoad {
    [super viewDidLoad];

	self.navigationItem.title = [line objectForKey: @"number"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [routes count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 70;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSArray* nibViews = [[NSBundle mainBundle] loadNibNamed:@"RouteStationTableSectionHeader" owner:self options:nil];

	NSDictionary *route = [routes objectAtIndex: section];
	float fare = (float)[[route objectForKey: @"fare"] floatValue];
	BOOL fixedFare = (BOOL)[[route objectForKey: @"fixed_fare"] intValue];
	NSString *fareText;
	if (fixedFare) {
		fareText = [NSString stringWithFormat: @"fixed fare: %1.2f yuan", fare];
	} else {
		fareText = [NSString stringWithFormat: @"max fare: %1.2f yuan", fare];
	}

	NSString *start_time = [route objectForKey: @"start_time"];
	NSString *end_time = [route objectForKey: @"end_time"];

	RouteStationTableSectionHeader* sectionHeader = [nibViews objectAtIndex: 0];
	sectionHeader.detailsLabel.text = [NSString stringWithFormat:@"%@ - %@ / %@", start_time, end_time, fareText];

	NSArray *stations = [route objectForKey:@"stations"];
	NSDictionary* start_station = [stations objectAtIndex: 0];
	NSDictionary* end_station = [stations objectAtIndex: [stations count] - 1];

	sectionHeader.startStationLabel.text = [NSString stringWithFormat:@"From: %@", [start_station objectForKey: @"name"]];
	sectionHeader.endStationLabel.text = [NSString stringWithFormat:@"To: %@", [end_station objectForKey: @"name"]];

	return sectionHeader;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	int length = [[[routes objectAtIndex: section] objectForKey: @"length"] floatValue];
	return [NSString stringWithFormat:@"%1.2f km", (float)length];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[[routes objectAtIndex:section]objectForKey:@"stations"]count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"station_cell";

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

	NSDictionary* station = [[[routes objectAtIndex:indexPath.section]objectForKey:@"stations"]objectAtIndex:indexPath.row];

	cell.nameLabel.text = [station objectForKey:@"name"];
	cell.pinyinNameLabel.text = [station objectForKey:@"pinyin_name"];

	return cell;
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
    [super dealloc];
}


@end
