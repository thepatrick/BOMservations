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
		
		[db performQuery:@"CREATE TABLE observation (id INTEGER PRIMARY KEY, sort_order INTEGER, name STRING, local_date_time STRING, air_temp STRING, apparent_t STRING, rel_hum INTEGER)"];
                
//        "sort_order": 0,
//        "wmo": 94766,
//        "name": "Canterbury",
//        "history_product": "IDN60901",
//        "local_date_time": "20/01:30pm",
//        "local_date_time_full": "20110220133000",
//        "aifstime_utc": "20110220023000",
//        "air_temp": 29.1,
//        "apparent_t": 28.9,
//        "cloud": "-",
//        "cloud_base_m": null,
//        "cloud_oktas": null,
//        "cloud_type": "-",
//        "cloud_type_id": null,
//        "delta_t": 6.1,
//        "dewpt": 19.7,
//        "gust_kmh": 28,
//        "gust_kt": 15,
//        "lat": -33.9,
//        "lon": 151.1,
//        "press": null,
//        "press_msl": null,
//        "press_qnh": null,
//        "press_tend": "-",
//        "rain_trace": "0.0",
//        "rel_hum": 57,
//        "sea_state": "-",
//        "swell_dir_worded": "-",
//        "swell_height": "-",
//        "swell_length": "-",
//        "vis_km": "10",
//        "weather": "-",
//        "wind_dir": "SE",
//        "wind_spd_kmh": 20,
//        "wind_spd_kt": 11
		
		[db performQuery:@"UPDATE sync_status_and_version SET version = 1"];
    }
}

@end
