//
//  AddStation.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 16/03/11.
//  Copyright 2011 Sharkey Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StationsStore;
@class PersistStore;


@interface AddStation : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UINavigationBar *navBar;
@property (nonatomic, assign) StationsStore *stationStore;
@property (nonatomic, assign) PersistStore *persistStore;
@property (nonatomic, retain) NSMutableArray *resultNames;
@property (nonatomic, retain) NSMutableArray *resultIDs;

- (IBAction)cancelAddStation:(id)sender;


@end
