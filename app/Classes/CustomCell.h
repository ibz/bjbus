//
//  CustomCell.h
//  bjbus
//
//  Created by ibz on 10-03-28.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomCell : UITableViewCell {
	IBOutlet UILabel* nameLabel;
	IBOutlet UILabel* pinyinNameLabel;
}

@property (nonatomic, retain) IBOutlet UILabel* nameLabel;
@property (nonatomic, retain) IBOutlet UILabel* pinyinNameLabel;

@end
