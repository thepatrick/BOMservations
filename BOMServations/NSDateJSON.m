//
//  NSDate+JSON.m
//  Geonoter
//
//  Created by Patrick Quinn-Graham on 09-02-09.
//  Copyright 2009-2010 Patrick Quinn-Graham. All rights reserved.
//
//

#import "NSDateJSON.h"


@implementation NSDate (NSDateJSON)

+dateWithJSONString:(NSString*)jsonDate {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[inputFormatter setLocale: usLocale];
	[usLocale release];
	
	[inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDate *formattedDate = [inputFormatter dateFromString:jsonDate];
	
	[inputFormatter release];
	
	return formattedDate;
}


+dateWithSQLString:(NSString*)sqlDate {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[inputFormatter setLocale: usLocale];
	[usLocale release];
	
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSDate *formattedDate = [inputFormatter dateFromString:sqlDate];
	
	[inputFormatter release];
	
	return formattedDate;	
}


-(NSString*)jsonString {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[inputFormatter setLocale: usLocale];
	[usLocale release];
	
	[inputFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSString *outDate = [inputFormatter stringFromDate:self];
	[inputFormatter release];
	return outDate;
}

-(NSString*)sqlDateString {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	
	NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
	[inputFormatter setLocale: usLocale];
	[usLocale release];
	
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	NSString *outDate = [inputFormatter stringFromDate:self];
	
	[inputFormatter release];
	
	return outDate;	
}

@end
