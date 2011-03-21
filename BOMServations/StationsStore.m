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
		queue = dispatch_queue_create("bomservations.stationsstore", nil);
        stationCache = [[NSMutableDictionary dictionaryWithCapacity:10] retain];
	}	
	return self;
}

-(void)dealloc {
	if(dbIsOpen) {
		[self closeDatabase];
	}
	[db release];
    [stationCache release];
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

-(void)stationDetail:(long long)stationID callback:(void (^)(NSDictionary*))block {
    NSNumber *stationNumber = [NSNumber numberWithLongLong:stationID];
    NSDictionary *stationCacheObject = [stationCache objectForKey:stationNumber];
    if(stationCacheObject) {
        block(stationCacheObject);
        return;
    }
    dispatch_queue_t current_queue = dispatch_get_current_queue();
    dispatch_async(dispatch_get_main_queue(), ^{
        SQLResult *res = [db performQueryWithFormat:@"SELECT * FROM stations WHERE id = %@", stationNumber];
        SQLRow *row = [res rowAtIndex:0];
        NSDictionary *stationCacheObject = nil;
        if(row) {
            NSString *state = [row stringForColumn:@"state"];
            NSString *name = [row stringForColumn:@"name"];
            NSString *url = [row stringForColumn:@"url"];
            stationCacheObject = [NSDictionary dictionaryWithObjectsAndKeys:state, @"state", name, @"name", url, @"url", stationNumber, @"id", nil];
            [stationCache setObject:stationCacheObject forKey:stationNumber];
        }
        dispatch_async(current_queue, ^{
            block(stationCacheObject);
        });
    });
}
@end
