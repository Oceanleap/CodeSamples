//
//  ViewController.m
//  OLDemo
//
//  Copyright (c) 2014 Oceanleap, Inc. All rights reserved.
//

#import "ViewController.h"
#import "OLUserNetworkManager.h"

#define EMAIL_ADDRESS	@"test@test.test"
#define PASSWORD		@"testing"
#define DEVICE_KEY		@"bm7aCFcOC4avXIwydkeRicy5P0mwA14QmZjdDZ6NqjI"
#define DEVICE_UUID		@"23BE7D1A-E8DB-0EE5-27E3-DE66A531D38F"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signUpPressed:(id)sender {
	NSDictionary *signupDict = @{@"first_name"	: @"John",
								 @"last_name"	: @"Doe",
								 @"timezone"	: @"America/Los_Angeles",
								 @"username"	: EMAIL_ADDRESS,
								 @"email"		: EMAIL_ADDRESS,
								 @"password"	: PASSWORD};

	[[OLUserNetworkManager sharedInstance] signup:signupDict completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"sendSignupData ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"sendSignupData CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"sendSignupData SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

- (IBAction)autoLoginPressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] autoLogin:^(NSError *error){
		if (error) {
			NSLog(@"Auto Login ERROR: %@",error.localizedDescription);
		} else {
			NSLog(@"Auto Login SUCCESS!!!");
		}
	}];
}

- (IBAction)logInPressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] loginWithEmail:EMAIL_ADDRESS password:PASSWORD completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"sendSignupData ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"sendSignupData CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"sendSignupData SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];
}

- (IBAction)registerDevicePressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] registerDeviceKey:DEVICE_KEY name:@"FirstDevice" uuid:DEVICE_UUID completion:^(NSError *error) {
        if (error) {
			NSLog(@"registerDevice ERROR: %@",error.localizedDescription);
        } else {
			NSLog(@"registerDevice SUCCESS!!!!!");
        }
    }];

}

- (IBAction)getUseDevicesPressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] getUserDevices:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"getUserDevices ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"getUserDevices CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"getUserDevices SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

- (IBAction)lastTimeSyncedPressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] lastTimeSyncedForDevice:DEVICE_UUID completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"lastTimeSyncedForDevice ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"lastTimeSyncedForDevice CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"lastTimeSyncedForDevice SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

- (IBAction)postDataPressed:(id)sender {
	double timestamp = [[NSDate date] timeIntervalSince1970] - 5000.0;
	NSArray * dataset = @[@{@"measurement":@1, @"value":@19, @"timestamp":@(timestamp)}];

	NSDictionary * postDict = @{@"activity_type":@"walking",@"device_uuid":DEVICE_UUID,@"sync_method":@1,@"sync_time":@(timestamp),@"dataset":dataset};

	[[OLUserNetworkManager sharedInstance] postData:postDict completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"postSampleData ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"postSampleData CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"postSampleData SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

- (IBAction)forgotPasswordPressed:(id)sender {

	[[OLUserNetworkManager sharedInstance] forgotPasswordForEmail:EMAIL_ADDRESS completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"forgotPasswordForEmail ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"forgotPasswordForEmail CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"forgotPasswordForEmail SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

- (IBAction)createChallengePressed:(id)sender {

	double startTime = [[NSDate date] timeIntervalSince1970];
	double endTime = [[NSDate date] timeIntervalSince1970] + 10000.0;
	NSDictionary *dict = @{@"invite_emails":@[],
						   @"bet":@"",
						   @"title":@"My challenge",
						   @"description":@"I am creating a challenge!",
						   @"start_time":@(startTime),
						   @"end_time":@(endTime),
						   @"measurement":@1};
	[[OLUserNetworkManager sharedInstance] createChallenge:dict completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"createChallenge ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"createChallenge CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"createChallenge SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];


}

//Status of 0 is Current/Active challenges
//Status of 1 is Upcoming challenges
//Status of 2 is Completed challenges
- (IBAction)getChallengeListPressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] challengeListForStatus:1 completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"challengeListForStatus ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"challengeListForStatus CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"challengeListForStatus SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

#warning Include the id of a challenge you created to get the details
- (IBAction)getChallengeDetailPressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] getChallengeDetailsForID:15 completion:^(id object, NSString *customError, NSError *error) {
		if (error) {
			NSLog(@"getChallengeDetailsForID ERROR: %@",error.localizedDescription);
		} else if (customError) {
			NSLog(@"getChallengeDetailsForID CUSTOM ERROR: %@",customError);
		} else {
			NSLog(@"getChallengeDetailsForID SUCCESS!!!!!");
			NSLog(@"Object = %@",object);
		}
	}];

}

#warning Add an email to the array to send an invite, make sure to include the id of a challenge you created
- (IBAction)inviteToChallengePressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] inviteToUsersWithEmails:@[] toChallengeWithID:15 completion:^(NSError *error) {
        if (error) {
			NSLog(@"inviteToUsersWithEmails ERROR: %@",error.localizedDescription);
        } else {
			NSLog(@"inviteToUsersWithEmails SUCCESS!!!!!");
        }
    }];

}

- (IBAction)acceptChallengePressed:(id)sender {
	[[OLUserNetworkManager sharedInstance] acceptChallengeInviteWithID:7 completion:^(NSError *error) {
        if (error) {
			NSLog(@"acceptChallengeInviteWithID ERROR: %@",error.localizedDescription);
        } else {
			NSLog(@"acceptChallengeInviteWithID SUCCESS!!!!!");
        }
    }];
}

@end
