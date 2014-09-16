//
//  OLUser.m
//  oceanleap
//
//  Created by Gagandeep Singh on 12/24/13.
//  Copyright (c) 2013 Oceanleap, Inc. All rights reserved.
//

#import "OLUser.h"
#import "NSObject+Additions.h"
#import "NSString+Additions.h"

@implementation OLUser

+(instancetype) createUserFromDictionary:(NSDictionary *)dictionary
{
    OLUser* user = [[OLUser alloc] init];
    if ([NSObject nullSafeConversion:dictionary]) {
        user.dateJoined = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"date_joined"] doubleValue]];
        user.authorization = [NSObject nullSafeConversion:dictionary[@"authorization"]];
        user.email = dictionary[@"email"];
        user.firstName = dictionary[@"first_name"];
        user.userId = dictionary[@"id"];
        user.isActive = dictionary[@"is_active"];
        user.isStaff = dictionary[@"is_staff"];
        user.isSuperuser = dictionary[@"is_superuser"];
        user.lastLogin = [NSObject nullSafeConversion:dictionary[@"last_login"]];
        user.lastName = dictionary[@"last_name"];
        user.resourceURI = dictionary[@"resource_uri"];
        user.gender = [NSObject nullSafeConversion:dictionary[@"gender"]];
        user.height = [NSObject nullSafeConversion:dictionary[@"height"]];
        user.stepLength = [NSObject nullSafeConversion:dictionary[@"step_length"]];
        user.token = dictionary[@"token"];
        user.username = dictionary[@"username"];
        user.avatar = [NSObject nullSafeConversion:dictionary[@"avatar"]];
        user.avgSteps = [NSObject nullSafeConversion:dictionary[@"7day_steps_avg"]];
        //user.strideLength = [NSObject nullSafeConversion:[dictionary objectForKey:@"avatar"]];
        user.deviceName = dictionary[@"device_name"];
		if (dictionary[@"time_since_sync"] != (id)[NSNull null]) {
			user.timeSinceSync = dictionary[@"time_since_sync"];
		} else {
			user.timeSinceSync = @"Unknown";
		}
		if (dictionary[@"last_sync_time"] != (id)[NSNull null]) {
			user.lastSynced = [NSDate dateWithTimeIntervalSince1970:[dictionary[@"last_sync_time"] doubleValue]];
		} else {
			user.lastSynced = nil;
		}
        user.totalFitPoint = dictionary[@"total_fit_points"];
    }
    return user;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self)
    {
        self.authorization = [aDecoder decodeObjectForKey:@"authorization"];
        self.dateJoined = [aDecoder decodeObjectForKey:@"dateJoined"];
        self.email = [aDecoder decodeObjectForKey:@"email"];
        self.firstName = [aDecoder decodeObjectForKey:@"firstName"];
        self.userId = [aDecoder decodeObjectForKey:@"userId"];
        self.isActive = [aDecoder decodeObjectForKey:@"isActive"];
        self.isStaff = [aDecoder decodeObjectForKey:@"isStaff"];
        self.isSuperuser = [aDecoder decodeObjectForKey:@"isSuperuser"];
        self.lastLogin = [aDecoder decodeObjectForKey:@"lastLogin"];
        self.lastName = [aDecoder decodeObjectForKey:@"lastName"];
        self.resourceURI = [aDecoder decodeObjectForKey:@"resourceURI"];
        self.token = [aDecoder decodeObjectForKey:@"token"];
        self.username = [aDecoder decodeObjectForKey:@"username"];
        self.avatar = [aDecoder decodeObjectForKey:@"avatar"];
        self.timeSinceSync = [aDecoder decodeObjectForKey:@"time_since_sync"];
        self.lastSynced = [aDecoder decodeObjectForKey:@"last_sync_time"];
        self.gender = [aDecoder decodeObjectForKey:@"gender"];
        self.height = [aDecoder decodeObjectForKey:@"height"];
        self.stepLength = [aDecoder decodeObjectForKey:@"step_length"];
        self.avgSteps = [aDecoder decodeObjectForKey:@"7day_steps_avg"];

    }

    return self;
}

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.authorization forKey:@"authorization"];
    [aCoder encodeObject:self.dateJoined forKey:@"dateJoined"];
    [aCoder encodeObject:self.email forKey:@"email"];
    [aCoder encodeObject:self.firstName forKey:@"firstName"];
    [aCoder encodeObject:self.userId forKey:@"userId"];
    [aCoder encodeObject:self.isActive forKey:@"isActive"];
    [aCoder encodeObject:self.isStaff forKey:@"isStaff"];
    [aCoder encodeObject:self.isSuperuser forKey:@"isSuperUser"];
    [aCoder encodeObject:self.lastLogin forKey:@"lastLogin"];
    [aCoder encodeObject:self.lastName forKey:@"lastName"];
    [aCoder encodeObject:self.resourceURI forKey:@"resourceURI"];
    [aCoder encodeObject:self.token forKey:@"token"];
    [aCoder encodeObject:self.username forKey:@"username"];
    [aCoder encodeObject:self.avatar forKey:@"avatar"];
    [aCoder encodeObject:self.timeSinceSync forKey:@"time_since_sync"];
    [aCoder encodeObject:self.lastSynced forKey:@"last_sync_time"];
    [aCoder encodeObject:self.gender forKey:@"gender"];
    [aCoder encodeObject:self.height forKey:@"height"];
    [aCoder encodeObject:self.stepLength forKey:@"step_length"];
    [aCoder encodeObject:self.avgSteps forKey:@"7day_steps_avg"];
}

-(NSString *)description {
    NSString *description = [NSString stringWithFormat:@"date_joined::%@\n"
                             "authorization::%@\n"
                             "email::%@\n"
                             "first_name::%@\n"
                             "id::%@\n"
                             "is_active::%@\n"
                             "is_staff::%@\n"
                             "is_superuser::%@\n"
                             "last_login::%@\n"
                             "last_name::%@\n"
                             "resource_uri::%@\n"
                             "token::%@\n"
                             "username::%@\n"
                             "Avatar::%@\n"
                             "lastSynced::%@\n"
                             "gender::%@\n"
                             "height::%@\n"
                             "step_length::%@\n"
                             ,self.authorization,self.dateJoined, self.email, self.firstName, self.userId,
                             self.isActive, self.isStaff, self.isSuperuser, self.lastLogin,
                             self.lastName, self.resourceURI, self.token, self.username, self.avatar,
							 self.lastSynced,self.gender,self.height,self.stepLength
                             ];
    return description;
}

- (NSString*)fullName {
    if (![self.lastName isNilOrEmpty])
    {
        return [NSString stringWithFormat:@"%@ %@.", self.firstName, self.lastName != nil ? [self.lastName substringToIndex:1] : @""];
    }
    return self.firstName;

}

@end
