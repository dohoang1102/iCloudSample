//
//  FileController.h
//  iCloudTesting
//
//  Created by Michal Tuszynski on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileController : NSObject

+(NSString *)getDocumentsDirectory;
+(NSString *)createNewFile;
+(NSArray *)getFilesFromDocuments;

@end
