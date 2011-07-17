//
//  TableCellView.m
//  SimpleTable
//
//  Created by Adeem on 30/05/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "LeftSideBarCellView.h"

@interface LeftSideBarCellView (PrivateMethods)

-(UIButton *) getCellButtonRight;

-(UIButton *) getCellButtonLeft;

@end


@implementation LeftSideBarCellView

@synthesize cellButtonLeft,cellButtonRight;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}

- (void)setLabelTextLeft:(NSString *)text {
	cellTextLeft.text = text;
}
- (void)setLabelTextRight:(NSString *)text{
	cellTextRight.text = text;
}
- (void)setButtonImageLeft:(UIImage *)image{
	[cellButtonLeft setImage:image forState:UIControlStateNormal];
}
- (void)setButtonImageRight:(UIImage *)image{
	[cellButtonRight setImage:image forState:UIControlStateNormal];
}

- (void)setButtonTagLeft:(NSInteger)buttonTag {
	cellButtonLeft.tag = buttonTag;
}

- (void)setButtonTagRight:(NSInteger)buttonTag {
	cellButtonRight.tag = buttonTag;
}

- (void)removeLabelLeft {
	[cellTextLeft removeFromSuperview];
}
- (void)removeLabelRight {
	[cellTextRight removeFromSuperview];
}
- (void)removeButtonLeft {
	[cellButtonLeft removeFromSuperview];
}
- (void)removeButtonRight {
	[cellButtonRight removeFromSuperview];
}

-(UIButton*) getCellButtonRight {
	
	return cellButtonRight;
}

-(UIButton*) getCellButtonLeft {
	
	return cellButtonLeft;
}

@end
