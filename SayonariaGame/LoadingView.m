//
//  LoadingView.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()
@end

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)callDelegateMethod{
    [self.delegate loaderIsOnScreen];
}

-(LoadingView *)loadSpinnerIntoView:(UIView *)superView withSplash:(BOOL)isSplash withFade:(BOOL)withFade{

    NSLog(@"Creating Loader...");
    
    // Create a new view with the same frame size as the superView
	//LoadingView *loaderView = [[LoadingView alloc] initWithFrame:superView.bounds];
    
    LoadingView *loaderView = [[LoadingView alloc] initWithFrame:[[UIScreen mainScreen]bounds]];
    
    
	// If something's gone wrong, abort!
	if(!loaderView){ return nil; }
    
    //set up the screen dimensions
    CGRect screenBounds =[[UIScreen mainScreen] bounds];
    CGSize screenDimensions = screenBounds.size;
    
    if(isSplash == YES){
        UIImage *loaderBackgroundImage = [UIImage imageNamed:@"SplashArtIphone@2x.png"];
        UIImageView *loaderBackground = [[UIImageView alloc] initWithImage:loaderBackgroundImage];
        //add a blank view to the screen (allows us to remove them properly)
        UIImageView *blankView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
        [loaderView insertSubview:blankView atIndex:0];
        //add the splash art to the screen
        [loaderBackground setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
        [loaderView insertSubview:loaderBackground atIndex:1];
    } else {
    
    //make the background of the spinner
    UIImage *loaderBackgroundImage = [UIImage imageNamed:@"BlankFancyBackIphone@2x.png"];
    UIImageView *loaderBackground = [[UIImageView alloc] initWithImage:loaderBackgroundImage];
    [loaderBackground setFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];
    [loaderView insertSubview:loaderBackground atIndex:0];
    
    //create the spinning indicator//
    UIImage *loaderImage = [UIImage imageNamed:@"loader_sayonaria_version_05_A10000.png"];
    UIImageView *activityImageView = [[UIImageView alloc] initWithImage:loaderImage];
    activityImageView.animationImages = [NSArray arrayWithObjects:
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10000.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10001.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10002.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10003.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10004.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10005.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10006.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10007.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10008.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10009.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10010.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10011.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10012.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10013.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10014.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10015.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10016.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10017.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10018.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10019.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10020.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10021.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10022.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10023.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10024.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10025.png"],
                            [UIImage imageNamed:@"loader_sayonaria_version_05_A10026.png"],
	                                         nil];
    activityImageView.animationDuration = 2.5;
    
    // Set the resizing mask so it's not stretched
    activityImageView.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
    // Place it in the middle of the view
    activityImageView.frame = CGRectMake(superView.frame.size.width/2,superView.frame.size.height/2, screenDimensions.width/2, screenDimensions.width/2);
    UIImageView *blankView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenDimensions.width,screenDimensions.height)];

    activityImageView.center = blankView.center;
	// Add it into the spinnerView
    [loaderView insertSubview:activityImageView atIndex:1];
	// Start it spinning! Don't miss this step
	[activityImageView startAnimating];

    //set up the fade in
    loaderView.alpha = 0.0;
    NSTimeInterval animationDuration = 0.0;
    if(withFade == YES) { animationDuration = 0.75;}
        
    [UIImageView animateWithDuration:animationDuration
                              animations:^{loaderView.alpha = 1.0;}
                              completion:^(BOOL finished){
                                  if (withFade == YES) {
                                      [self.delegate loaderIsOnScreen];
                                  }
                              }]; 
    }
    [superView insertSubview:loaderView atIndex:[[superView subviews] count]+1];
    return loaderView;
}

-(void)removeLoader:(UIView *)superView {
    NSLog(@"Removing Loader...");

    [UIView animateWithDuration:0.75
                     animations:^{self.alpha = 0.0;}
                     completion:^(BOOL finished){[self removeFromSuperview];}];
}

@end
