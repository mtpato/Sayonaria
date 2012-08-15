//
//  LoadingView.h
//  SayonariaGame
//
//  Created by Ian Pytlarz on 8/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface LoadingView : UIView

+(LoadingView *)loadSpinnerIntoView:(UIView *)superView;
-(void)removeLoader;

@end
