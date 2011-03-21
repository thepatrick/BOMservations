//
//  SQLDatabase.m
//  SQLite Test
//
//  Created by Dustin Mierau on Tue Apr 02 2002.
//  Copyright (c) 2002 Blackhole Media, Inc. All rights reserved.
//

#import "SQLDatabase.h"
#import "SQLDatabasePrivate.h"

@implementation SQLDatabase

+ (id)databaseWithFile:(NSString*)inPath
{
	return [[[SQLDatabase alloc] initWithFile:inPath] autorelease];
}

#pragma mark -

- (id)initWithFile:(NSString*)inPath
{
	if( ![super init] )
		return nil;
	
	mPath = [inPath copy];
	mDatabase = NULL;
	
	return self;
}

- (id)init
{
	if( ![super init] )
		return nil;
	
	mPath = NULL;
	mDatabase = NULL;
	
	return self;
}

- (void)dealloc
{
	NSLog(@"SQLDatabase going away.");
	[self close];
	[mPath release];
	[super dealloc];
}

#pragma mark -

- (BOOL)open
{
	
    sqlite3_open( [mPath fileSystemRepresentation], &mDatabase );
	if( !mDatabase )
	{
		return NO;
	}
	
	return YES;
}

- (void)close
{
	if( !mDatabase )
		return;
	
	NSLog(@"Closing teh database");
	
	sqlite3_close( mDatabase );
	mDatabase = NULL;
}

#pragma mark -

+ (NSString*)prepareStringForQuery:(NSString*)inString
{
	NSMutableString*	string;
    if([inString respondsToSelector:@selector(stringValue)]) {
        inString = [(id)inString stringValue];
    }
    if((NSNull*)inString == [NSNull null]) {
        inString = nil;
    }
	NSRange				range = NSMakeRange( 0, [inString length] );
	NSRange				subRange;
	
	if(inString == nil) return nil; // just don't try.
	
	subRange = [inString rangeOfString:@"'" options:NSLiteralSearch range:range];
	if( subRange.location == NSNotFound )
		return inString;
	
	string = [NSMutableString stringWithString:inString];
	for( ; subRange.location != NSNotFound && range.length > 0;  )
	{
		subRange = [string rangeOfString:@"'" options:NSLiteralSearch range:range];
		if( subRange.location != NSNotFound )
			[string replaceCharactersInRange:subRange withString:@"''"];
		
		range.location = subRange.location + 2;
		range.length = ( [string length] < range.location ) ? 0 : ( [string length] - range.location );
	}
	
	return string;
}

- (SQLResult*)performQuery:(NSString*)inQuery
{
	SQLResult*	sqlResult = nil;
	char**		results;
	int			result;
	int			columns;
	int			rows;
	
	if( !mDatabase )
		return nil;

	result = sqlite3_get_table( mDatabase, [inQuery cStringUsingEncoding:NSStringEncodingConversionExternalRepresentation], &results, &rows, &columns, NULL );
	if( result != SQLITE_OK )
	{
		NSLog(@"SQLITE said %@ NOT ok! It was: %d", inQuery, result);
		sqlite3_free_table( results );
		return nil;
	}
	
	//NSLog(@"SQLITE said %@ ok!", inQuery);
	
	sqlResult = [[[SQLResult alloc] initWithTable:results rows:rows columns:columns] autorelease];
	if( !sqlResult )
		sqlite3_free_table( results );
	
	return sqlResult;
}

- (SQLResult*)performQueryWithFormat:(NSString*)inFormat, ...
{
	SQLResult*	sqlResult = nil;
	NSString*	query = nil;
	va_list		arguments;
	
	if( inFormat == nil )
		return nil;
	
	va_start( arguments, inFormat );
	
	query = [[NSString alloc] initWithFormat:inFormat arguments:arguments];
	sqlResult = [self performQuery:query];
	[query release];
	
	va_end( arguments );
	
	return sqlResult;
}

@end
