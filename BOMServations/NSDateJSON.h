//
//  NSDate+JSON.h
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-02-09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//
//

@interface NSDate (NSDateJSON)

+dateWithJSONString:(NSString*)jsonDate;
+dateWithSQLString:(NSString*)sqlDate;

-(NSString*)jsonString;
-(NSString*)sqlDateString;

@end
