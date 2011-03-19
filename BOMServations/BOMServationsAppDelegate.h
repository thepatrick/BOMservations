//
//  BOMServationsAppDelegate.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 20/02/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;
@class StationsStore;

@interface BOMServationsAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) PersistStore *store;
@property (nonatomic, retain) StationsStore *stations;

+(BOMServationsAppDelegate*)shared;

-(NSString*)getDocumentPath:(NSString*)file;

@end
