//
//  NSString+Additions.m
//  oceanleap
//
//  Created by Gagandeep Singh on 12/28/13.
//  Copyright (c) 2013 Oceanleap, Inc. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (BOOL)isNilOrEmptyString:(NSString *)string {
    return string == nil || string.length == 0;
}

- (BOOL)isNilOrEmpty
{
    return [NSString isNilOrEmptyString:self];
}

@end
