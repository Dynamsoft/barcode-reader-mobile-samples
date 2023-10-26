/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

#import <Foundation/Foundation.h>
#import <DynamsoftCore/DynamsoftCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DSCaptureEnhancer : DSImageSourceAdapter

- (void)setUpCameraView:(UIView *)view;

- (void)startRunning;

- (void)stopRunning;

@end

NS_ASSUME_NONNULL_END
