//
//  LoginViewController.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoadingView.h"
#import "NewUserViewController.h"
#import "NetworkController.h"
#import "GameTabViewController.h"
#import "NetworkStorageTabBarController.h"

@interface LoginViewController : UIViewController <NSStreamDelegate,UIAlertViewDelegate,UITextFieldDelegate,NewUserViewControllerDelegate,NetworkControllerDelegate,LoadingViewDelegate>
@property (nonatomic,weak) IBOutlet UITextField *UserName;
@property (nonatomic,weak) IBOutlet UITextField *Password;
@property (nonatomic,weak) IBOutlet UIButton *registerButton;
@property (nonatomic,weak) IBOutlet UIButton *loginButton;
@property (nonatomic,weak) IBOutlet UILabel *registerText;
@property (nonatomic,weak) IBOutlet UILabel *usernameText;
@property (nonatomic,weak) IBOutlet UILabel *passwordText;
@property (nonatomic,weak) IBOutlet UILabel *loginText;
@property (nonatomic,strong) NetworkController *thisNetworkController;
@property (nonatomic, strong) LoadingView * loader;

@end


/*	
 
 ********SAMPLE THEADING CODE**********
 
 // Initialise the queue used to download from flickr
 dispatch_queue_t dispatchQueue = dispatch_queue_create("q_photosInPlace", NULL);
 [self.spinner startAnimating];
 
 // Using the dowload queue, fetch the array of photos based on the selected dictionary
 dispatch_async(dispatchQueue, ^{
 
 NSArray *photos = [FlickrFetcher photosInPlace:placeDictionary maxResults:50];
 
 // Use the main queue to prepare for segue
 dispatch_async(dispatch_get_main_queue(), ^{
 // Set up the photo descriptions in the PhotoDescriptionViewController
 [[segue destinationViewController] setPhotoList:photos
 withTitle:[[sender textLabel] text]];
 [[[segue destinationViewController] tableView] reloadData];
 [self.spinner stopAnimating];
 });
 
 });
 dispatch_release(dispatchQueue);
 
 */