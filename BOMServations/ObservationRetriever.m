//
//  ObservationRetriever.m
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 20/02/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import "ObservationRetriever.h"

#import "BOMServationsAppDelegate.h"
#import "PersistStore.h"
#import "JSON/JSON.h"
#import "SQLDatabase.h"

@implementation ObservationRetriever

- init {
    if((self == [super init])) {
        BOMServationsAppDelegate *del = (BOMServationsAppDelegate*)[[UIApplication sharedApplication] delegate];
        store = [del.store retain];
    }
    return self;
}

- (void)dealloc {
    [store release];
    [super dealloc];
}


- (void)fetchBOMObservations:(NSInteger)stationID {
    SQLDatabase *db = store.db;
    
    SQLRow *config = [[db performQueryWithFormat:@"SELECT * FROM stations WHERE id = %d", stationID] rowAtIndex:0];
    
    NSString *bom = [config stringForColumn:@"url"];
    NSURL *bomURL = [NSURL URLWithString:bom];
    NSError *err;
    NSString *observations = [NSString stringWithContentsOfURL:bomURL encoding:NSUTF8StringEncoding error:&err];
    if(err && observations == nil) {
        NSLog(@"Observations error! %@", err);
        return;
    }
    NSDictionary *weather = [observations JSONValue];
    if(!weather) {
        NSLog(@"Weather is null, I am a sad program :(");
        return;
    }
    NSArray *data = [[weather objectForKey:@"observations"] objectForKey:@"data"];
    
    
    [db performQueryWithFormat:@"DELETE FROM observations WHERE station_id = %d", stationID];

    //    20110220023000
    for(NSDictionary *ob in data) {
        [db performQueryWithFormat:@"INSERT INTO observations (sort_order, name, local_date_time, air_temp, apparent_t, rel_hum) VALUES (%@, '%@', '%@', '%@', '%@', %@)",
             [ob objectForKey:@"sort_order"],
             [SQLDatabase prepareStringForQuery:[ob objectForKey:@"name"]],
             [SQLDatabase prepareStringForQuery:[ob objectForKey:@"local_date_time"]],
             [ob objectForKey:@"air_temp"],
             [ob objectForKey:@"apparent_t"],
             [ob objectForKey:@"rel_hum"]
         ];
        NSLog(@"Added observation %@", ob);
    }
}


@end
