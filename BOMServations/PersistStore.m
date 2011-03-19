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

@synthesize db;

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
		dbLock = [[NSLock alloc] init];
	}	
	return self;
}

-(void)dealloc {
	if(dbIsOpen) {
		[self closeDatabase];
	}
	[dbLock release];
    [db release];
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
        
		[db performQuery:@"CREATE TABLE observations (id INTEGER PRIMARY KEY, choice_id INTEGER, sort_order INTEGER, name STRING, local_date_time STRING, air_temp NUMBER, apparent_t NUMBER, rel_hum INTEGER, aifstime_utc DATETIME, cloud STRING, cloud_base_m STRING, cloud_oktas STRING, cloud_type STRING cloud_type_id INTEGER, delta_t NUMBER, dewpt NUMBER, gust_kmh NUMBER, gust_kt NUMBER, lat NUMBER lon NUMBER, press STRING, press_msl STRING, press_qnh STRING, press_tend STRING, rain_trace STRING, sea_state STRING, swell_dir_worded STRING, swell_height STRING, swell_length STRING, vis_km NUMBER, weather STRING, wind_dir STRING, wind_spd_kmh NUMBER, wind_spd_kt NUMBER)"];

		[db performQuery:@"UPDATE sync_status_and_version SET version = 1"];
    }
}

-(NSInteger)choicesCount {
    SQLResult *res = [db performQuery:@"SELECT count(*) FROM choices"];
    return [[res rowAtIndex:0] integerForColumnAtIndex:0];
}

@end
