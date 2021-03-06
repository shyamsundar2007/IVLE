//
//  IVLE.m
//  IVLE
//
//  Created by Lee Sing Jie on 3/21/11.
//  Copyright 2011 NUS. All rights reserved.
//

#import "IVLE.h"

@implementation IVLE
static IVLE *sharedSingleton;

@synthesize authenticationToken;
@synthesize userName;
@synthesize selectedWorkbinID;
@synthesize selectedCourseID;
@synthesize handler;

-(id)init{
	self = [super init];
	
	handler = [[IVLEAPIHandler alloc] init];
	authenticationToken = nil;
	
	return self;
}

+ (IVLE *)instance
{
	@synchronized(self)
    {
		if (sharedSingleton == NULL)
			sharedSingleton = [[self alloc] init];
    }
	
	return sharedSingleton;
}

-(NSString *) authenticationToken {
	
	return authenticationToken;
}

-(void) setAuthToken:(NSString *)authToken {
    self.authenticationToken = authToken;
}

-(NSString*) getAndSetUserName:(BOOL)isOnline {
    
	if (isOnline) {
		NSString *user = [handler getUserName:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/UserName_Get?APIKey=%@&Token=%@&output=json", kAPIKey, authenticationToken]];
		self.userName = [NSString stringWithString:user];
		
		//save token to file
		NSError *error;
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserName.txt"];
		NSString *string = self.userName;
		BOOL ok = [string writeToFile:path atomically:YES
							 encoding:NSUTF8StringEncoding error:&error];
		if (!ok) {
			// an error occurred
			NSLog(@"Error writing file at %@\n%@",
				  path, [error localizedFailureReason]);
		}
		
		
		return [user stringByReplacingOccurrencesOfString:@" " withString:@""];		
	}
    else {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *path = [documentsDirectory stringByAppendingPathComponent:@"UserName.txt"];
		NSError *error;
		NSString *stringFromFileAtPath = [[NSString alloc]
										  initWithContentsOfFile:path
										  encoding:NSUTF8StringEncoding
										  error:&error];
		
		if(stringFromFileAtPath != nil) {
			self.userName = stringFromFileAtPath;
			return [self.userName stringByReplacingOccurrencesOfString:@" " withString:@""];		
		}
		
		return @"Offline";
	}
	return @"Offline";
}

- (NSDictionary *)validate {
	
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Validate?APIKey=%@&Token=%@", kAPIKey, authenticationToken]];
}

-(NSDictionary*)announcements:(NSString*)courseID withDuration:(NSInteger)duration withTitle:(BOOL)title{	
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Announcements?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&TitleOnly=%@&output=json", kAPIKey, authenticationToken, courseID, duration, [self booleanToSystemBoolean:title]]];
    
}

-(NSDictionary*)classRoster:(NSString*)courseID{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Class_Roster?APIKey=%@&AuthToken=%@&CourseID=%@&output=json", kAPIKey, authenticationToken, courseID]];
}

-(NSDictionary*)modules:(NSInteger)duration withAllInfo:(BOOL)info{
	if (info) {
		NSAssert(0, @"modules:duration withAllInfo:info, info should be NO. Info == YES is too much info");
	}
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Modules?APIKey=%@&AuthToken=%@&Duration=%d&IncludeAllInfo=%@&output=json", kAPIKey, authenticationToken, duration, [self booleanToSystemBoolean:info]]];
}

-(NSDictionary*)module:(NSString*)courseID withDuration:(NSInteger)duration withTitle:(BOOL)title withAllInfo:(BOOL)info{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module?APIKey=%@&AuthToken=%@&Duration=%d&IncludeAllInfo=%@&CourseID=%@&TitleOnly=%@&output=json", kAPIKey, authenticationToken, duration, [self booleanToSystemBoolean:info], courseID, [self booleanToSystemBoolean:title]]];
}

-(NSDictionary*)moduleInfo:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_Information?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}

-(NSDictionary*)moduleLecturers:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_Lecturers?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}

-(NSDictionary*)moduleOrganizerEvents{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_Organizer_Events?APIKey=%@&AuthToken=%@&output=json", kAPIKey, authenticationToken]];
}

-(NSDictionary*)moduleReading:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_Reading?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}

-(NSDictionary*)moduleReadingFormatted:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_ReadingFormatted?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}

-(NSDictionary*)moduleReadingFormattedCoop:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_ReadingsFormatted_Coop?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}


-(NSDictionary*)moduleReadingUnformatted:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_ReadingUnformatted?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}

-(NSDictionary*)moduleWeblinks:(NSString*)courseID withDuration:(NSInteger)duration{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Module_Weblinks?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, courseID, duration]];
}


// ------------------- FORUM API CALLS -------------------------------------

-(NSDictionary*)forum:(NSString*)forumID withDuration:(NSInteger)duration withThreads:(BOOL)thread{
	if (thread == YES) {
		NSAssert(0, @"Are you insane? This will load ALL data in the forum");
	}
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum?APIKey=%@&AuthToken=%@&ForumID=%@&Duration=%d&IncludeThreads=%@&output=json", kAPIKey, authenticationToken, forumID, duration, [self booleanToSystemBoolean:thread]]];  
}

-(NSDictionary*)forumHeadingMainThreads:(NSString*)headingID withDuration:(NSInteger)duration withMainTopics:(BOOL)thread{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_HeadingThreads?APIKey=%@&AuthToken=%@&HeadingID=%@&Duration=%d&GetMainTopicsOnly=%@&output=json", kAPIKey, authenticationToken, headingID, duration, [self booleanToSystemBoolean:thread]]];
}

-(NSDictionary*)forumHeadings:(NSString*)forumID withDuration:(NSInteger)duration withThreads:(BOOL)thread{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_Headings?APIKey=%@&AuthToken=%@&ForumID=%@&Duration=%d&IncludeThreads=%@&output=json", kAPIKey, authenticationToken, forumID, duration, [self booleanToSystemBoolean:thread]]];
}

//-(NSDictionary*)forumHeadingThreads:(NSString*)headingID withDuration:(NSInteger)duration{
//	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_HeadingThreads?APIKey=%@&AuthToken=%@&HeadingID=%@&Duration=%d&output=json", kAPIKey, authenticationToken, headingID, duration]]; 
//}

- (NSDictionary *)forumThreads:(NSString *)threadID withDuration:(NSInteger)duration withThreads:(BOOL)thread {
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_Threads?APIKey=%@&AuthToken=%@&ThreadID=%@&Duration=%d&GetSubThreads=%@&output=json", kAPIKey, authenticationToken, threadID, duration, [self booleanToSystemBoolean:thread]]];
}

- (NSDictionary *)forumThread:(NSString *)threadID {
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_Thread?APIKey=%@&AuthToken=%@&ThreadID=%@&output=json", kAPIKey, authenticationToken, threadID]];
}

- (NSDictionary *)forums:(NSString *)courseID withDuration:(NSInteger)duration withThreads:(BOOL)thread withTitle:(BOOL)title {
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forums?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&IncludeThreads=%@&TitleOnly=%@&output=json", kAPIKey, authenticationToken, courseID, duration, [self booleanToSystemBoolean:thread], [self booleanToSystemBoolean:title]]];
}

- (NSDictionary *)forumPostNewThread:(NSString *)headingID withTitle:(NSString*)title withReply:(NSString*)reply{
	return [handler postURL:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_PostNewThread_JSON" withParameters:[NSString stringWithFormat:@"APIKey=%@&AuthToken=%@&HeadingID=%@&Title=%@&Reply=%@", kAPIKey, authenticationToken, headingID, title, reply]];
}

- (NSDictionary *)forumReplyThread:(NSString *)threadID withTitle:(NSString*)title withReply:(NSString*)reply{
	return [handler postURL:@"https://ivle.nus.edu.sg/api/Lapi.svc/Forum_ReplyThread_JSON" withParameters:[NSString stringWithFormat:@"APIKey=%@&AuthToken=%@&ThreadID=%@&Title=%@&Reply=%@", kAPIKey, authenticationToken, threadID, title, reply]];
}

// --------------------------- WORKBIN API CALLS ---------------------------------------

-(NSDictionary*)workbin:(NSString*)courseID withDuration:(NSInteger)duration withWorkbinID:(NSString*)workbinID withTitle:(BOOL)title{
	if (workbinID != nil) {
		return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Workbins?APIKey=%@&AuthToken=%@&Duration=%d&WorkbinID=%@&TitleOnly=%@&output=json", kAPIKey, authenticationToken, duration, workbinID, [self booleanToSystemBoolean:title]]];
	} else if (courseID != nil) {
		return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Workbins?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&TitleOnly=%@&output=json", kAPIKey, authenticationToken, courseID, duration, [self booleanToSystemBoolean:title]]];
	} else {
		NSAssert(0, @"courseID == nil & workbinID == nil");
	}

	return nil;
}

- (NSDictionary *)userEventsCreate:(NSString*)user withContact:(NSString*)hp withTitle:(NSString*)title withDescription:(NSString*)description withPrice:(NSString*)price atLocation:(CLLocationCoordinate2D)coordinates{
	return [handler postURL:[NSString stringWithFormat:@"http://%@/map.php",kMapServerHost] withParameters:[NSString stringWithFormat:@"user=%@&contact=%@&title=%@&description=%@&price=%@&latitude=%f&longitude=%f",user, hp, title, description, price, coordinates]];
}

- (NSDictionary *)userEventsGet:(NSInteger)hour{
	//time is used to prevent cache.
	return [handler getURL:[NSString stringWithFormat:@"http://%@/map.php?duration=%d&time=%.0f",kMapServerHost, hour, [NSDate timeIntervalSinceReferenceDate]]];
}

- (NSDictionary *)studentEvents:(BOOL)title {
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/StudentEvents?APIKey=%@&AuthToken=%@&TitleOnly=%@&output=json", kAPIKey, authenticationToken, [self booleanToSystemBoolean:title]]];
}

-(NSURLRequest*)workbinGetFile:(NSString*)fileID withExtension:(NSString*)ext{
	NSData *data = [handler getFile:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/downloadfile.ashx?APIKey=%@&AuthToken=%@&target=workbin&ID=%@", kAPIKey, authenticationToken, fileID]];
	NSString *pathToTempFile = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"download.%@", ext]];

	NSError *error=nil;
	[data writeToFile:pathToTempFile options:NSDataWritingAtomic error:&error];
	if (error != nil) {
		//NSLog(@"path:%@", pathToTempFile);

		//NSLog(@"%@", [error localizedFailureReason]);
	}
	return [NSURLRequest requestWithURL:[NSURL URLWithString:pathToTempFile]];
}

- (NSDictionary *)webcasts:(NSString *)courseID withDuration:(NSInteger)duration withTitleOnly:(BOOL)title {
		
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Webcasts?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&TitleOnly=%@&output=json", kAPIKey, authenticationToken, courseID, duration, [self booleanToSystemBoolean:title]]];
}

- (NSDictionary *)webcasts:(NSString *)courseID withDuration:(NSInteger)duration withMediaID:(NSString *)mediaID withTitleOnly:(BOOL)title {
	
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Webcasts?APIKey=%@&AuthToken=%@&CourseID=%@&Duration=%d&MediaChannelID=%@&TitleOnly=%@&output=json", kAPIKey, authenticationToken, courseID, duration, mediaID, [self booleanToSystemBoolean:title]]];
}

- (NSDictionary *)timetableStudentModule:(NSString *)courseID
{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Timetable_Student_Module?APIKey=%@&AuthToken=%@&CourseID=%@&output=json", kAPIKey, authenticationToken, courseID]];
}

- (NSDictionary *)timetableStudent:(NSString *)academicYear forSemester:(NSString *)semester
{
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Timetable_Student?APIKey=%@&AuthToken=%@&AcadYear=%@&Semester=%@&output=json", kAPIKey, authenticationToken, academicYear, semester]];
}

- (NSDictionary *)timetableModule:(NSString *)courseID {

	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Timetable_Module?APIKey=%@&AuthToken=%@&CourseID=%@&output=json", kAPIKey, authenticationToken, courseID]];
}

- (NSDictionary *)gradebookViewItems:(NSString *)courseID {
		
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/Gradebook_ViewItems?APIKey=%@&AuthToken=%@&CourseID=%@&output=json", kAPIKey, authenticationToken, courseID]];
}

- (NSDictionary *)libEreserves:(NSString *)courseID withTitleOnly:(BOOL)title {
	
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/LibEreserves?APIKey=%@&AuthToken=%@&CourseID=%@&TitleOnly=%@&output=json", kAPIKey, authenticationToken, courseID, [self booleanToSystemBoolean:title]]];
}

- (NSDictionary *)libEreserveFiles:(NSString *)folderID {

	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/LibEreserveFiles?APIKey=%@&AuthToken=%@&FolderID=%@&output=json", kAPIKey, authenticationToken, folderID]];
}

- (NSDictionary *)MyOrganizerIVLE:(NSString *)startDate withEndDate:(NSString *)endDate {
	
	NSDictionary *temp = [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/MyOrganizer_IVLE?APIKey=%@&AuthToken=%@&StartDate=%@&EndDate=%@&output=json", kAPIKey, authenticationToken, startDate, endDate]];
	return temp; 
}

- (NSDictionary *)MyOrganizerAcadSemesterInfo:(NSString *)acadYear ForSem:(NSString *)semester {
	
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/MyOrganizer_AcadSemesterInfo?APIKey=%@&AuthToken=%@&AcadYear=%@&Semester=%@&output=json", kAPIKey, authenticationToken, acadYear, semester]];
}

- (NSDictionary *)CodeTableWeekTypes {
	
	return [handler getURL:[NSString stringWithFormat:@"https://ivle.nus.edu.sg/api/Lapi.svc/CodeTable_WeekTypes?APIKey=%@&output=json", kAPIKey]];
}

-(NSString*)booleanToSystemBoolean:(BOOL)boolean{
	if (boolean) {
		return @"true";
	} 
	return @"false";
}

- (void)dealloc{
	sharedSingleton = nil;
	
	[super dealloc];
}


@end
