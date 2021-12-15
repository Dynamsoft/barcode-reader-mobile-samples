//
//  BaseNavigationController.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/18.
//

#import "BaseNavigationController.h"

@interface BaseNavigationController ()

@end

@implementation BaseNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    

}

- (BOOL)prefersStatusBarHidden
{
    return self.visibleViewController.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    UIViewController* topVC = self.topViewController;
    return [topVC preferredStatusBarStyle];

}


@end
