//
//  UIViewController+HideNavBackTitle.m
//  BarcodeScannerX
//
//  Created by dynamsoft on 2022/1/27.
//

#import "UIViewController+HideNavBackTitle.h"
#import <objc/runtime.h>

@implementation UIViewController (HideNavBackTitle)

+(void)load {
    swizzleMethod([self class], @selector(viewDidAppear:), @selector(ac_viewDidAppear));
}
 
// Set backBarButtonItem
- (void)ac_viewDidAppear{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:@""
                                              style:UIBarButtonItemStylePlain
                                              target:self
                                              action:nil];
    [self ac_viewDidAppear];
}

void swizzleMethod(Class class, SEL originalSelector, SEL swizzledSelector)
{
    // The method might not exist in the class, but in its superclass.
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
     
    // class_addMethod will fail if original method already exists.
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
     
    // The method doesn’t exist and we just added one.
    if (didAddMethod) {
        class_replaceMethod(class, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    }
    else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
