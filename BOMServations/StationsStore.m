//
//  StationsStore.m
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 16/03/11.
//  Copyright 2011 Sharkey Media. All rights reserved.
//

#import "StationsStore.h"

#import "SQLDatabase.h"


@implementation StationsStore

@synthesize db, queue;

+storeWithFile:(NSString*)file
{
	StationsStore *store = [[[StationsStore alloc] init] autorelease];
	[store openDatabase:file];
	return store;
}

-init
{
	if((self = [super init])) {
		dbIsOpen = NO;
		dbLock = [[NSLock alloc] init];
        queue = dispatch_queue_create("bomservations.stationsstore", nil);
	}	
	return self;
}

-(void)dealloc {
	if(dbIsOpen) {
		[self closeDatabase];
	}
	[dbLock release];
    [db release];
    dispatch_release(queue);
    [super dealloc];
}

-(BOOL)openDatabase:(NSString *)fileName
{	
    if(![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        return NO;
    }
	self.db = [SQLDatabase databaseWithFile:fileName];
	[db open];
	dbIsOpen = YES;
	return YES;
}

-(void)closeDatabase {
	[db performQuery:@"COMMIT"];
	[db close];
    dbIsOpen = NO;
}

@end
