//
//  AppDelegate.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/25.
//

#import "AppDelegate.h"
#import "BaseNavigationController.h"
#import "MainViewController.h"

@interface AppDelegate ()<DBRLicenseVerificationListener,DCELicenseVerificationListener>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
  
    [self.window makeKeyAndVisible];
    
    MainViewController *rootVC = [[MainViewController alloc] init];
    BaseNavigationController *naviVC = [[BaseNavigationController alloc] initWithRootViewController:rootVC];
    self.window.rootViewController = naviVC;
    
    if(@available(ios 15.0,*)){
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = kNavigationBackgroundColor;
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
      

        [[UINavigationBar appearance] setStandardAppearance:appearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
    }
    

    // It is recommended to initialize the License in AppDelegate
    // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
    // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
    [DynamsoftBarcodeReader initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];
    [DynamsoftCameraEnhancer initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];

    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AppDidEnterToBackgroundNotification object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[NSNotificationCenter defaultCenter] postNotificationName:AppWillEnterToForegroundNotification object:nil];
}

//MARK: DBRLicenseVerificationListener
- (void)DBRLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error
{
    [self verificationCallback:error];
}

- (void)DCELicenseVerificationCallback:(bool)isSuccess error:(NSError *)error
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
