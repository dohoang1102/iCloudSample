//
//  APVViewController.m
//  iCloudTesting
//
// Copyright 2011 by Michal Tuszynski
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
    
    //Iterate through all results, create documents from urls and reload the table view
    for (NSMetadataItem *item in [self.query results]) {
        
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
    
    //This predicate just fetches all files which have a file extension
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT %K.pathExtension = ''", NSMetadataItemFSNameKey];
    
    //Perform the search inside Documents iCloud scope
    self.query = [[[NSMetadataQuery alloc] init] autorelease];
    [self.query setSearchScopes:[NSArray arrayWithObjects:NSMetadataQueryUbiquitousDocumentsScope, nil]];
    [self.query setPredicate:predicate];
    [self.query startQuery];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //This method should be called as soon as possible after launching the app. It returns url pointing to the iCloud-monitored 
    //directory and enables our app to make changes there. If this method returns nil, then either you're 
    //running on simulator or the device doesn't have iCloud enabled
    
    self.icloudUrl = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:kStorageIdentifier];
    
    if (icloudUrl) {
        
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
    
    else {
        
        [APVUtilities spawnAlertWithMessage:@"Either you're running on simulator or don't have iCloud enabled. Check your settings and restart the app"];
        
    }
    
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
        [[cell detailTextLabel] setText:@""];
        
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
        
        //All iCloud operations should be done on seperate threads, or else it might hog to main thread
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(dispatchQueue, ^ {
            
            //Find the file inside out app sandbox
            NSString *filePath = (NSString *)[self.filesArray objectAtIndex:indexPath.row];
            filePath = [[FileController getDocumentsDirectory] stringByAppendingPathComponent:filePath];
            
            //Make the url out of it
            NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
            
            NSString *fileName = [NSString stringWithFormat:@"%@", [fileUrl lastPathComponent]];
            
            //This url points to the directory monitored by iCloud and our file is going to be copied there
            NSURL *storageUrl = [[self.icloudUrl URLByAppendingPathComponent:@"Documents"] URLByAppendingPathComponent:fileName];
            
            
            NSError *error;
            
            //Attempt to move the file from Documents directory to the iCloud directory
            if([[NSFileManager defaultManager] setUbiquitous:YES 
                                                itemAtURL:fileUrl 
                                           destinationURL:storageUrl 
                                                    error:&error]) {
            
            
                //Initiate a new document with the new file path
                Timestamp *timestamp = [[Timestamp alloc] initWithFileURL:storageUrl];
            
                //TableView logic
                [self.icloudFilesArray addObject:timestamp];
                [self.filesArray removeObjectAtIndex:indexPath.row];
            
                dispatch_async(dispatch_get_main_queue(), ^ {
                   
                    NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:[self.icloudFilesArray count] - 1 
                                                                   inSection:1];
                    
                    [self.tableView beginUpdates];
                    
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                          withRowAnimation:UITableViewRowAnimationMiddle];
                    
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] 
                                          withRowAnimation:UITableViewRowAnimationMiddle];
                    
                    [self.tableView endUpdates];

                    
                });
                            
                [timestamp closeWithCompletionHandler:nil];
            
                [timestamp release];

                
            }
            
            else {
                
            #ifdef DEBUG 
                NSLog(@"Failed to move file to iCloud: %@", [error localizedDescription]);
            #endif
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                   
                    [APVUtilities spawnAlertWithMessage:@"Something went wrong. The file failed to move to iCloud."];
                    
                });
                
            }
            
            
        });
        
               
    }
    
    else {
        
        dispatch_queue_t dispatchQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        dispatch_async(dispatchQueue, ^ {
           
            //Grab the document from array and find it's location inside iCloud storage
            Timestamp *timestamp = (Timestamp *)[self.icloudFilesArray objectAtIndex:indexPath.row];
            
            //The path inside app's Document directory where the file will be moved back
            NSString *targetPath = [[FileController getDocumentsDirectory] stringByAppendingPathComponent:[timestamp localizedName]];
            
            NSError *error;
            
            //Attempt to move the file back to Document directory
            if ([[NSFileManager defaultManager] setUbiquitous:NO 
                                                    itemAtURL:[timestamp fileURL] 
                                               destinationURL:[NSURL fileURLWithPath:targetPath] 
                                                        error:&error]) {
                
                
                //TableView logic
                [self.icloudFilesArray removeObjectAtIndex:indexPath.row];
                [self.filesArray addObject:[targetPath lastPathComponent]];
                
                dispatch_sync(dispatch_get_main_queue(), ^ {
                    
                    NSIndexPath *newPath = [NSIndexPath indexPathForRow:[self.filesArray count] - 1 
                                                              inSection:0];
                    
                    [self.tableView beginUpdates];
                    
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                                          withRowAnimation:UITableViewRowAnimationMiddle];
                    
                    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newPath] 
                                          withRowAnimation:UITableViewRowAnimationMiddle];
                    
                    [self.tableView endUpdates];
                    
                    
                });
                
            }
            
            else {
                
            #ifdef DEBUG
                NSLog(@"Failed to remove document from iCloud: %@", [error localizedDescription]);
            #endif
                
                dispatch_async(dispatch_get_main_queue(), ^ {
                    
                    [APVUtilities spawnAlertWithMessage:@"Failed to remove document from iCloud"];
                    
                });
                
            }

            
        });
    }
    
}

@end
