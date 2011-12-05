//
//  Timestamp.m
//  iCloudTesting
//
//  Created by Michal Tuszynski on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Timestamp.h"

@implementation Timestamp

@synthesize date;


#pragma mark - UIDocument overriden methods

-(id)initWithFileURL:(NSURL *)url {
    
    self = [super initWithFileURL:url];
    
    if (self) {
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.date = (NSDate *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    return self;
}

-(NSString *)localizedName {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterFullStyle];
    [dateFormatter setTimeStyle:NSDateFormatterFullStyle];
    
    NSString *name = [dateFormatter stringFromDate:date];
    
    [dateFormatter release];
    
    return name;
}

-(NSString *)fileType {
    
    return @"time";
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
        
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.date];
    

    return data;
}


- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
 
    if ([contents isKindOfClass:[NSData class]]) {
        
        self.date = (NSDate *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)contents];
        
        return YES;
    }
    
    return NO;
}

#pragma mark - Memory managment

-(void)dealloc {
    
    [date release];
    
    [super dealloc];
}

@end
