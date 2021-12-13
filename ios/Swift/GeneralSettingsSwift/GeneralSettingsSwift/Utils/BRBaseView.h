//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRBaseView : UIView

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, strong) UIView *alertView;

@property (nonatomic, strong) UIView *topView;

@property (nonatomic, strong) UIButton *leftBtn;

@property (nonatomic, strong) UIButton *rightBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *lineView;

- (void)initUI;

- (void)didTapBackgroundView:(UITapGestureRecognizer *)sender;

- (void)clickLeftBtn;

- (void)clickRightBtn;

- (void)setupThemeColor:(UIColor *)themeColor;

@end
