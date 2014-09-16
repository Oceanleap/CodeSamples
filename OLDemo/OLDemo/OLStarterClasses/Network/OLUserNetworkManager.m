//
//  OLUserNetworkManager.m
//
//  Copyright (c) 2014 Oceanleap, Inc. All rights reserved.
//

#import "OLUserNetworkManager.h"
#import "OLNetworkConstants.h"
#import "NSString+Additions.h"

@interface OLUserNetworkManager()

@property (nonatomic, strong) OLUser* currentUser;

@end

static NSString* const kSavedUser = @"savedUser";

@implementation OLUserNetworkManager

+ (instancetype)sharedInstance {
    static OLUserNetworkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

#pragma mark - Signup

- (void) signup:(NSDictionary*)userDict completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/users/register/"]];
	[request setHTTPMethod:@"POST"];
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:userDict
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];
	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* responseDict = [self parsedJson:data];
				if (!responseDict || responseDict[@"error_message"]) {
					NSString* errorMsg = responseDict ? responseDict[@"error_message"] : @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				} else {
					OLUser *user = [self populateUser:responseDict];
					[self saveUser:user];
					completionBlock(responseDict, nil, nil);
				}
			} else {
				completionBlock(nil, nil, nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

#pragma mark - Verify Credentials

- (void) autoLogin:(void(^)(NSError* error)) resultBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/users/verify-credentials/"]];
	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
			NSDictionary* dict = [self parsedJson:data];

			if ([dict[@"success"] boolValue]) {
				resultBlock(nil);
			} else {
				resultBlock([NSError errorWithDomain:@"user.login" code:-101 userInfo:@{NSLocalizedDescriptionKey : @"user not authorized"}]);
				NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
				int responsecode = (int)[httpResponse statusCode];
				NSLog(@"Status Code %d",responsecode);
			}
		} else {
			NSDictionary *userInfo = @{
									   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
									   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to log in to server.", nil),
									   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
									   };

			NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
			resultBlock(error);
		}
	}] resume];
}

#pragma mark - Login


- (void) loginWithEmail:(NSString*)email password:(NSString*)password completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

    NSDictionary *postParams = @{@"username" : email, @"password" : password};

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/users/login/"]];

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postParams
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[request setHTTPMethod:@"POST"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
					if (data && [[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
						NSDictionary *jsonDictionary = [self parsedJson:data];
						NSLog(@"jsonDictionary = %@",jsonDictionary);
						if (jsonDictionary[@"authorization"]) {
							error = nil;
							NSDictionary *jsonDictionary = [self parsedJson:data];
							if (jsonDictionary) {
								NSString *authorization = jsonDictionary[@"authorization"];
								if(authorization == nil) {
									BOOL success = [jsonDictionary[@"success"] boolValue];
									if (!success) {
										NSString *reason = jsonDictionary[@"reason"];
										if ([NSString isNilOrEmptyString:reason]) {
											reason = @"Unfortunately an unknown error has occured while trying to log in. Please try again. If you continue to receive this error please contact us at support@stepshaker.com";
										}
										completionBlock(nil, reason, nil);
									}
								} else {
									OLUser *user = [self populateUser:jsonDictionary];
									[self saveUser:user];
									completionBlock(user, nil, nil);
								}
							} else {
								completionBlock(nil, PARSING_ERROR, nil);
							}
						} else {
							NSString * reason;
							if (jsonDictionary[@"reason"] && [jsonDictionary[@"reason"] isKindOfClass:[NSString class]]) {
								reason = jsonDictionary[@"reason"];
							}
							if ([NSString isNilOrEmptyString:reason]) {
								reason = @"Unfortunately an unknown error has occured while trying to log in. Please try again. If  you continue to receive this error please contact us at support@stepshaker.com";
							}
							completionBlock(nil, reason, nil);
						}
					} else { //connection failure
						if (error) {
							NSLog(@"error : %@", error.localizedDescription);
							completionBlock(nil, nil, error);
						} else {
							NSString *reason = @"Unfortunately an unknown error has occured while trying to log in. Please try again. If  you continue to receive this error please contact us at support@stepshaker.com";
							completionBlock(nil, reason, nil);
						}

                    }
                }] resume];
}

#pragma mark - Forgot Password

- (void)forgotPasswordForEmail:(NSString*)email completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

    NSDictionary *postParams = @{@"email":email}.mutableCopy;

	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/users/forgot-password/"]];

	[request setHTTPMethod:@"POST"];

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postParams
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
					if (data) {
						if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
							NSDictionary *jsonDictionary = [self parsedJson:data];
							if (jsonDictionary[@"success"]) {
								NSDictionary *jsonDictionary = [self parsedJson:data];
								if (jsonDictionary) {
									BOOL success = [jsonDictionary[@"success"] boolValue];
									if (success) {
										completionBlock(@(success), nil, nil);
									} else {
										if (![NSString isNilOrEmptyString:jsonDictionary[@"error"]]) {
											completionBlock(@(success), jsonDictionary[@"error"], nil);
										} else {
											completionBlock(@(success), @"Unknown error occurred", nil);
										}
									}
								} else {
									completionBlock(nil, PARSING_ERROR, nil);
								}
							} else { //connection failure
								NSLog(@"error : %@", error.localizedDescription);
								completionBlock(nil, nil, error);
							}
						}
					} else {
						completionBlock(nil, @"An error occured while submitting your request. Please try again later.", nil);
					}
	}] resume];
}

#pragma mark - Post Data

- (void) lastTimeSyncedForDevice:(NSString *)deviceUUID completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {


	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:[NSString stringWithFormat:@"https://api.oceanleap.com/api/v1/devices/last-sync-time/?device_uuid=%@",deviceUUID]]];
	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"last_sync_time"]) {
					NSLog(@"%@",dict);
					completionBlock(dict, nil, nil);
				} else {
					NSString* errorMsg = @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to retrieve your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

- (void) postData:(NSDictionary*)dataDict completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock{
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/activities/data/"]];

	[request setHTTPMethod:@"POST"];

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dataDict
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* responseDict = [self parsedJson:data];
				NSLog(@"%@",responseDict);
				if (!responseDict || responseDict[@"error_message"]) {
					NSString* errorMsg = responseDict ? responseDict[@"error_message"] : @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				} else {
					completionBlock(responseDict, nil, nil);
				}
			} else {
				completionBlock(nil, nil, nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

#pragma mark - Update Timezone

- (void)updateUserTimeZoneWithCompletion:(void(^)(NSError* error)) resultBlock {
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/users/update-timezone/"]];

	[request setHTTPMethod:@"POST"];

	NSDictionary *params = @{@"timezone":[[NSTimeZone localTimeZone] name]}.copy;

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		if (!error){
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"success"]) {
					NSLog(@"%@",dict);
					resultBlock(nil);
				} else {
					NSDictionary *userInfo = @{
											   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
											   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to update your timezone with the server.", nil),
											   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
											   };

					NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
					resultBlock(error);
				}
			} else {
				NSDictionary *userInfo = @{
										   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
										   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to update your timezone with the server.", nil),
										   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
										   };

				NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
				resultBlock(error);
			}
		} else {
			NSLog(@"unable to update timezone for this device %@", error.localizedDescription);
			resultBlock(error);
			return;
		}
	}] resume];
}


#pragma mark - Register Fitness Device

- (void)registerDeviceKey:(NSString*)key name:(NSString*)name uuid:(NSString*)uuid completion:(void(^)(NSError* error)) resultBlock {
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/devices/user-associate/"]];

	[request setHTTPMethod:@"POST"];

	NSDictionary *params = @{@"device_name":name,
							 @"device_uuid":uuid,
							 @"device_key":key}.copy;

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		if (!error){
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"success"]) {
					NSLog(@"%@",dict);
					resultBlock(nil);
				} else {
					NSDictionary *userInfo = @{
											   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
											   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to register your device with the server.", nil),
											   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
											   };

					NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
					resultBlock(error);
				}
			} else {
				NSDictionary *userInfo = @{
										   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
										   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to register your device with the server.", nil),
										   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
										   };

				NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
				resultBlock(error);
			}
		} else {
			NSLog(@"unable toregister device %@", error.localizedDescription);
			resultBlock(error);
			return;
		}
	}] resume];
}

- (void) getUserDevices:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/users/devices/"]];

	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSArray class]]) {
				NSArray* array = [self parsedJson:data];
				if (array && array.count) {
					completionBlock(array, nil, nil);
				} else {
					NSString* errorMsg = @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to save your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

#pragma mark - User Details

- (void) getUserDetailsForID:(int)userID completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:[NSString stringWithFormat:@"https://api.oceanleap.com/api/v1/users/%d/",userID]]];

	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"username"]) {
					completionBlock(dict, nil, nil);
				} else {
					NSString* errorMsg = @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to retrieve your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}


#pragma mark - Post Feedback

- (void)postFeedbackWithTitle:(NSString*)title andDescription:(NSString*)description completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableDictionary *params = @{@"description":description,
									@"title":title}.mutableCopy;

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/feedback/"]];

	[request setHTTPMethod:@"POST"];

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
		int responsecode = (int)[httpResponse statusCode];
        if (responsecode == 201) {
            NSLog(@"API_USER_FEEDBACK Successful");
			completionBlock(@"Success", nil, nil);
        } else if (error){ //connection failure
			completionBlock(nil, nil, error);
        } else {
			completionBlock(nil, @"An unknown error occured while submitting your feedback.", nil);
		}
	}] resume];
}

/*
#pragma mark - User Profile

- (void) getUserProfileForID:(NSNumber*)userID completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:[NSString stringWithFormat:@"https://api.oceanleap.com/api/v1/user-profiles/%@/",[userID stringValue]]]];
	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {

		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* responseDict = [self parsedJson:data];
				NSLog(@"User responseDict: %@",responseDict);
				if (!responseDict || responseDict[@"error_message"]) {
					NSString* errorMsg = responseDict ? responseDict[@"error_message"] : @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				} else {
					completionBlock(responseDict, nil, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to get your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}
*/

#pragma mark - Interplayer communication

- (void) messagePlayerWithUserID:(NSNumber *)userID challengeID:(NSString *)challengeID andType:(NSNumber *)type completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSDictionary *params = @{@"send_to":userID,
							 @"challenge_id":challengeID,
							 @"type":type}.copy;

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/notifications/taunt-cheer/"]];

	[request setHTTPMethod:@"POST"];

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
        if (!error) {
			NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
			int responsecode = (int)[httpResponse statusCode];
			NSLog(@"%@",[self parsedJson:data]);
			if (responsecode == 202) {
				completionBlock(@YES, nil, nil);
			} else {
				completionBlock(nil, @"Error sending your taunt/cheer.", nil);
			}
        } else { //connection failure
            NSLog(@"error : %@", error.localizedDescription);
            completionBlock(nil, nil, error);
        }
	}] resume];
}

#pragma mark - User Settings

- (void) userNotificationSettingsList:(void (^)(id object, NSString *customError, NSError *error))completionBlock {
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/settings/list/"]];

	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (!dict) {
					NSString* errorMsg = @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				} else {
					completionBlock(dict, nil, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to save your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

- (void) updateUserNotificationSettingsWithID:(NSString *)userID name:(NSString*)name andStatus:(BOOL)status completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSDictionary *params = @{@"objects":@[@{name:@(status)}]}.copy;

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:[NSString stringWithFormat:@"https://api.oceanleap.com/api/v1/settings/?user=%@",userID]]];

	[request setHTTPMethod:@"PATCH"];

	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
        if (!error) {
			NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
			int responsecode = (int)[httpResponse statusCode];

			if (responsecode == 202) {
				completionBlock(@YES, nil, nil);
			} else {
				completionBlock(nil, @"Error saving your settings change.", nil);
			}
        } else { //connection failure
            NSLog(@"error : %@", error.localizedDescription);
            completionBlock(nil, nil, error);
        }
	}] resume];
}

#pragma mark - Challenges
#pragma mark - Create Challenge

- (void) createChallenge:(NSDictionary*)challengeDict completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/challenges/"]];
	[request setHTTPMethod:@"POST"];
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:challengeDict
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];
	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* responseDict = [self parsedJson:data];
				if (!responseDict || responseDict[@"error_message"]) {
					NSString* errorMsg = responseDict ? responseDict[@"error_message"] : @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				} else {
					completionBlock(responseDict, nil, nil);
				}
			} else {
				completionBlock(nil, @"An unknown error occurred", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

#pragma mark - Challenge List

- (void) challengeListForStatus:(int)status completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {
	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:[NSString stringWithFormat:@"https://api.oceanleap.com/api/v1/challenges/?status=%d&order_by=end_time&limit=20",status]]];

	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				NSLog(@"[self parsedJson:data] = %@",dict);
				if (dict && dict[@"meta"]) {
					completionBlock(dict, nil, nil);
				} else {
					NSString* errorMsg = @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to save your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

#pragma mark - Challenge Details

- (void) getChallengeDetailsForID:(int)challengeID completion:(void (^)(id object, NSString *customError, NSError *error))completionBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:[NSString stringWithFormat:@"https://api.oceanleap.com/api/v1/challenges/%d/",challengeID]]];

	[request setHTTPMethod:@"GET"];

	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error) {
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"created_at"]) {
					completionBlock(dict, nil, nil);
				} else {
					NSString* errorMsg = @"Invalid Response Received";
					completionBlock(nil, errorMsg, nil);
				}
			} else {
				completionBlock(nil, @"We encountered an error while trying to retrieve your data. Please try again later.", nil);
			}
		} else { //connection failure
			NSLog(@"error : %@", error.localizedDescription);
			completionBlock(nil, nil, error);
		}
	}] resume];
}

#pragma mark - Invite to Challenge

- (void) inviteToUsersWithEmails:(NSArray*)emails toChallengeWithID:(int)challengeID completion:(void(^)(NSError* error))resultBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/challenges/invite/"]];
	[request setHTTPMethod:@"POST"];

	NSDictionary * sendDict = @{@"invite_emails":emails,@"challenge":@(challengeID)};
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDict
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];
	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error){
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"success"]) {
					NSLog(@"%@",dict);
					resultBlock(nil);
				} else {
					NSDictionary *userInfo = @{
											   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
											   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to invite users at this time.", nil),
											   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
											   };

					NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
					resultBlock(error);
				}
			} else {
				NSDictionary *userInfo = @{
										   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
										   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to invite users at this time.", nil),
										   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
										   };

				NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
				resultBlock(error);
			}
		} else {
			NSLog(@"unable invite users %@", error.localizedDescription);
			resultBlock(error);
			return;
		}
	}] resume];
}

#pragma mark - Invite to Challenge

- (void) acceptChallengeInviteWithID:(int)challengeID completion:(void(^)(NSError* error))resultBlock {

	NSURLSessionConfiguration * config = [NSURLSessionConfiguration defaultSessionConfiguration];
	config.HTTPAdditionalHeaders = @{@"Content-Type" : @"application/json", @"OceanleapApplicationKey": APPLICATION_KEY, @"Authorization" : self.me.authorization};

    NSURLSession * session = [NSURLSession sessionWithConfiguration:config];

	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:
									[NSURL URLWithString:@"https://api.oceanleap.com/api/v1/challenges/accept-invite/"]];
	[request setHTTPMethod:@"POST"];

	NSDictionary * sendDict = @{@"challenge":@(challengeID)};
	NSError *error;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendDict
													   options:NSUTF8StringEncoding
														 error:&error];

	[request setHTTPBody:jsonData];
	[[session dataTaskWithRequest:request completionHandler:^(NSData *data,
															  NSURLResponse *response,
															  NSError *error) {
		// handle response
		if (!error){
			if ([[self parsedJson:data] isKindOfClass:[NSDictionary class]]) {
				NSDictionary* dict = [self parsedJson:data];
				if (dict && dict[@"success"]) {
					resultBlock(nil);
				} else {
					NSDictionary *userInfo = @{
											   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
											   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to invite users at this time.", nil),
											   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
											   };

					NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
					resultBlock(error);
				}
			} else {
				NSDictionary *userInfo = @{
										   NSLocalizedDescriptionKey: NSLocalizedString(@"Operation was unsuccessful.", nil),
										   NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Unable to invite users at this time.", nil),
										   NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try again in a few minutes.", nil)
										   };

				NSError * error = [NSError errorWithDomain:@"Connection Error" code:-14 userInfo:userInfo];
				resultBlock(error);
			}
		} else {
			NSLog(@"unable invite users %@", error.localizedDescription);
			resultBlock(error);
			return;
		}
	}] resume];
}


#pragma mark - Authorization

- (OLUser*) me {
    return self.currentUser;
}

- (NSString*)fullAPIPath:(NSString*)api {
    return [NSString stringWithFormat:@"%@%@%@", API_HOSTNAME, API_VERSION, api];
}

- (id)parsedJson:(NSData*)data {

    NSError *parsingError;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&parsingError];
    if (parsingError) {
        NSLog(@"Respone converted to String :: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        return nil;
    }
    return json;
}

- (void)saveUser:(OLUser*)user {
	self.currentUser = user;
}


- (OLUser*)populateUser:(NSDictionary*)dictionary {
    return [OLUser createUserFromDictionary:dictionary];
}

- (NSString*)appendGetParams:(NSDictionary*)params toAPI:(NSString*)api {
    NSMutableString *tempString = [[NSMutableString alloc] init];
    for (id key in params) {
        [tempString appendFormat:@"%@=%@&",key,params[key]];
    }
    return [api stringByAppendingFormat:@"?%@",tempString];
}

@end
