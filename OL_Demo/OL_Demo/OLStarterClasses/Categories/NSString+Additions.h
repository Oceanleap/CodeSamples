//
//  NSString+Additions.h
//  oceanleap
//
//  Created by Gagandeep Singh on 12/28/13.
//  Copyright (c) 2013 Oceanleap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Additions)

+ (BOOL)isNilOrEmptyString:(NSString *)string;
- (BOOL)isNilOrEmpty;

@end
