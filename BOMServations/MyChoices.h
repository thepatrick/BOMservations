//
//  MyChoices.h
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 16/03/11.
//  Copyright 2011 Sharkey Media. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MyChoices : UITableViewController {
    
    UIBarButtonItem *addStation;
}

@property (nonatomic, retain) IBOutlet UIBarButtonItem *addStation;

- (IBAction)addStation:(id)sender;

@end
