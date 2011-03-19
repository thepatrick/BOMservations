//
//  PersistStore.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 20/02/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SQLDatabase;

@interface PersistStore : NSObject {

	BOOL dbIsOpen;

}

@property (nonatomic, retain) SQLDatabase *db;
@property (nonatomic, assign) dispatch_queue_t queue;

+storeWithFile:(NSString*)file;

-(BOOL)openDatabase:(NSString *)fileName;
-(void)closeDatabase;

-(void)migrateFrom:(NSInteger)version;

-(NSInteger)choicesCount;

-(void)addStation:(long long)stationID complete:(void (^)(BOOL))block;
-(void)choices:(void (^)(NSArray*))block;

@end
