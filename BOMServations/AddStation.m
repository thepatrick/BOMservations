//
//  AddStation.m
//  BOMServations
//
//  Created by Patrick Quinn-Graham on 16/03/11.
//  Copyright 2011 Patrick Quinn-Graham. All rights reserved.
//

#import "AddStation.h"
#import "BOMServationsAppDelegate.h"
#import "StationsStore.h"
#import "PersistStore.h"
#import "SQLDatabase.h"


@implementation AddStation

@synthesize stationStore, persistStore, resultNames, resultIDs;
@synthesize navBar=_navBar, searchBar=_searchBar, tableView=_tableView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.resultIDs = [NSMutableArray arrayWithCapacity:10];
        self.resultNames = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)dealloc
{
    [resultIDs release];
    [resultNames release];
    [_searchBar release];
    [_tableView release];
    [_navBar release];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.stationStore = [[BOMServationsAppDelegate shared] stations];
    self.persistStore = [[BOMServationsAppDelegate shared] store];
    
}


- (void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];    
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidUnload
{
    [self setSearchBar:nil];
    [self setTableView:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)cancelAddStation:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.searchBar becomeFirstResponder];
}

#pragma mark -
#pragma mark Table view datasource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.resultNames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    
    cell.textLabel.text = [self.resultNames objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    long long resultID = [[resultIDs objectAtIndex:indexPath.row] longLongValue];
    NSLog(@"They picked %@, which has ID %lld", [resultNames objectAtIndex:indexPath.row], resultID);
    [self.persistStore addStation:resultID complete:^(BOOL success) {
        if(!success) {
            NSLog(@"Couldn't add it :(");
            return;
        }
        [self cancelAddStation:nil];
    }];
}

#pragma mark - Keyboard show/hide

- (void)keyboardWillShow:(NSNotification*)notification {
    [UIView beginAnimations:@"keyboardWillShow" context:nil];
    NSValue *endPoint = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame;
    [endPoint getValue:&keyboardFrame];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - (keyboardFrame.size.height + self.searchBar.frame.size.height + self.navBar.frame.size.height);
    self.tableView.frame = tableFrame;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    [UIView beginAnimations:@"keyboardWillHide" context:nil];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - (self.searchBar.frame.size.height + self.navBar.frame.size.height);
    self.tableView.frame = tableFrame;
    [UIView commitAnimations];
}

#pragma mark - Search bar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    dispatch_queue_t queue = self.stationStore.queue;
    if(!queue) {
        return;
    }
    dispatch_async(queue, ^{
        NSString *str = [NSString stringWithFormat:@"SELECT * FROM stations WHERE name LIKE \"%%%@%%\" OR state LIKE \"%%%@%%\"", searchText, searchText];
        
        SQLResult *res = [self.stationStore.db performQuery:str];
        
        NSInteger rowCount = [res rowCount];

        NSMutableArray *replacementIDs;
        NSMutableArray *replacementNames;

        if(rowCount < 1 || rowCount > 20) {
            replacementIDs = [NSMutableArray array];
            replacementNames = [NSMutableArray array];
        } else {
            replacementIDs = [NSMutableArray arrayWithCapacity:rowCount];
            replacementNames = [NSMutableArray arrayWithCapacity:rowCount];
            NSEnumerator *myenumerator = [res rowEnumerator];
            NSString *state;
            NSString *city;
            SQLRow *row = [myenumerator nextObject];
            while(row) {
                NSNumber *rowID = [row numberForColumn:@"id"];
                NSLog(@"Found row (%@), %@", rowID, row);
                [replacementIDs addObject:rowID];
                state = [row stringForColumnNoCopy:@"state"];
                city = [row stringForColumnNoCopy:@"name"];
                [replacementNames addObject:[NSString stringWithFormat:@"%@, %@", city, state]];
                row = [myenumerator nextObject];
            }
        }
                
        dispatch_async(dispatch_get_main_queue(), ^{
            self.resultIDs = replacementIDs;
            self.resultNames = replacementNames;
            [self.tableView reloadData]; 
        });
    });
}

@end
