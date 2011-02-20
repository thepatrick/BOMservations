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
    
	SQLDatabase *db;
    
	BOOL dbIsOpen;
	
	NSLock *dbLock;
    
}

@property (nonatomic, retain) SQLDatabase *db;

+storeWithFile:(NSString*)file;

-(BOOL)openDatabase:(NSString *)fileName;
-(void)closeDatabase;

-(void)migrateFrom:(NSInteger)version;

@end
