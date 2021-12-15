//
//  MyTargetProxy.h
//  PerformanceSettings
//
//  Created by dynamsoft on 2021/12/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyTargetProxy : NSProxy

+ (instancetype)weakProxyTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
