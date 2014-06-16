//
//  TrackManager.m
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TrackManager.h"
#import "sqlite3.h"
#import "EventObject.h"
#import "ClientObject.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Utils.h"
#import "GenericTableItem.h"
#import "OpenUDID.h"

#define POST_DATA_TIMEOUT 240
#define DATABASE_NAME @"AppTrack.db3"
#define NOT_AVAILABLE_TEXT @"Not available"

/*** DO NOT CHANGE ***/
#pragma mark - EVENT TYPE ID
// Add here event type ids
const int EVENT_INFO = 1;
const int EVENT_DEBUG = 2;
const int EVENT_WARNING = 3;
const int EVENT_EXCEPTION = 4;
const int EVENT_SYSTEM = 5;
const int EVENT_CUSTOM = 100;

#pragma mark - SYSTEM EVENTS (9xxxxxxx)
// Add here system events code and description
#define EVENT_CODE_START                    @"00000000"
#define EVENT_CODE_DUMP                     @"99999996"
#define EVENT_CODE_RESTORE                  @"99999997"
#define EVENT_CODE_MINIMIZE                 @"99999998"
#define EVENT_CODE_STOP                     @"99999999"

#define EVENT_DESC_START                    @"START"
#define EVENT_DESC_DUMP                     @"DUMP"
#define EVENT_DESC_RESTORE                  @"RESTORE"
#define EVENT_DESC_MINIMIZE                 @"MINIMIZE"
#define EVENT_DESC_STOP                     @"STOP"

#pragma mark - INFO EVENTS (1xxxxxxx)
// Add here info events code and description
#define EVENT_CODE_START_SESSION            @"10000000"
#define EVENT_CODE_CHANGE_SECTION           @"10000001"
#define EVENT_CODE_COMMAND                  @"10000002"
#define EVENT_CODE_OPEN_PDF                 @"10000003"
#define EVENT_CODE_CLOSE_PDF                @"10000004"
#define EVENT_CODE_PLAY_VIDEO               @"10000005"
#define EVENT_CODE_TOGGLE_HIDDEN_CONTENT    @"10000011"
#define EVENT_CODE_BIBLIOGRAPHY             @"10000012"
#define EVENT_CODE_SWITCH_POPUP_IMAGE       @"10000013"
#define EVENT_CODE_CHANGE_PAGE              @"10000014"
#define EVENT_CODE_CHANGE_SUB_PAGE          @"10000015"
#define EVENT_CODE_SHOW_POPUP               @"10000016"
#define EVENT_CODE_CLOSE_POPUP              @"10000017"
#define EVENT_CODE_SWITCH_SECTION_MENU      @"10000018"
#define EVENT_CODE_SWITCH_HIDDEN_MENU       @"10000019"
#define EVENT_CODE_OPEN_WORD                @"10000021"
#define EVENT_CODE_CLOSE_WORD               @"10000022"
#define EVENT_CODE_OPEN_EXCEL               @"10000023"
#define EVENT_CODE_CLOSE_EXCEL              @"10000024"
#define EVENT_CODE_OPEN_POWERPOINT          @"10000025"
#define EVENT_CODE_CLOSE_POWERPOINT         @"10000026"
#define EVENT_CODE_STOP_SESSION             @"10000099"

#define EVENT_DESC_START_SESSION            @"START_SESSION"
#define EVENT_DESC_CHANGE_SECTION           @"CHANGE_SECTION"
#define EVENT_DESC_COMMAND                  @"COMMAND"
#define EVENT_DESC_OPEN_PDF                 @"OPEN_PDF"
#define EVENT_DESC_CLOSE_PDF                @"CLOSE_PDF"
#define EVENT_DESC_PLAY_VIDEO               @"PLAY_VIDEO"
#define EVENT_DESC_TOGGLE_HIDDEN_CONTENT    @"TOGGLE_HIDDEN_CONTENT"
#define EVENT_DESC_BIBLIOGRAPHY             @"BIBLIOGRAPHY"
#define EVENT_DESC_SWITCH_POPUP_IMAGE       @"SWITCH_POPUP_IMAGE"
#define EVENT_DESC_CHANGE_PAGE              @"CHANGE_PAGE"
#define EVENT_DESC_CHANGE_SUB_PAGE          @"CHANGE_SUB_PAGE"
#define EVENT_DESC_SHOW_POPUP               @"SHOW_POPUP"
#define EVENT_DESC_CLOSE_POPUP              @"CLOSE_POPUP"
#define EVENT_DESC_SWITCH_SECTION_MENU      @"SWITCH_SECTION_MENU"
#define EVENT_DESC_SWITCH_HIDDEN_MENU       @"SWITCH_HIDDEN_MENU"
#define EVENT_DESC_OPEN_WORD                @"OPEN_WORD"
#define EVENT_DESC_CLOSE_WORD               @"CLOSE_WORD"
#define EVENT_DESC_OPEN_EXCEL               @"OPEN_EXCEL"
#define EVENT_DESC_CLOSE_EXCEL              @"CLOSE_EXCEL"
#define EVENT_DESC_OPEN_POWERPOINT          @"OPEN_POWERPOINT"
#define EVENT_DESC_CLOSE_POWERPOINT         @"CLOSE_POWERPOINT"
#define EVENT_DESC_STOP_SESSION             @"STOP_SESSION"

#pragma mark - DEBUG EVENTS (2xxxxxxx)
// Add here debug events code and description

#pragma mark - WARNING EVENTS (3xxxxxxx)
// Add here warning events code and description

#pragma mark - EXCEPTION EVENTS (4xxxxxxx)
// Add here exception events code and description

#pragma mark - CUSTOM EVENTS (8xxxxxxx)
// Add here custom events code and description
#define EVENT_CODE_CHOICE                   @"80000001"
#define EVENT_CODE_MENU_EVENT               @"80000002"

/*** DO NOT CHANGE ***/

@implementation TrackManager

static TrackManager *sharedInstance = nil;

@synthesize databasePath;
@synthesize enableTracking;
@synthesize enableLocalization;
@synthesize request;
@synthesize storeDataServiceURL;

@synthesize events;

@synthesize documentsDir;

+ (TrackManager *) sharedInstance
{
    if (sharedInstance == nil)
    {
        sharedInstance = [[super allocWithZone:NULL] init];
        [sharedInstance initialize];
    }
    return sharedInstance;
}

+ (id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {        
        if (sharedInstance == nil)   
        {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;            
        }
    }
    return nil;
}

- (id) copyWithZone:(NSZone *)zone
{
    return self;
}

- (id) retain
{
    return self;
}

- (NSUInteger)retainCount
{
    return NSUIntegerMax;
}

- (id)autorelease
{
    return self;
}

- (void) dealloc {
	[self.databasePath release];
	[super dealloc];
}

- (void) initialize {
	self.enableTracking = YES;
	self.enableLocalization = NO;
    self.storeDataServiceURL = [NSString stringWithString:[Utils readStoreDataServiceURL]];
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDir = [documentPaths objectAtIndex:0];
	self.databasePath = [documentsDir stringByAppendingPathComponent:DATABASE_NAME];
    [self debugLog:[NSString stringWithFormat:@"Database path: %@", self.databasePath]];
}

- (void) checkAndCreateDabase {
    NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_NAME];
    
    [self debugLog:[NSString stringWithFormat:@"Database path from app: %@", databasePathFromApp]];
    [self debugLog:[NSString stringWithFormat:@"Database path: %@", self.databasePath]]; 
    
    BOOL success;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	success = [fileManager fileExistsAtPath:databasePath];
	if(success) {
        [self debugLog:@"Database already exists"];
        return;   
    }
    
    NSError *error = nil;
    [fileManager copyItemAtPath:databasePathFromApp toPath:databasePath error:&error];
    [self debugLog:[NSString stringWithFormat:@"Check for copy database error: %@", error]];
    [fileManager release];
    
	[self traceClient];
}


- (void) dropDatabase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager fileExistsAtPath:databasePath];
	if (success) {
        
        //Delete database from Document directory
        [fileManager removeItemAtPath:databasePath error:nil];
        
        // Reinitialize database  
        [self initialize];
        [self checkAndCreateDabase];
    }
}

- (void) clearDatabase {
    /// CHECK THIS!
    if (sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
        const char *statement = "DELETE FROM [app_Events]";
        char *err = nil;
        /* int execStatus = */ sqlite3_exec(database, statement, nil, nil, &err);
        if (err != nil) [self debugLog:[NSString stringWithFormat:@"%s", err]];
        sqlite3_stmt *deleteStatement;
        int sqlStatus = sqlite3_prepare_v2(database, statement, -1, &deleteStatement, NULL);
        if (sqlStatus == SQLITE_OK)
        {
            
            sqlite3_step(deleteStatement);
            [self debugLog:@"Clear data ok"];
        }
        else {
            [self debugLog:[NSString stringWithFormat:@"Error in clearing data %i %s", sqlStatus, sqlite3_errmsg(database)]];
        }
        sqlite3_reset(deleteStatement); 
        sqlite3_finalize(deleteStatement);
    }
    sqlite3_close(database);
}

- (void) readEvents {
    [events removeAllObjects];
    [events release];
    events = nil;
    events = [[NSMutableArray alloc] init];
    if (sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
        const char *statement = "SELECT Code, Description, ID FROM app_Events ORDER BY ClientTime";
        sqlite3_stmt *compiledStatement;
        if (sqlite3_prepare_v2(database, statement, -1, &compiledStatement, NULL) ==SQLITE_OK) {
            while (sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                GenericTableItem *item = [[GenericTableItem alloc] init];
                
                @try {
                    item.label = [NSString stringWithFormat:@"%@", 
                                  [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 1)]];
                }
                @catch (NSException *exception) {
                    item.label = NOT_AVAILABLE_TEXT;
                }
                @finally {
                    // DO NOTHING
                }
                
                @try {
                    item.detail = [NSString stringWithFormat:@"%@", 
                                   [NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, 0)]];
                }
                @catch (NSException *exception) {
                    item.label = NOT_AVAILABLE_TEXT;
                }
                @finally {
                    // DO NOTHING
                }                
                
                item.value = sqlite3_column_int(compiledStatement, 2);
                [events addObject:item];
                [item release];
            }
        }
        else {
            [self debugLog:[NSString stringWithFormat:@"Error in reading events: %i", sqlite3_errcode(database)]];
        }
        sqlite3_finalize(compiledStatement);
    }
    sqlite3_close(database);
}


- (void) traceClient {
	ClientObject *client = [[ClientObject alloc] init];
	if (sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
		const char *statement = "INSERT OR REPLACE INTO app_Client(ID, UniqueIdentifier, SystemName, SystemVersion) VALUES(1, ?,?,?)";
		sqlite3_stmt *compiledStatement;
        int sqlStatus = sqlite3_prepare_v2(database, statement, -1, &compiledStatement, NULL);
        if (sqlStatus == SQLITE_OK) {
			sqlite3_bind_text(compiledStatement, 1, [client.uniqueIdentifier cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(compiledStatement, 2, [client.systemName cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
			sqlite3_bind_text(compiledStatement, 3, [client.systemVersion cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
			sqlite3_step(compiledStatement);
		}
        else {
            [self debugLog:[NSString stringWithFormat:@"Error in traceClient (%i)", sqlite3_errcode(database)]];
        }
		sqlite3_finalize(compiledStatement);
	}
	sqlite3_close(database);
	[client dealloc];
}

#pragma mark - Generic tracing events

- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type {
	if (enableTracking) {
		[self traceEvent:code description:description type:type sender:nil extended:nil weight:0];
	}
}

- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type extended:(NSString*)extended {
	if (enableTracking) {
		[self traceEvent:code description:description type:type sender:nil extended:extended weight:0];
	}
}

- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type sender:(NSString*)sender {
	if (enableTracking) {
		[self traceEvent:code description:description type:type sender:sender extended:nil weight:0];
	}
}

- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type sender:(NSString*)sender extended:(NSString*)extended {
	if (enableTracking) {
		[self traceEvent:code description:description type:type sender:sender extended:extended weight:0];		
	}
}

- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type sender:(NSString*)sender extended:(NSString*)extended weight:(float)weight {
	if (enableTracking) {
		EventObject *event = [[EventObject alloc] init];
		event.type = type;
		event.code = code;
		event.description = description;
		event.sender = sender;
		event.extended = extended;
		event.weight = weight;
		[self traceEvent:event];
		[event release];
	}
}

- (void) traceDebug:(EventObject*)event {
	if (enableTracking) {
		event.type = EVENT_DEBUG;
		[self traceEvent:event];
	}
}

- (void) traceInfo:(EventObject*)event {
	if (enableTracking) {
		event.type = EVENT_INFO;
		[self traceEvent:event];
	}
}

- (void) traceWarning:(EventObject*)event {
	if (enableTracking) {
		event.type = EVENT_WARNING;
		[self traceEvent:event];
	}
}

- (void) traceException:(EventObject*)event {
	if (enableTracking) {
		event.type = EVENT_EXCEPTION;
		[self traceEvent:event];
	}
}

- (void) traceSystem:(EventObject*)event {
	if (enableTracking) {
		event.type = EVENT_SYSTEM;
		[self traceEvent:event];
	}
}

- (void) traceCustom:(EventObject*)event {
	if (enableTracking) {
		event.type = EVENT_CUSTOM;
		[self traceEvent:event];
	}
}


- (void) traceEvent:(EventObject*)event {
	if (enableTracking) {
        [self debugLog:[NSString stringWithFormat:@"Trying to open database at %@", self.databasePath]];
        
        if (sqlite3_open([self.databasePath UTF8String], &database) == SQLITE_OK) {
            const char *statement = "INSERT INTO app_Events(Type, Code, Description, Extended, Sender, Latitude, Longitude, Weight, ApplicationID, ClientTime, BundleIdentifier, BundleVersion) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
            sqlite3_stmt *compiledStatement;
            if (sqlite3_prepare_v2(database, statement, -1, &compiledStatement, NULL) == SQLITE_OK) {
                sqlite3_bind_int(compiledStatement, 1, event.type);
                sqlite3_bind_text(compiledStatement, 2, [event.code cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 3, [event.description cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 4, [event.extended cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 5, [event.sender cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);			
                sqlite3_bind_double(compiledStatement, 6, event.latitude);
                sqlite3_bind_double(compiledStatement, 7, event.longitude);
                sqlite3_bind_double(compiledStatement, 8, event.weight);
                sqlite3_bind_int(compiledStatement, 9, event.applicationID);
                sqlite3_bind_double(compiledStatement, 10, event.clientTime);
                sqlite3_bind_text(compiledStatement, 11, [event.bundleIdentifier cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);
                sqlite3_bind_text(compiledStatement, 12, [event.bundleVersion cStringUsingEncoding:NSUTF8StringEncoding], -1, SQLITE_TRANSIENT);				
                sqlite3_step(compiledStatement);
                [self debugLog:[NSString stringWithFormat:@"Database operation completed"]];
            }
            else {
                [self debugLog:[NSString stringWithFormat:@"Error in database operation %i", sqlite3_errcode(database)]];
            }
            sqlite3_finalize(compiledStatement);
        }
        sqlite3_close(database);
	}
}

#pragma mark - Tracing events helpers
- (void) traceBibliography {
    if (enableTracking) {
        [self traceEvent:EVENT_CODE_BIBLIOGRAPHY 
             description:EVENT_DESC_BIBLIOGRAPHY 
                    type:EVENT_INFO];
    }
}

- (void) traceShowPopup:(NSString*)document extended:(NSString*)extended {
    if (enableTracking) {
        [self traceEvent:EVENT_CODE_SHOW_POPUP 
             description:EVENT_DESC_SHOW_POPUP 
                    type:EVENT_INFO 
                extended:extended];
    }
}

- (void) traceClosePopup {
    if (enableTracking) {
        [self traceEvent:EVENT_CODE_CLOSE_POPUP 
             description:EVENT_DESC_CLOSE_POPUP 
                    type:EVENT_INFO];
    }
}

- (void) traceChangePage:(NSString*)current required:(NSString*)required {
    if (enableTracking) {
        [self traceEvent:EVENT_CODE_CHANGE_PAGE 
             description:EVENT_DESC_CHANGE_PAGE 
                    type:EVENT_INFO 
                  sender:current 
                extended:required];
    }
}

- (void) traceStartSession {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_START_SESSION 
             description:EVENT_DESC_START_SESSION 
                    type:EVENT_INFO];
	}
}

- (void) traceStopSession {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_STOP_SESSION 
             description:EVENT_DESC_STOP_SESSION 
                    type:EVENT_INFO];
	}
}

- (void) traceStart {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_START 
             description:EVENT_DESC_START 
                    type:EVENT_SYSTEM];
	}
}

- (void) traceDump {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_DUMP 
             description:EVENT_DESC_DUMP 
                    type:EVENT_SYSTEM];
	}
}

- (void) traceChangeSection:(NSString*)current required:(NSString*)required {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_CHANGE_SECTION 
             description:EVENT_DESC_CHANGE_SECTION 
                    type:EVENT_INFO 
                  sender:current 
                extended:required];
	}
}

- (void) traceCommand:(NSString*)command {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_COMMAND 
             description:EVENT_DESC_COMMAND 
                    type:EVENT_INFO 
                extended:command];
	}	
}

- (void) traceOpenPdf:(NSString*)document title:(NSString*)title {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_OPEN_PDF 
             description:EVENT_DESC_OPEN_PDF 
                    type:EVENT_INFO 
                  sender:document 
                extended:title];
	}
}

- (void) traceOpenWord:(NSString *)document title:(NSString *)title {
    if (enableTracking) {
		[self traceEvent:EVENT_CODE_OPEN_WORD 
             description:EVENT_DESC_OPEN_WORD 
                    type:EVENT_INFO 
                  sender:document 
                extended:title];
	}
}

- (void) traceOpenExcel:(NSString *)document title:(NSString *)title
{
    if (enableTracking) {
		[self traceEvent:EVENT_CODE_OPEN_EXCEL
             description:EVENT_DESC_OPEN_EXCEL
                    type:EVENT_INFO 
                  sender:document 
                extended:title];
	}    
}

- (void) traceOpenPowerPoint:(NSString *)document title:(NSString *)title {
    if (enableTracking) {
        [self traceEvent:EVENT_CODE_OPEN_WORD 
             description:EVENT_DESC_OPEN_POWERPOINT
                    type:EVENT_INFO 
                  sender:document 
                extended:title];
    }
}

- (void) traceClosePdf {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_CLOSE_PDF
             description:EVENT_DESC_CLOSE_PDF 
                    type:EVENT_INFO];
	}
}

- (void) traceCloseWord {
    if (enableTracking) {
		[self traceEvent:EVENT_CODE_CLOSE_WORD 
             description:EVENT_DESC_CLOSE_WORD
                    type:EVENT_INFO];
	}
}

- (void) traceCloseExcel {
    if (enableTracking) {
		[self traceEvent:EVENT_CODE_CLOSE_EXCEL 
             description:EVENT_DESC_CLOSE_EXCEL
                    type:EVENT_INFO];
	}
}

- (void) traceClosePowerPoint {
    if (enableTracking) {
		[self traceEvent:EVENT_CODE_CLOSE_POWERPOINT 
             description:EVENT_DESC_CLOSE_POWERPOINT 
                    type:EVENT_INFO];
	}
}

- (void) tracePlayVideo:(NSString*)video {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_PLAY_VIDEO 
             description:EVENT_DESC_PLAY_VIDEO 
                    type:EVENT_INFO 
                extended:video];
	}
}

- (void) traceRestore {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_RESTORE 
             description:EVENT_DESC_RESTORE
                    type:EVENT_SYSTEM];
	}
}

- (void) traceMinimize {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_MINIMIZE
             description:EVENT_DESC_MINIMIZE 
                    type:EVENT_SYSTEM];
	}
}

- (void) traceStop {
	if (enableTracking) {
		[self traceEvent:EVENT_CODE_STOP
             description:EVENT_DESC_STOP 
                    type:EVENT_SYSTEM];
	}
}

- (void) saveOldDB{
    long timestamp = [[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] longValue];
    NSString *new_databasePath = [NSString stringWithFormat:@"%@_%ld.db3",[databasePath substringWithRange:NSMakeRange(0, databasePath.length-4)], timestamp];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL success = [fileManager copyItemAtPath:databasePath toPath:new_databasePath error:nil];
    if(success)
        [self dropDatabase];
}

#pragma mark - Send data

- (void) postData {
    [self debugLog:[NSString stringWithFormat:@"Sending data to %@", storeDataServiceURL]];
    NSURL *url = [NSURL URLWithString:storeDataServiceURL];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:POST_DATA_TIMEOUT];
    [request setFile:databasePath forKey:@"dataFile"];
    [request setDelegate:self];
    [request startAsynchronous];
}

- (void) postRecursiveData {
    NSURL *url = [NSURL URLWithString:storeDataServiceURL];
    request = [ASIFormDataRequest requestWithURL:url];
    [request setTimeOutSeconds:120];
    [request setFile:[collect objectAtIndex:0] forKey:@"dataFile"];
    [request setDelegate:self];
    [request startAsynchronous];
}

-(void) postQueuedData {
    NSArray *filelist = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDir error: nil];
    collect = [[NSMutableArray alloc] init];
    NSString *sub = [DATABASE_NAME substringWithRange:NSMakeRange(0, [DATABASE_NAME length]-4)];
    sub = [NSString stringWithFormat:@"%@_",sub];
    for (int i = 0; i < [filelist count]; i++){
        NSString *fileName = [filelist objectAtIndex:i];
        if([fileName rangeOfString:sub].location != NSNotFound){
            NSString *path_db = [documentsDir stringByAppendingFormat:@"/%@", fileName];
            [collect addObject:path_db];
        }
    }
    if([collect count]>0) [self postRecursiveData];
}


- (void)requestFinished:(ASIHTTPRequest *)_request
{
	NSString *responseString = [_request responseString];
    [_request setDownloadProgressDelegate:nil];
    [_request clearDelegatesAndCancel];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"syncDone" object:responseString];
    
    if (collect && [collect count] > 0) {
        BOOL res = [[NSFileManager defaultManager] removeItemAtPath:[collect objectAtIndex:0] error:nil];
        if(res) {
            [collect removeObjectAtIndex:0];
            if([collect count]>0) [self postRecursiveData];
        }
    }
}

- (void)requestFailed:(ASIHTTPRequest *)_request
{
	NSError *error = [_request error];
	[self debugLog:[NSString stringWithFormat:@"Request failed. Error %@ (%i)", [error description], [error code]]];
    // [[NSNotificationCenter defaultCenter] postNotificationName:@"syncFail" object:self];
}

#pragma mark - Miscellaneous support functions

- (void) debugLog:(NSString*)message {
#ifdef DEBUG
    NSLog(@"TrackLib - %@", message);
#endif
}

@end
