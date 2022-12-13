#import "AppDelegate.h"
#import <DynamsoftBarcodeReader/DynamsoftBarcodeReader.h>

@interface AppDelegate ()<DBRLicenseVerificationListener>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    if(@available(ios 15.0,*)){
        UINavigationBarAppearance *appearance = [UINavigationBarAppearance new];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
        [[UINavigationBar appearance] setStandardAppearance:appearance];
        [[UINavigationBar appearance] setScrollEdgeAppearance:appearance];
    }
    
    // It is recommended to initialize the License in AppDelegate.
    // The license string here is a time-limited trial license. Note that network connection is required for this license to work.
    // You can also request an extension for your trial license in the customer portal: https://www.dynamsoft.com/customer/license/trialLicense?product=dbr&utm_source=installer&package=ios
    [DynamsoftBarcodeReader initLicense:@"DLS2eyJvcmdhbml6YXRpb25JRCI6IjIwMDAwMSJ9" verificationDelegate:self];
    
    return YES;
}

- (void)DBRLicenseVerificationCallback:(bool)isSuccess error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString* msg = @"";
        if(error != nil)
        {
            msg = error.userInfo[NSUnderlyingErrorKey];
            if(msg == nil)
            {
                msg = [error localizedDescription];
            }

            __block UIWindow *topWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
            topWindow.rootViewController = [[UIViewController alloc] init];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Server license verify failed" message:msg preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                topWindow.hidden = YES;
                topWindow = nil;
            }]];
            [topWindow makeKeyAndVisible];
            [topWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    });
}


@end
