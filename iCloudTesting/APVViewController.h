//
//  APVViewController.h
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
