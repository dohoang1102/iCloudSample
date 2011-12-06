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

-(void)fetchDocumentsFromCloud;
-(void)metadataSearchCompleted:(NSNotification *)notification;
-(void)documentStateChanged:(NSNotification *)notification;

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

-(void)documentStateChanged:(NSNotification *)notification {
    
    Timestamp *timestamp = (Timestamp *)[notification object];
    
    NSUInteger index = [self.icloudFilesArray indexOfObject:timestamp];
    
    if (index != NSNotFound) {
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:1];
        
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                              withRowAnimation:UITableViewRowAnimationMiddle];
    }
    
}

-(void)metadataSearchCompleted:(NSNotification *)notification {
    
    [self.icloudFilesArray removeAllObjects];
    
    NSMetadataQuery *newQuery = [notification object];
    
    [newQuery disableUpdates];
    [newQuery stopQuery];
    
    for (NSMetadataItem *item in [newQuery results]) {
        
        NSURL *fileUrl = [item valueForAttribute:NSMetadataItemURLKey];
        
        Timestamp *timestamp = [[Timestamp alloc] initWithFileURL:fileUrl];
        [self.icloudFilesArray addObject:timestamp];
        
        [timestamp release];
    }
    
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    
    [self.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationMiddle];
}


#pragma mark - IBActions

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

#pragma mark - Helper methods

-(void)fetchDocumentsFromCloud {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT %K.pathExtension = ''", NSMetadataItemFSNameKey];
    
    self.query = [[[NSMetadataQuery alloc] init] autorelease];
    [self.query setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
    [self.query setPredicate:predicate];
    [self.query startQuery];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(metadataSearchCompleted:)
                                                 name:NSMetadataQueryDidFinishGatheringNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(metadataSearchCompleted:)
                                                 name:NSMetadataQueryDidUpdateNotification 
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(documentStateChanged:) 
                                                 name:UIDocumentStateChangedNotification 
                                               object:nil];
    
    [self fetchDocumentsFromCloud];
    
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.tableView = nil;
    
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
        
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier] autorelease];
    }
    
    if (indexPath.section == 0) {
     
        [[cell textLabel] setText:[self.filesArray objectAtIndex:indexPath.row]];
        
    }
    else {
        
        Timestamp *timestamp = (Timestamp *)[self.icloudFilesArray objectAtIndex:indexPath.row];
        
        NSString *documentStatus = nil;
        
        switch ([timestamp documentState]) {
                
            case UIDocumentStateNormal:
                
                documentStatus = @"Normal";
                
                break;
                
            case UIDocumentStateClosed:
                
                documentStatus = @"Closed";
                
                break;
                
            case UIDocumentStateInConflict:
                
                documentStatus = @"Conflict detected";
                
                break;
                
            case UIDocumentStateSavingError:
                
                documentStatus = @"Saving error";
                
                break;
                
            case UIDocumentStateEditingDisabled:
                
                documentStatus = @"Editing disabled";
                
                break;
                
                
        }
        
        
        [[cell textLabel] setText:[timestamp localizedName]];
        [[cell detailTextLabel] setText:documentStatus];
        
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate methods

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        
        NSString *filePath = (NSString *)[self.filesArray objectAtIndex:indexPath.row];
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:filePath])
            filePath = [[FileController getDocumentsDirectory] stringByAppendingPathComponent:filePath];
        
        
        NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
        
        NSString *fileName = [NSString stringWithFormat:@"%@", [fileUrl lastPathComponent]];
        NSURL *storageUrl = [[self.icloudUrl URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] setUbiquitous:YES 
                                            itemAtURL:fileUrl 
                                       destinationURL:storageUrl 
                                                error:nil];
        

        Timestamp *timestamp = [[Timestamp alloc] initWithFileURL:storageUrl];
                
        [self.icloudFilesArray addObject:timestamp];
        [self.filesArray removeObjectAtIndex:indexPath.row];
        
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.icloudFilesArray count] - 1 
                                                       inSection:1];
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                              withRowAnimation:UITableViewRowAnimationMiddle];
        
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                              withRowAnimation:UITableViewRowAnimationMiddle];
        
        [self.tableView endUpdates];
        
        [timestamp closeWithCompletionHandler:nil];
        
        [timestamp release];
        
    }
    
}

@end
