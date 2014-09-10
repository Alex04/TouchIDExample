//
//  ViewController.m
//  TouchIDExample
//
//  Created by Alexander Mack on 09/09/14.
//  Copyright (c) 2014 AMA. All rights reserved.
//

#import "ViewController.h"
#import <LocalAuthentication/LocalAuthentication.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *buttonLogin;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.labelInfo.text = @"Please login";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonLogin:(id)sender {
    
    if([self isTouchIDAvailable]) {
        [self showTouchIDAuthentication];
    } else {
        //do standard login
        self.labelInfo.text = @"Touch ID not available";
    }
}

- (BOOL) isTouchIDAvailable;
{
    LAContext *localAuthContext = [[LAContext alloc] init];
    NSError *error;
    [localAuthContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
    
    //if error - probably no touch id available
    if(error) {
        NSLog(@"Errir with biometrics authentication");
        return NO;
    }
    return YES;
}

- (void) showTouchIDAuthentication;
{
    __weak ViewController *weakSelf = self;
    LAContext *localAuthContext = [[LAContext alloc] init];
    [localAuthContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                     localizedReason:@"Identify to login" reply:^(BOOL success, NSError *error) {
                         if(success) {
                             //show logged in
                             weakSelf.labelInfo.text = @"Successfully authenticated";
                         } else {
                             NSString *failureReason;
                             //depending on error show what exactly has failed
                             switch (error.code) {
                                 case LAErrorAuthenticationFailed:
                                     failureReason = @"Touch ID authentication failed";
                                     break;
                                     
                                 case LAErrorUserCancel:
                                     failureReason = @"Touch ID authentication cancelled";
                                     break;
                                     
                                 case LAErrorUserFallback:
                                     failureReason =  @"UTouch ID authentication choose password selected";
                                     break;

                                 default:
                                     failureReason = @"Touch ID has not been setup or system has cancelled";
                                     break;
                             }
                             
                             NSLog(@"Authentication failed: %@", failureReason);
                             weakSelf.labelInfo.text = failureReason;
                             
                         }
                     }];
}

@end
