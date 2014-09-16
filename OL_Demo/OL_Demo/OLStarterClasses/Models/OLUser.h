//
//  OLUser.h
//  oceanleap
//
//  Copyright (c) 2014 Oceanleap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OLUser : NSObject<NSCoding>

@property (nonatomic, strong) NSDate *dateJoined;
@property (nonatomic, strong) NSDate *lastLogin;
@property (nonatomic, strong) NSDate* lastSynced;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *authorization;
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *isActive;
@property (nonatomic, copy) NSString *isStaff;
@property (nonatomic, copy) NSString *isSuperuser;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *resourceURI;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *timeSinceSync;
@property (nonatomic, strong) NSNumber *userId;
@property (nonatomic, strong) NSNumber* height;
@property (nonatomic, strong) NSNumber* avgSteps;
@property (nonatomic, strong) NSNumber* gender;
@property (nonatomic, strong) NSNumber* stepLength;
@property (nonatomic, strong) NSNumber* totalFitPoint;

- (NSString*)fullName;

+(instancetype) createUserFromDictionary:(NSDictionary*) dictionary;

@end
