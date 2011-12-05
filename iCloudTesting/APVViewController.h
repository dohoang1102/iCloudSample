//
//  APVViewController.h
//  iCloudTesting
//
//  Created by Michal Tuszynski on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APVViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    IBOutlet UITableView *tableView;
    
    NSMutableArray *filesArray;
    NSMutableArray *icloudFilesArray;
    
    NSMetadataQuery *query;
    
    NSURL *icloudUrl;
}

-(IBAction)newFile:(id)sender;

@property (assign) UITableView *tableView;
@property (retain, nonatomic) NSMutableArray *filesArray;
@property (retain, nonatomic) NSMutableArray *icloudFilesArray;
@property (retain, nonatomic) NSURL *icloudUrl;
@property (retain, nonatomic) NSMetadataQuery *query;

@end
