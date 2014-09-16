//
//  OLNetworkConstants.h
//  oceanleap
//
//  Copyright (c) 2013 Oceanleap, Inc. All rights reserved.
//

#ifndef OLNetwork_AppConstants_h
#define OLNetwork_AppConstants_h

#warning Make sure you add your application key! http://www.oceanleap.com/get-started.html
#define APPLICATION_KEY							@""

#define API_VERSION								@"api/v1/"
#define API_REGISTER_DEVICE						@"mobile-device/register/"
#define API_LOGIN								@"users/login/"
#define API_FORGOT_PASSWORD						@"users/forgot-password/"
#define API_USER(__userId__)					[NSString stringWithFormat:@"user/%@/", __userId__]
#define API_USER_PROFILE(__userId__)            [NSString stringWithFormat:@"user-profiles/%@/", __userId__]
#define API_USER_SETTINGS_LIST					@"user-settings/list/"
#define API_USER_SETTINGS_UPDATE(__userId__)	[NSString stringWithFormat:@"user-settings/%@/", __userId__]
#define API_USERS_SUGGESTED						@"user/find-users/suggested/"
#define API_USERS_RECENT						@"user/find-users/recent/"
#define API_USERS_INVITED						@"user/find-users/invited/"
#define API_FITBIT_DEVICE						@"user/fitbit-devices/"
#define API_ASSOCIATE_USER_DEVICE				@"devices/user-associate/"
#define API_DEVICE_REGISTER						@"fitness-device/register/"
#define API_USER_DEVICES						@"users/devices/"

#define API_POST_ACTIVITY_DATA					@"activities/data/"
#define API_DEVICE_LAST_TIME_SYNC				@"devices/last-sync-time/"
#define API_ACTIVITY_LIFETIME					@"activity-analytics/lifetime/"

#define API_SENSOPLEX_DEVICE_POST_DATA			@"sensoplex/post/"
#define API_SIGNUP                              @"users/register/"
#define API_FACEBOOK_SIGNUP                     @"user/facebook-connect/"
#define API_UPDATE_USER_PROFILE					@"user-profiles/update/"
#define API_USER_FEEDBACK						@"feedback/"
#define API_UPLOAD_AVATAR						@"user/avatar/"
#define API_CHALLENGE_CREATE                    @"challenge/"
#define API_CHALLENGE_LIST                      @"challenge/"
#define API_CHALLENGE_LIST_SORTED               @"challenges/"
#define API_CHALLENGE_DETAILS(__challengeId__) [NSString stringWithFormat:@"challenge/%@/", __challengeId__]
#define API_CHALLENGE_JOIN                      @"challenge-join/"
#define API_CHALLENGE_INVITE                    @"challenge/invite/"
#define API_NOTIFICATION_LIST                   @"notification/"
#define API_NOTIFICATION_CLEAR                  @"notification/clear/"
#define API_NOTIFICATION_READ					@"notification/read/"
#define API_NOTIFICATION_NUDGE					@"notification/taunt-cheer/"
#define API_VERIFY_USER                         @"users/verify-credentials/"

#define API_HOSTNAME								@"https://api.oceanleap.com/"

//segues
#define CREATION_STEP_TWO                           @"CreationStepTwo"
#define CHALLENGE_LIST_CONTROLLER                   @"ChallengeListController"
#define SEGUE_CHALLENGE_DETAIL_VIEW                 @"ChallengeDetailView"
#define SEGUE_CHALLENGE_DETAIL_VIEW_EMBED           @"ChallengeDetailViewEmbed"
#define SEGUE_INVITE_OPTION                         @"InvitesOptionView"
#define SEGUE_INVITE                                @"InviteView"
#define SEGUE_LINK_FITBIT                           @"LinkFitBit"
#define SEGUE_LINK_DEVICE                           @"LinkDeviceSegue"
#define SEGUE_STORED_RECIPIENTS                     @"StoredRecipientsView"
#define SEGUE_FITBIT_TO_SLIDEPARENTVC               @"SegueFitBitToSlideParentVC"

//error string
#define PARSING_ERROR @"Error while parsing response from the server"

//constants
#define STATUS_ACTIVE @"active"
#define STATUS_UPCOMING @"future"
#define STATUS_PAST @"concluded"

#define DEVICE_TOKEN @"DeviceToken"
#define STORED_RECIPIENTS @"StoredRecipients"

//Notifications
#define REMOTE_NOTIFICATION_RECEIVED                @"RemoteNotificationReceived"
#define NOTIFICATION_CONTACTS_SELECTED              @"ConstactsSelected"
#define NOTIFICATION_CHALLENGE_SELECTED             @"NOTIFICATION_CHALLENGE_SELECTED"
#define NOTIFICATION_NOTIFICATIONS_REFRESHED        @"NOTIFICATION_NOTIFICATIONS_REFRESHED"
#define NOTIFICATION_NOTIFICATIONS_SCREEN_SELECTED  @"NOTIFICATION_NOTIFICATIONS_SCREEN_SELECTED"
#define NOTIFICATION_CREATE_NEW_CHALLENGE           @"NOTIFICATION_CREATE_NEW_CHALLENGE"
#define NOTIFICATION_HOME_SCREEN_SELECTED           @"NOTIFICATION_HOME_SCREEN_SELECTED"
#define NOTIFICATION_MY_PROFILE_SCREEN_SELECTED     @"NOTIFICATION_MY_PROFILE_SCREEN_SELECTED"
#define NOTIFICATION_LOGOUT                         @"NOTIFICATION_LOGOUT"
#define NOTIFICATION_MAIN_NAVCONTROLLER_LOADED      @"NOTIFICATION_MAIN_NAVCONTROLLER_LOADED"

//Invite Flows
typedef enum
{
    InviteFlowTypeNewChallenge,
    InviteFlowTypeExistingChallange
}InviteFlowType;

typedef enum
{
    OLNotificationTypeInvite		= 0,
    OLNotificationTypeRankChange	= 1,
    OLNotificationTypeJoin			= 2,
    OLNotificationTypeEnded			= 3,
    OLNotificationTypeStarted		= 4,
    OLNotificationTypeTaunt			= 5,
    OLNotificationTypeCheer			= 6
}OLNotificationType;

#endif
