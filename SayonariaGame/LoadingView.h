//
//  LoadingView.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class LoadingView;

@protocol LoadingViewDelegate
@optional
-(void)loaderIsOnScreen;
@end

@interface LoadingView : UIView

-(LoadingView *)loadSpinnerIntoView:(UIView *)superView withSplash:(BOOL)isSplash withFade:(BOOL)withFade;
-(void)removeLoader:(UIView *)superView;
@property (nonatomic,weak) id<LoadingViewDelegate> delegate;

@end
