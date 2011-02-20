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


- (void)fetchBOMObservations {
//    NSString *bom = @"http://10.0.100.29/~patrick/IDN60901.94766.json";
    NSString *bom = @"http://www.bom.gov.au/fwo/IDN60901/IDN60901.94766.json";
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
    
    SQLDatabase *db = store.db;
    
    [db performQueryWithFormat:@"DELETE FROM observation"];
    
    for(NSDictionary *ob in data) {
        [db performQueryWithFormat:@"INSERT INTO observation (sort_order, name, local_date_time, air_temp, apparent_t, rel_hum) VALUES (%@, '%@', '%@', '%@', '%@', %@)",
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
