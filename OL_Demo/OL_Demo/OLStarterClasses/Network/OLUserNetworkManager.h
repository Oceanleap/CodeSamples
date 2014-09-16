//
//  OLUserNetworkManager.h
//
//  Copyright (c) 2014 Oceanleap, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OLUser.h"

@interface OLUserNetworkManager : NSObject

@property (strong, readonly) OLUser *me;

+(instancetype)sharedInstance;

- (void)signup:(NSDictionary*)userDict completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void)autoLogin:(void(^)(NSError* error)) resultBlock;
- (void)loginWithEmail:(NSString*)email password:(NSString*)password completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void)forgotPasswordForEmail:(NSString*)email completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void)lastTimeSyncedForDevice:(NSString *)deviceUUID completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
//- (void)lifeTimeAggregateForActivity:(NSString *)activity completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void)postData:(NSDictionary*)dataDict completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void)registerDeviceKey:(NSString*)key name:(NSString*)name uuid:(NSString*)uuid completion:(void(^)(NSError* error)) resultBlock;
- (void)getUserDevices:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void)postFeedbackWithTitle:(NSString*)title andDescription:(NSString*)description completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void) messagePlayerWithUserID:(NSNumber *)userID challengeID:(NSString *)challengeID andType:(NSNumber *)type completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void) userNotificationSettingsList:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void) updateUserNotificationSettingsWithID:(NSString *)userID name:(NSString*)name andStatus:(BOOL)status completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
//Challenges
- (void) createChallenge:(NSDictionary*)challengeDict completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void) challengeListForStatus:(int)status completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void) getChallengeDetailsForID:(int)challengeID completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock;
- (void) inviteToUsersWithEmails:(NSArray*)emails toChallengeWithID:(int)challengeID completion:(void(^)(NSError* error))resultBlock;
- (void) acceptChallengeInviteWithID:(int)challengeID completion:(void(^)(NSError* error))resultBlock;


@end
