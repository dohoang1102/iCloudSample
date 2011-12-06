//
//  Timestamp.m
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
