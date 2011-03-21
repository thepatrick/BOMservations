//
//  PersistStore.m
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 20/02/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import "PersistStore.h"

#import "SQLDatabase.h"

@implementation PersistStore

@synthesize db, queue;

+storeWithFile:(NSString*)file
{
	PersistStore *store = [[[PersistStore alloc] init] autorelease];
	[store openDatabase:file];
	return store;
}

-init
{
	if((self = [super init])) {
		dbIsOpen = NO;
        queue = dispatch_queue_create("bomservations.userstore", nil);
	}	
	return self;
}

-(void)dealloc {
	if(dbIsOpen) {
		[self closeDatabase];
	}
    [db release];
    dispatch_release(queue);
    [super dealloc];
}

-(BOOL)openDatabase:(NSString *)fileName
{	
	BOOL newFile = ![[NSFileManager defaultManager] fileExistsAtPath:fileName];
	self.db = [SQLDatabase databaseWithFile:fileName];
	[db open];
	dbIsOpen = YES;
    
	if(newFile) {
		NSLog(@"First run, create basic file format");
		[db performQuery:@"CREATE TABLE sync_status_and_version (last_sync datetime, version integer)"];
		[db performQuery:@"INSERT INTO sync_status_and_version VALUES (NULL, 0)"];
	}
    
	SQLResult *res = [db performQuery:@"SELECT last_sync, version FROM sync_status_and_version;"];
	SQLRow *row = [res rowAtIndex:0];
	
	int theVersion = [row integerForColumn:@"version"];
	
	NSLog(@"Database: Version: '%d'", theVersion);
	
	[self migrateFrom:theVersion];
	
	return YES;
}
 
-(void)closeDatabase {
	[db performQuery:@"COMMIT"];
	[db close];
    dbIsOpen = NO;
}

-(void)migrateFrom:(NSInteger)version {
	if(version < 1) {
		NSLog(@"Database migrating to v1...");
        
        [db performQuery:@"CREATE TABLE choices (id INTEGER PRIMARY KEY, sort_order INTEGER, station_id INTEGER)"];
        
		[db performQuery:@"CREATE TABLE observations (id INTEGER PRIMARY KEY, choice_id INTEGER, sort_order INTEGER, name STRING, local_date_time STRING, air_temp NUMBER, apparent_t NUMBER, rel_hum INTEGER, aifstime_utc DATETIME, cloud STRING, cloud_base_m STRING, cloud_oktas STRING, cloud_type STRING, cloud_type_id INTEGER, delta_t NUMBER, dewpt NUMBER, gust_kmh NUMBER, gust_kt NUMBER, lat NUMBER, lon NUMBER, press STRING, press_msl STRING, press_qnh STRING, press_tend STRING, rain_trace STRING, sea_state STRING, swell_dir_worded STRING, swell_height STRING, swell_length STRING, vis_km NUMBER, weather STRING, wind_dir STRING, wind_spd_kmh NUMBER, wind_spd_kt NUMBER)"];

		[db performQuery:@"UPDATE sync_status_and_version SET version = 1"];
    }
}

-(NSInteger)choicesCount {
    SQLResult *res = [db performQuery:@"SELECT count(*) FROM choices"];
    return [[res rowAtIndex:0] integerForColumnAtIndex:0];
}

-(void)addStation:(long long)stationID complete:(void (^)(BOOL))block {
    dispatch_queue_t current_queue = dispatch_get_current_queue();
    dispatch_async(queue, ^{
        SQLResult *res = [db performQueryWithFormat:@"INSERT INTO choices (sort_order, station_id) VALUES (%d, %lld)", 0, stationID];
        dispatch_async(current_queue, ^{
            block(res != nil);  
        });
    });
}

-(void)choices:(void (^)(NSArray*))block {
    dispatch_queue_t current_queue = dispatch_get_current_queue();
    dispatch_async(queue, ^{
        SQLResult *res = [db performQueryWithFormat:@"SELECT id, station_id FROM choices ORDER BY sort_order ASC"];
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:[res rowCount]];
        for(SQLRow *row in [res rowEnumerator]) {
            NSNumber *choiceID = [NSNumber numberWithInteger:[row integerForColumn:@"id"]];
            NSNumber *stationID = [row numberForColumn:@"station_id"];
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:choiceID, @"id", stationID, @"station_id", nil];
            [arr addObject:dict];
        }
        dispatch_async(current_queue, ^{
            block(arr);  
        });
    });
}


-(void)choiceIDForStationID:(long long)stationID callback:(void (^)(NSInteger))block {
    dispatch_queue_t current_queue = dispatch_get_current_queue();
    dispatch_async(queue, ^{
        SQLResult *res = [db performQueryWithFormat:@"SELECT id FROM choices WHERE station_id = %lld", stationID];
        NSInteger choiceID = [[res rowAtIndex:0] integerForColumn:@"id"];
        dispatch_async(current_queue, ^{
            block(choiceID);  
        });
    });
}

-(void)stationIDForChoiceID:(NSInteger)choiceID callback:(void (^)(long long))block {
    dispatch_queue_t current_queue = dispatch_get_current_queue();
    dispatch_async(queue, ^{
        SQLResult *res = [db performQueryWithFormat:@"SELECT station_id FROM choices WHERE id = %d", choiceID];
        long long stationID = [[[res rowAtIndex:0] numberForColumn:@"station_id"] longLongValue];
        dispatch_async(current_queue, ^{
            block(stationID);  
        });
    });    
}


@end
