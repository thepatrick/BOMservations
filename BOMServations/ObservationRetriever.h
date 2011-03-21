//
//  ObservationRetriever.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 20/02/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BOMServationsAppDelegate;

@interface ObservationRetriever : NSObject {
}

@property (nonatomic, assign) BOMServationsAppDelegate *del;

- (void)fetchObservations:(long long)stationID callback:(void (^)())callback;

@end
