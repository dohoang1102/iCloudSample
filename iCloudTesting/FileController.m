//
//  FileController.m
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

#import "FileController.h"
#import "Timestamp.h"

@implementation FileController

+(NSString *)getDocumentsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    return [paths objectAtIndex:0];
    
}


+(NSString *)createNewFile {
    
    NSString *documentsPath = [FileController getDocumentsDirectory];
    NSDate *date = [NSDate date];
    
    NSString *filePath = [documentsPath stringByAppendingPathComponent:
                          [NSString stringWithFormat:@"%d.time", [date timeIntervalSince1970]]];
    
    [NSKeyedArchiver archiveRootObject:date toFile:filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [filePath lastPathComponent];
    }
    
    else {
        
        return nil;
    }
    
}

+(NSArray *)getFilesFromDocuments {
    
    NSString *documentsDirectory = [FileController getDocumentsDirectory];
    
    NSError *error;
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentsDirectory error:&error];
    
    if (contents != nil) {
        return contents;
    }
    
    else {
        
        NSLog(@"%@", [error localizedDescription]);
        return [NSArray array];
        
    }
}


@end
