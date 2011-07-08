//
//  Route.h
//  bjbus
//
//  Created by ibz on 10-02-21.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Line : UIViewController {
	NSDictionary *line;
	NSArray *routes;
}

@property (nonatomic, retain) NSDictionary *line;
@property (nonatomic, retain) NSArray *routes;

@end
