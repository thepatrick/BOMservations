//
//  BOMServationsAppDelegate.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 20/02/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PersistStore;

@interface BOMServationsAppDelegate : NSObject <UIApplicationDelegate> {

}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;

@property (nonatomic, retain) PersistStore *store;

-(NSString*)getDocumentPath:(NSString*)file;

@end
