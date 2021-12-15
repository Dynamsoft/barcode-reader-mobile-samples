//
//  MyTargetProxy.m
//  PerformanceSettings
//
//  Created by dynamsoft on 2021/12/1.
//

#import "MyTargetProxy.h"

@interface MyTargetProxy ()

@property (nonatomic, weak) id target;

@end

@implementation MyTargetProxy

+ (instancetype)weakProxyTarget:(id)target{
    MyTargetProxy *proxy = [MyTargetProxy alloc];
    proxy.target = target;
    return proxy;
}

- (id)forwardingTargetForSelector:(SEL)selector{
    return _target;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel{

    return [NSObject instanceMethodSignatureForSelector:@selector(init)];
}
- (void)forwardInvocation:(NSInvocation *)invocation{
    void *nullPointer = NULL;
    [invocation setReturnValue:&nullPointer];
}

@end
