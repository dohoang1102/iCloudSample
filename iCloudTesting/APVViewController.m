//
//  APVViewController.m
//  iCloudTesting
//
//  Created by Michal Tuszynski on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "APVViewController.h"
#import "FileController.h"
#import "APVUtilities.h"
#import "Timestamp.h"

#define kStorageIdentifier @"65E53C9T26.com.appvetica.icloud"

@interface APVViewController()

-(void)newFile;
-(void)metadataSearchCompleted:(NSNotification *)notification;
-(void)metadataSearchFailed:(NSNotification *)notification;
-(void)fileMovedToIcloud:(NSNotification *)notification;
-(void)fileFailedToMoveToICloud:(NSNotification *)notification;

@end

@implementation APVViewController

@synthesize tableView;
@synthesize filesArray, icloudFilesArray;
@synthesize icloudUrl;
@synthesize query;

#pragma mark - Memory managment

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

-(void)dealloc {
    
    [filesArray release];
    [icloudFilesArray release];
    [icloudUrl release];
    [query release];
    
    [super dealloc];
}

#pragma mark - NSNotificationCenter callbacks

-(void)metadataSearchCompleted:(NSNotification *)notification {
    
    
}


-(void)metadataSearchFailed:(NSNotification *)notification {
    
    
}

-(void)fileMovedToIcloud:(NSNotification *)notification {
    
    Timestamp *timestamp = (Timestamp *)[notification object];
    
    [APVUtilities spawnAlertWithMessage:[NSString stringWithFormat:@"File %@ is in your iCloud!", [timestamp localizedName]]];
    
    [self.icloudFilesArray addObject:timestamp];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow:[self.icloudFilesArray count] - 1 
                                           inSection:1];
    
    [self.tableView beginUpdates];
    
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] 
                          withRowAnimation:UITableViewRowAnimationMiddle];
    
    [self.tableView endUpdates];
    
}


-(void)fileFailedToMoveToICloud:(NSNotification *)notification {
    
    [APVUtilities spawnAlertWithMessage:@"Failed to move file to iCloud."];

}

#pragma mark - Button callbacks

-(IBAction)newFile:(id)sender {
 
    NSString *newFileName = [FileController createNewFile];
    
    if (newFileName != nil) {
        
        [self.filesArray addObject:newFileName];
        
        NSIndexPath *path = [NSIndexPath indexPathForRow:[self.filesArray count] - 1 
                                               inSection:0];
        
        [self.tableView beginUpdates];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:path] 
                              withRowAnimation:UITableViewRowAnimationMiddle];
        
        [self.tableView endUpdates];
        
    }
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.icloudUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:kStorageIdentifier];
    
    self.filesArray = [[[NSMutableArray alloc] init] autorelease];
    self.icloudFilesArray = [[[NSMutableArray alloc] init] autorelease];
    
    [filesArray addObjectsFromArray:[FileController getFilesFromDocuments]];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

#pragma mark - UITableViewDataSource methods

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (section == 0)
        return @"Local files";
    
    return @"iCloud files";
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (section == 0) 
        return [filesArray count];
    
    return [icloudFilesArray count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"CellIdentifier";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) 
        [[cell textLabel] setText:[filesArray objectAtIndex:indexPath.row]];
    else
        [[cell textLabel] setText:[[icloudFilesArray objectAtIndex:indexPath.row] absoluteString]];
    
    return cell;
}


#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    
}

@end
