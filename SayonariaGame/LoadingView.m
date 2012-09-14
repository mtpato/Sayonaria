//
//  LoadingView.m
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+(LoadingView *)loadSpinnerIntoView:(UIView *)superView{
	// Create a new view with the same frame size as the superView
	LoadingView *loaderView = [[LoadingView alloc] initWithFrame:superView.bounds];
	// If something's gone wrong, abort!
	if(!loaderView){ return nil; }
    
    //make the background of the spinner
    loaderView.backgroundColor = [UIColor blackColor];
    
    //create the spinning indicator//
    UIActivityIndicatorView *indicator =
    [[UIActivityIndicatorView alloc]
      initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhiteLarge];
	// Set the resizing mask so it's not stretched
    indicator.autoresizingMask =
    UIViewAutoresizingFlexibleTopMargin |
    UIViewAutoresizingFlexibleRightMargin |
    UIViewAutoresizingFlexibleBottomMargin |
    UIViewAutoresizingFlexibleLeftMargin;
	// Place it in the middle of the view
    indicator.center = superView.center;
	// Add it into the spinnerView
    [loaderView addSubview:indicator];
	// Start it spinning! Don't miss this step
	[indicator startAnimating];
    
    [superView addSubview:loaderView];
    
	// Create a new animation
    CATransition *animation = [CATransition animation];
	// Set the type to a nice wee fade
	[animation setType:kCATransitionFade];
	// Add it to the superView
	[[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    
    return loaderView;
}

-(void)removeLoader:(UIView *)superView {
    CATransition *animation = [CATransition animation];
	[animation setType:kCATransitionFade];
	[[superView layer] addAnimation:animation forKey:@"layerAnimation"];
    [super removeFromSuperview];
}

@end
