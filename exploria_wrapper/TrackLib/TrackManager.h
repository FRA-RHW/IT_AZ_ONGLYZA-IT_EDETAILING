//
//  TrackManager.h
//  sample
//
//  Created by Gianluca Esposito on 21/06/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"
#import "EventObject.h"
#import "ASIFormDataRequest.h"

extern NSString * const DATABASE_NAME;
extern NSString * const REMOTE_DATA_STORE_SERVICE;

@interface TrackManager : NSObject {
	NSString *databasePath;
	sqlite3 *database;
	BOOL enableTracking;
	BOOL enableLocalization;
    ASIFormDataRequest *request;
    NSString *storeDataServiceURL;
    
    NSMutableArray *events;
    
    NSString * sending;
    NSMutableArray * collect;
    
    NSString * documentsDir;
}

@property (nonatomic, retain) NSString *databasePath;
@property BOOL enableTracking;
@property BOOL enableLocalization;
@property (nonatomic, retain) ASIFormDataRequest* request;
@property (nonatomic, retain) NSString* storeDataServiceURL;

@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSString * documentsDir;

+ (TrackManager *) sharedInstance;

- (void) initialize;
- (void) checkAndCreateDabase;
- (void) dropDatabase;
- (void) clearDatabase;
- (void) readEvents;
- (void) postData;
- (void) traceClient;

- (void) traceEvent:(EventObject*) event;
- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type;
- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type extended:(NSString*)extended;
- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type sender:(NSString*)sender;
- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type sender:(NSString*)sender extended:(NSString*)extended;
- (void) traceEvent:(NSString*)code description:(NSString*)description type:(int)type sender:(NSString*)sender extended:(NSString*)extended weight:(float)weight;

- (void) traceDebug:(EventObject*)event;
- (void) traceInfo:(EventObject*)event;
- (void) traceWarning:(EventObject*)event;
- (void) traceException:(EventObject*)event;
- (void) traceSystem:(EventObject*)event;
- (void) traceCustom:(EventObject*)event;

- (void) traceStartSession;
- (void) traceStopSession;
- (void) traceDump;

- (void) traceChangeSection:(NSString*)current required:(NSString*)required;
- (void) traceCommand:(NSString*)command;
- (void) traceOpenPdf:(NSString*)document title:(NSString*)title;
- (void) traceOpenWord:(NSString*)document title:(NSString*)title;
- (void) traceOpenExcel:(NSString*)document title:(NSString*)title;
- (void) traceOpenPowerPoint:(NSString*)document title:(NSString*)title;
- (void) traceClosePdf;
- (void) traceCloseWord;
- (void) traceCloseExcel;
- (void) traceClosePowerPoint;
- (void) tracePlayVideo:(NSString*)video;
- (void) traceStart;
- (void) traceStop;
- (void) traceMinimize;
- (void) traceRestore;
- (void) traceShowPopup:(NSString*)document extended:(NSString*)extended;
- (void) traceClosePopup;
- (void) traceBibliography;
- (void) traceChangePage:(NSString*)current required:(NSString*)required;

- (void) debugLog:(NSString*)message;

- (void) saveOldDB;
- (void) postRecursiveData;
- (void) postQueuedData;

@end
