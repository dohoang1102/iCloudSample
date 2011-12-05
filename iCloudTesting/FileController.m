//
//  FileController.m
//  iCloudTesting
//
//  Created by Michal Tuszynski on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

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
    
    NSString *filePath = [documentsPath stringByAppendingPathExtension:[NSString stringWithFormat:@"%d", [date timeIntervalSince1970]]];
    
    [NSKeyedArchiver archiveRootObject:date toFile:filePath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return filePath;
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




+(void)storeFileInICloud:(NSString *)fileName withStorageUrl:(NSURL *)storageUrl {
    
    NSString *documentsDirectory = [FileController getDocumentsDirectory];
    NSURL *fileUrl = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathExtension:fileName]];
    
    Timestamp *timestamp = [[Timestamp alloc] initWithFileURL:fileUrl];
    
    [timestamp saveToURL:[storageUrl URLByAppendingPathComponent:fileName] 
        forSaveOperation:UIDocumentSaveForCreating 
       completionHandler:^ (BOOL success) {
           
           NSNotification *notification = nil;
           
           if (success) {
               
               notification = [NSNotification notificationWithName:kFileMovedToICloudNotification object:timestamp];
           }
           
           else {
               
               notification = [NSNotification notificationWithName:kFileFailedMovingToICloudNotification object:nil];
               
           }
           
           [[NSNotificationCenter defaultCenter] postNotification:notification];
           
       }];

    
}

@end
