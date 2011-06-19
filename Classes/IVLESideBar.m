//
//  IVLESideBar.m
//  IVLE
//
//  Created by Lee Sing Jie on 3/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "IVLESideBar.h"

@implementation IVLESideBar
#define HEADER_HEIGHT 40
#define ROW_HEIGHT 110.0
#define kNotificationSetWelcomeMessage @"setWelcomeMessage"
#define kNotificationSetPageTitle @"setPageTitle"

static IVLESideBar *sharedSingleton;
//@synthesize moduleList;

NSMutableArray* moduleStrings;
NSMutableArray* moduleActiveLinks;
NSMutableArray* moduleHeaderInfoArray;
NSDictionary *moduleActiveLinksAssociation;
NSDictionary *moduleActiveLinksImageAssociation;
NSInteger openSectionIndex;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.


+ (void)clear
{
	
	[moduleStrings release];
//	[moduleHeaderInfoArray release];
	[moduleActiveLinksAssociation release];
	sharedSingleton = NULL;
	moduleHeaderInfoArray = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
	
	@synchronized(self)
    {
		if (sharedSingleton == NULL) {
			NSLog(@"I AM HERE");
			sharedSingleton = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
		}
    }
	
	return sharedSingleton;
	
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	
	IVLE *ivle = [IVLE instance];
	openSectionIndex = -1;
	
	moduleStrings = [[[NSMutableArray alloc] init] retain];
	
	NSDictionary *moduleDict = [ivle modules:0 withAllInfo:NO];
	
		NSLog(@"%@", moduleDict);
	int i;
	for (i=0; i<[[moduleDict valueForKey:@"Results"] count]; i++) {
		NSArray *module = [[moduleDict valueForKey:@"Results"] objectAtIndex:i];
		if (![[module valueForKey:@"ID"] isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
			[moduleStrings addObject:[[moduleDict valueForKey:@"Results"] objectAtIndex:i]] ;
		}
	}
	
	if (moduleHeaderInfoArray == nil) {
		
		moduleHeaderInfoArray = [[[NSMutableArray alloc] init] retain];
		moduleActiveLinks = [[[NSMutableArray alloc] init] retain];

		for(NSArray *module in moduleStrings) {
			
			ModuleHeaderInfo *moduleHeaderInfo = [[ModuleHeaderInfo alloc] init];
			moduleHeaderInfo.open = NO;
			moduleHeaderInfo.moduleName = [module valueForKey:@"CourseCode"];
			moduleHeaderInfo.moduleID = [module valueForKey:@"ID"];
			[moduleHeaderInfoArray addObject:moduleHeaderInfo];
			[moduleHeaderInfo release];
			
			[moduleActiveLinks addObject:[[NSArray alloc] initWithObjects:@"Information",@"Announcements",@"Forum",@"Workbin",nil]];

		}
	}
	
	
	moduleActiveLinksAssociation = [[[NSDictionary alloc] initWithObjectsAndKeys: @"ModulesInfo",@"Information",@"ModulesAnnouncements",@"Announcements",@"ForumViewController",@"Forum",@"ModulesWorkbin",@"Workbin",nil] retain];
	moduleActiveLinksImageAssociation =[[[NSDictionary alloc] initWithObjectsAndKeys: @"information.png",@"Information",@"announcements.png",@"Announcements",@"forum.png",@"Forum",@"workbin.png",@"Workbin",nil] retain];
	
	UIImage *backgroundImage = [UIImage imageNamed:@"IVLE_side_bar_bg.png"];
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:backgroundImage]];
	moduleList.backgroundColor = [UIColor clearColor];
}




-(NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
    
    return [moduleStrings count];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	return ROW_HEIGHT;
	
}
-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section {
    
	ModuleHeaderInfo *moduleHeaderInfo = [moduleHeaderInfoArray objectAtIndex:section];
	if (!moduleHeaderInfo.headerView) {
		
		moduleHeaderInfo.headerView = [[[ModuleHeader alloc] initWithFrame:CGRectMake(0.0, 0.0, moduleList.bounds.size.width, HEADER_HEIGHT) title:moduleHeaderInfo.moduleName module:section delegate:self] autorelease];
		
	}
	return moduleHeaderInfo.headerView;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	
	//NSLog(@"%d", section);
	NSInteger numOfActiveLinksInModule = ceil([[moduleActiveLinks objectAtIndex:section] count]/2.0);
	ModuleHeaderInfo *moduleHeaderInfo =  [moduleHeaderInfoArray objectAtIndex:section];
	return moduleHeaderInfo.open ? numOfActiveLinksInModule : 0;
	
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	
	return HEADER_HEIGHT;
}


-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	MyIdentifier = @"tableCellView";
	
	LeftSideBarCellView *cell = (LeftSideBarCellView *)[tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if(cell == nil) {
		[[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil];
		cell = tableCell;
	}
	
	
	int rowNumber = indexPath.row;
	int linkCount = [[moduleActiveLinks objectAtIndex:indexPath.section] count];
	
	if ((rowNumber == (ceil(linkCount/2.0)-1)) && (linkCount%2 == 1)) {
		
		[cell setLabelTextLeft:[[moduleActiveLinks objectAtIndex:indexPath.section] objectAtIndex:(rowNumber*2)]];
		UIButton *leftButton = [cell getCellButtonLeft];
		leftButton.tag = indexPath.section*10+(rowNumber*2);
		[leftButton addTarget:[self retain] action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
		UIImage *leftButtonImage =[UIImage imageNamed:[moduleActiveLinksImageAssociation objectForKey:[[moduleActiveLinks objectAtIndex:indexPath.section] objectAtIndex:(rowNumber*2)]]];
		[leftButton setImage:leftButtonImage forState:UIControlStateNormal];
		
		[cell removeLabelRight];
		[cell removeButtonRight];
	}
	else {
		[cell setLabelTextLeft:[[moduleActiveLinks objectAtIndex:indexPath.section] objectAtIndex:(rowNumber*2)]];
		[cell setLabelTextRight:[[moduleActiveLinks objectAtIndex:indexPath.section] objectAtIndex:(rowNumber*2+1)]];
		
		
		UIButton *leftButton = [cell getCellButtonLeft];
		UIButton *rightButton = [cell getCellButtonRight];
		
		leftButton.tag = indexPath.section*10+(rowNumber*2);
		rightButton.tag	 = indexPath.section*10+(rowNumber*2+1);
		
		[leftButton addTarget:[self retain] action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
		[rightButton addTarget:[self retain] action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
		
		UIImage *leftButtonImage =[UIImage imageNamed:[moduleActiveLinksImageAssociation objectForKey:[[moduleActiveLinks objectAtIndex:indexPath.section] objectAtIndex:(rowNumber*2)]]];
		UIImage *rightButtonImage = [UIImage imageNamed:[moduleActiveLinksImageAssociation objectForKey:[[moduleActiveLinks objectAtIndex:indexPath.section] objectAtIndex:(rowNumber*2+1)]]];
		
		[leftButton setImage:leftButtonImage forState:UIControlStateNormal];
		[rightButton setImage:rightButtonImage forState:UIControlStateNormal];
		
	}
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
	
}


- (void)btnClicked:(id)sender{
	UIButton *button = (UIButton*)sender;
	
	NSInteger tag = button.tag;
	
	NSInteger sectionNumber = tag/10;
	NSInteger linkNumber = tag%10;
	
	//	NSLog(@"Section Number %d\n",button.state);
	//	NSLog(@"Link Number %d\n",linkNumber);
	
	NSString *nibName = [moduleActiveLinksAssociation objectForKey:[[moduleActiveLinks objectAtIndex:sectionNumber] objectAtIndex:linkNumber]];
	
//	NSLog(@"NIB NAME %@ \n",nibName);
	
	
	UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	spinner.frame = CGRectMake(1024/2-spinner.frame.size.width/2, 768/2-spinner.frame.size.height/2, spinner.frame.size.width, spinner.frame.size.height);
	[spinner startAnimating];
	[[self.view superview] addSubview:spinner];
	self.view.userInteractionEnabled = NO;
	
	NSArray *leftBar;
	if ([nibName compare:@"ModulesInfo"] == NSOrderedSame) {
		leftBar = [NSArray arrayWithObject:[[ModulesInfo alloc] initWithNibName:nibName bundle:nil]];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetPageTitle object:[NSString stringWithString:@"Modules | Information"]];
	}
	
	else if ([nibName compare:@"ModulesAnnouncements"] == NSOrderedSame) {
		
		leftBar = [NSArray arrayWithObject:[[ModulesAnnouncements alloc] initWithNibName:nibName bundle:nil]];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetPageTitle object:[NSString stringWithString:@"Modules | Announcements"]];
	}
	
	else if ([nibName compare:@"ForumViewController"] == NSOrderedSame) {
		
		leftBar = [NSArray arrayWithObject:[[ForumViewController alloc] initWithNibName:nibName bundle:nil]];
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetPageTitle object:[NSString stringWithString:@"Modules | Forum"]];
	}
	
	else if ([nibName compare:@"ModulesWorkbin"] == NSOrderedSame) {
		
		leftBar = [NSArray arrayWithObject:[[ModulesWorkbin alloc] initWithNibName:nibName bundle:nil]];	
		[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSetPageTitle object:[NSString stringWithString:@"Modules | Workbin"]];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRefreshRightScreen object:leftBar];
	[spinner removeFromSuperview];
	self.view.userInteractionEnabled = YES;
	[spinner release];
	
}

-(void)moduleHeader:(ModuleHeader*)sectionHeaderView moduleOpened:(NSInteger)sectionOpened {
	
	
	ModuleHeaderInfo *moduleHeaderInfo = [moduleHeaderInfoArray objectAtIndex:sectionOpened];
	moduleHeaderInfo.open = YES;
	[IVLE instance].selectedCourseID = moduleHeaderInfo.moduleID;
//	NSLog(@"%@", [IVLE instance].selectedCourseID);
    
    /*
     Create an array containing the index paths of the rows to insert: These correspond to the rows for each quotation in the current section.
     */
    NSInteger countOfRowsToInsert = ceil([[moduleActiveLinks objectAtIndex:sectionOpened] count]/2.0);
    NSMutableArray *indexPathsToInsert = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < countOfRowsToInsert; i++) {
        [indexPathsToInsert addObject:[NSIndexPath indexPathForRow:i inSection:sectionOpened]];
		
    }
    
    /*
     Create an array containing the index paths of the rows to delete: These correspond to the rows for each quotation in the previously-open section, if there was one.
     */
    NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
	
	
	
    NSInteger previousOpenHeaderIndex = openSectionIndex;
    if (previousOpenHeaderIndex != -1) {
		
		ModuleHeaderInfo *previousOpenHeader = [moduleHeaderInfoArray objectAtIndex:previousOpenHeaderIndex];
        previousOpenHeader.open = NO;
		[previousOpenHeader.headerView toggleOpenWithUserAction:NO];
        NSInteger countOfRowsToDelete = ceil([[moduleActiveLinks objectAtIndex:previousOpenHeaderIndex] count]/2.0);
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:previousOpenHeaderIndex]];
        }
    }
    
    // Style the animation so that there's a smooth flow in either direction.
    UITableViewRowAnimation insertAnimation;
    UITableViewRowAnimation deleteAnimation;
    if (previousOpenHeaderIndex == -1 || sectionOpened < previousOpenHeaderIndex) {
        insertAnimation = UITableViewRowAnimationTop;
        deleteAnimation = UITableViewRowAnimationBottom;
    }
    else {
        insertAnimation = UITableViewRowAnimationBottom;
        deleteAnimation = UITableViewRowAnimationTop;
    }
    
    // Apply the updates.
    [moduleList beginUpdates];
    [moduleList deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:deleteAnimation];
    [moduleList insertRowsAtIndexPaths:indexPathsToInsert withRowAnimation:insertAnimation];
    [moduleList endUpdates];
    openSectionIndex = sectionOpened;
	
	//NSLog(@"%@", moduleList);
    
    [indexPathsToInsert release];
    [indexPathsToDelete release];
}

-(void)moduleHeader:(ModuleHeader*)sectionHeaderView moduleClosed:(NSInteger)sectionClosed {
    
    /*
     Create an array of the index paths of the rows in the section that was closed, then delete those rows from the table view.
     */
	ModuleHeaderInfo *moduleHeaderInfo = [moduleHeaderInfoArray objectAtIndex:sectionClosed];
	moduleHeaderInfo.open = NO;
	
	
	NSInteger countOfRowsToDelete = ceil([[moduleActiveLinks objectAtIndex:sectionClosed] count]/2.0);
    
    if (countOfRowsToDelete > 0) {
        NSMutableArray *indexPathsToDelete = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < countOfRowsToDelete; i++) {
            [indexPathsToDelete addObject:[NSIndexPath indexPathForRow:i inSection:sectionClosed]];
        }
        [moduleList deleteRowsAtIndexPaths:indexPathsToDelete withRowAnimation:UITableViewRowAnimationTop];
        [indexPathsToDelete release];
    }
    openSectionIndex = -1;
}






- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return interfaceOrientation == UIInterfaceOrientationLandscapeLeft;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
	NSLog(@"dealloc sidebar %@", self);
	[moduleStrings release];
	[moduleHeaderInfoArray release];
	[moduleActiveLinksAssociation release];
    [super dealloc];

	
}


@end
