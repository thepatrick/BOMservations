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
#import "StationsStore.h"
#import "JSON/JSON.h"
#import "SQLDatabase.h"
#import "NSDateJSON.h"

@implementation ObservationRetriever

@synthesize del=_del;

- init {
    if((self == [super init])) {
        self.del = [BOMServationsAppDelegate shared];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)fetchObservations:(long long)stationID callback:(void (^)())callback {
    dispatch_queue_t current_queue = dispatch_get_current_queue();
    [self.del.stations stationDetail:stationID callback:^(NSDictionary* stationDetail){
        NSString *bom = [stationDetail objectForKey:@"url"];

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
        
        [self.del.store choiceIDForStationID:stationID callback:^(NSInteger choiceID){
            dispatch_async(self.del.store.queue, ^{
                SQLDatabase *db = self.del.store.db;
                [db performQueryWithFormat:@"DELETE FROM observations WHERE choice_id = %d", choiceID];

                NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
                
                NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
                [inputFormatter setLocale: usLocale];
                [usLocale release];
                [inputFormatter setDateFormat:@"yyyyMMddHHmmss"];
                [inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                
                for(NSDictionary *ob in data) {
                    NSString *aifstime = [[inputFormatter dateFromString:[ob objectForKey:@"aifstime_utc"]] sqlDateString];
                    NSLog(@"local: %@, aifstime: %@", [ob objectForKey:@"local_date_time"], aifstime);
                    [db performQueryWithFormat:@"INSERT INTO observations (choice_id, sort_order, name, local_date_time, air_temp, apparent_t, rel_hum, aifstime_utc, cloud, cloud_base_m, cloud_oktas, cloud_type, cloud_type_id, delta_t, dewpt, gust_kmh, gust_kt, lat, lon, press, press_msl, press_qnh, press_tend, rain_trace, sea_state, swell_dir_worded, swell_height, swell_length, vis_km, weather, wind_dir, wind_spd_kmh, wind_spd_kt) VALUES (%d, '%@', '%@', '%@', '%@', '%@', %@, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",
                     choiceID,
                     [ob objectForKey:@"sort_order"],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"name"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"local_date_time"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"air_temp"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"apparent_t"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"rel_hum"]],
                     [SQLDatabase prepareStringForQuery:aifstime], 
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"cloud"]], 
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"cloud_base_m"]], 
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"cloud_oktas"]], 
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"cloud_type"]], 
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"cloud_type_id"]], 
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"delta_t"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"dewpt"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"gust_kmh"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"gust_kt"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"lat"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"lon"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"press"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"press_msl"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"press_qnh"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"press_tend"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"rain_trace"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"sea_state"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"swell_dir_worded"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"swell_height"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"swell_length"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"vis_km"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"weather"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"wind_dir"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"wind_spd_kmh"]],
                     [SQLDatabase prepareStringForQuery:[ob objectForKey:@"wind_spd_kt"]]
                     ];
                }
                
                [inputFormatter release];
                
                dispatch_async(current_queue, ^{
                    callback();
                });
            });                    
        }];
        
    }];
}

@end
