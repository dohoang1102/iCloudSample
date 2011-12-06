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

-(id)initWithFileURL:(NSURL *)url {
    
    self = [super initWithFileURL:url];
    
    if (self) {
        
        NSData *data = [NSData dataWithContentsOfURL:url];
        self.date = (NSDate *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
        
    }
    
    return self;
}

-(NSString *)localizedName {
    
    return [NSString stringWithFormat:@"%d", [date timeIntervalSince1970]];
}

- (id)contentsForType:(NSString *)typeName error:(NSError **)outError {
        
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.date];
    

    return data;
}


- (BOOL)loadFromContents:(id)contents ofType:(NSString *)typeName error:(NSError **)outError {
 
        
    self.date = (NSDate *)[NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)contents];
        
    return YES;
    
}

#pragma mark - Memory managment

-(void)dealloc {
    
    [date release];
    
    [super dealloc];
}

@end
