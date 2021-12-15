//
//  AppDelegate.m
//  PerformanceSettings
//
//  Created by dynamsoft on 2021/12/1.
//

#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "RootViewController.h"

@interface AppDelegate ()<DCELicenseVerificationListener>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
  
    [self.window makeKeyAndVisible];
    
    RootViewController *rootVC = [[RootViewController alloc] init];
    BaseNavigationController *naviVC = [[BaseNavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = naviVC;
    
    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(-200, 0)
                                                             forBarMetrics:UIBarMetricsDefault];
    
    // You should set the DCE License in AppDelegate
   [DynamsoftCameraEnhancer initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:appDidEnterToBackground_Notication object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:appWillEnterToForeground_Notication object:nil];
}

//MARK: DCELicenseVerificationListener
- (void)DCELicenseVerificationCallback:(bool)isSuccess error:(NSError *)error
{
    NSLog(@"%@", isSuccess ? @"DCE_vertify_success!":@"DCE_vertify_failure!");
    [self verificationCallback:error];
}

- (void)verificationCallback:(NSError *)error{
    
    NSString* msg = @"";
    if(error != nil)
    {
        if (error.code == -1009) {
            msg = @"Unable to connect to the public Internet to acquire a license. Please connect your device to the Internet or contact support@dynamsoft.com to acquire an offline license.";
            [self showResult:@"No Internet"
                         msg:msg
                     acTitle:@"ok"
                  completion:^{
              
                  }];
        } else {
            
            msg = error.userInfo[NSUnderlyingErrorKey];
            if(msg == nil)
            {
                msg = [error localizedDescription];
            }
            [self showResult:@"Server license verify failed"
                         msg:msg
                     acTitle:@"OK"
                  completion:^{
                  }];
          
        }
    }
}

- (void)showResult:(NSString *)title msg:(NSString *)msg acTitle:(NSString *)acTitle completion:(void (^)(void))completion {
    
    dispatch_async(dispatch_get_main_queue(), ^{

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:msg preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:acTitle style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction * action) {
                                                    completion();
                                                }]];
        UIViewController *topViewController = [self topViewController];
        [topViewController presentViewController:alert animated:YES completion:nil];
      
    });
}

- (UIViewController *)topViewController {
    UIViewController *resultVC;
    resultVC = [self getTopViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self getTopViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)getTopViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self getTopViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self getTopViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}


@end