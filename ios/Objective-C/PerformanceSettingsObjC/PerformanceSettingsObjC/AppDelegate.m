//
//  AppDelegate.m
//  PerformanceSettings
//
//  Created by dynamsoft on 2021/12/1.
//

#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "RootViewController.h"

@interface AppDelegate ()<DBRLicenseVerificationListener>

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
    
    if(@available(ios 15.0,*)){
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        [[UINavigationBar appearance] setStandardAppearance:appearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
    }
    
    // It is recommended to initialize the License in AppDelegate
    // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
    // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
    [DynamsoftBarcodeReader initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];

    return YES;
}

//MARK: DBRLicenseVerificationListener
- (void)DBRLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error
{
    [self verificationCallback:error];
}

- (void)verificationCallback:(NSError *)error{
    
    NSString* msg = @"";
    if(error != nil)
    {
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
