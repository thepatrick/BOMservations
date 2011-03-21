//
//  StationsStore.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 16/03/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLDatabase;

@interface StationsStore : NSObject {
    
	BOOL dbIsOpen;
    
    NSMutableDictionary *stationCache;
    
}

@property (nonatomic, retain) SQLDatabase *db;
@property (nonatomic, assign) dispatch_queue_t queue;

+storeWithFile:(NSString*)file;

-(BOOL)openDatabase:(NSString *)fileName;
-(void)closeDatabase;

-(void)stationDetail:(long long)stationID callback:(void (^)(NSDictionary*))block;

@end
