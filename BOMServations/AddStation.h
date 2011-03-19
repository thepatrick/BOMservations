//
//  AddStation.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 16/03/11.
//  Copyright 2011 Sharkey Media. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StationsStore;


@interface AddStation : UIViewController<UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource> {
}

@property (nonatomic, retain) IBOutlet UISearchBar *searchBar;
@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, assign) StationsStore *store;
@property (nonatomic, retain) NSMutableArray *resultNames;
@property (nonatomic, retain) NSMutableArray *resultIDs;

- (IBAction)cancelAddStation:(id)sender;


@end
