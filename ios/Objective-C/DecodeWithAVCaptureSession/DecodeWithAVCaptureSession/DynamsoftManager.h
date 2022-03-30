//
//  DynamsoftManager.h
//  DecodeWithAVCaptureSession
//
//  Created by dynamsoft on 2022/3/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamsoftManager : NSObject<NSCopying, NSMutableCopying>

+ (DynamsoftManager *)manager;

- (void)showResult:(NSString *)title msg:(NSString *)msg acTitle:(NSString *)acTitle completion:(nullable void (^)(void))completion;


@end

NS_ASSUME_NONNULL_END
