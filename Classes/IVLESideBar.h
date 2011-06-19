//
//  IVLESideBar.h
//  IVLE
//
//  Created by Lee Sing Jie on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IVLE.h"
#import "ModuleHeader.h"
#import "ModuleHeaderInfo.h"
#import "LeftSideBarCellView.h"
#import "ForumViewController.h"
#import "IVLE.h"
#import "Timetable.h"
#import "ModulesWorkbin.h"
#import "ModulesInfo.h"
#import "ModulesAnnouncements.h"
#import "CAPCalculator.h"
#import "Events.h"
#import "Constants.h"

#import "Map.h"

@interface IVLESideBar : UIViewController <ModuleHeaderDelegate, UITableViewDelegate, UITableViewDataSource>{


	IBOutlet UITableView *moduleList;
	IBOutlet LeftSideBarCellView *tableCell;
}

+(void) clear;

@end
