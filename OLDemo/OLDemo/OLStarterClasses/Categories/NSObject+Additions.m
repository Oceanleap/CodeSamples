//
//  NSObject+Additions.m
//  oceanleap
//
//  Created by Gagandeep Singh on 12/24/13.
//  Copyright (c) 2013 Oceanleap, Inc. All rights reserved.
//

#import "NSObject+Additions.h"

@implementation NSObject (Additions)

+ (id)nullSafeConversion:(id)source {
    if (source == nil || [source isKindOfClass:[NSNull class]]) {
        return nil;
    } else {
        return source;
    }
}

@end
