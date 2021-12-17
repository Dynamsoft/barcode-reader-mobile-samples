//
//  Created by Dynamsoft on 2021/12/5.
//  Copyright © Dynamsoft. All rights reserved.
//

#import "BRStringPickerView.h"
#import "BRPickerViewMacro.h"

typedef NS_ENUM(NSInteger, BRStringPickerMode) {
    BRStringPickerComponentSingle,
    BRStringPickerComponentMore
};

@interface BRStringPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>
{
    BOOL isDataSourceValid;
}

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) BRStringPickerMode type;
@property (nonatomic, strong) NSArray *dataSourceArr;
@property (nonatomic, strong) NSString *selectValue;
@property (nonatomic, strong) NSMutableArray *selectValueArr;

@property (nonatomic, assign) BOOL isAutoSelect;
@property (nonatomic, strong) UIColor *themeColor;
@property (nonatomic, copy) BRStringResultBlock resultBlock;
@property (nonatomic, copy) BRStringCancelBlock cancelBlock;

@end

@implementation BRStringPickerView

+ (void)showStringPickerWithTitle:(NSString *)title
                       dataSource:(id)dataSource
                  defaultSelValue:(id)defaultSelValue
                      resultBlock:(BRStringResultBlock)resultBlock {
    [self showStringPickerWithTitle:title dataSource:dataSource defaultSelValue:defaultSelValue isAutoSelect:NO themeColor:nil resultBlock:resultBlock cancelBlock:nil];
}

+ (void)showStringPickerWithTitle:(NSString *)title
                       dataSource:(id)dataSource
                  defaultSelValue:(id)defaultSelValue
                     isAutoSelect:(BOOL)isAutoSelect
                       themeColor:(UIColor *)themeColor
                      resultBlock:(BRStringResultBlock)resultBlock {
    [self showStringPickerWithTitle:title dataSource:dataSource defaultSelValue:defaultSelValue isAutoSelect:isAutoSelect themeColor:themeColor resultBlock:resultBlock cancelBlock:nil];
}

+ (void)showStringPickerWithTitle:(NSString *)title
                       dataSource:(id)dataSource
                  defaultSelValue:(id)defaultSelValue
                     isAutoSelect:(BOOL)isAutoSelect
                       themeColor:(UIColor *)themeColor
                      resultBlock:(BRStringResultBlock)resultBlock
                      cancelBlock:(BRStringCancelBlock)cancelBlock {
    BRStringPickerView *strPickerView = [[BRStringPickerView alloc]initWithTitle:title dataSource:dataSource defaultSelValue:defaultSelValue isAutoSelect:isAutoSelect themeColor:themeColor resultBlock:resultBlock cancelBlock:cancelBlock];
    NSAssert(strPickerView->isDataSourceValid, @"The data source is illegal! Please check the format of the string selector data source");
    if (strPickerView->isDataSourceValid) {
        [strPickerView showWithAnimation:YES];
    }
}

- (instancetype)initWithTitle:(NSString *)title
                   dataSource:(id)dataSource
              defaultSelValue:(id)defaultSelValue
                 isAutoSelect:(BOOL)isAutoSelect
                   themeColor:(UIColor *)themeColor
                  resultBlock:(BRStringResultBlock)resultBlock
                  cancelBlock:(BRStringCancelBlock)cancelBlock {
    if (self = [super init]) {
        self.title = title;
        self.isAutoSelect = isAutoSelect;
        self.themeColor = themeColor;
        self.resultBlock = resultBlock;
        self.cancelBlock = cancelBlock;
        isDataSourceValid = YES;
        [self configDataSource:dataSource defaultSelValue:defaultSelValue];
        if (isDataSourceValid) {
            [self initUI];
        }
    }
    return self;
}

- (void)configDataSource:(id)dataSource defaultSelValue:(id)defaultSelValue {
    if (!dataSource) {
        isDataSourceValid = NO;
    }
    NSArray *dataArr = nil;
    if ([dataSource isKindOfClass:[NSArray class]] && [dataSource count] > 0) {
        dataArr = [NSArray arrayWithArray:dataSource];
    } else if ([dataSource isKindOfClass:[NSString class]] && [dataSource length] > 0) {
        NSString *plistName = dataSource;
        NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:nil];
        dataArr = [[NSArray alloc] initWithContentsOfFile:path];
        if (!dataArr || dataArr.count == 0) {
            isDataSourceValid = NO;
        }
    } else {
        isDataSourceValid = NO;
    }
    if (isDataSourceValid) {
//        Class itemClass = [[dataArr firstObject] class];
//        for (id obj in dataArr) {
//            if (![obj isKindOfClass:itemClass]) {
//                isDataSourceValid = NO;
//                break;
//            }
//        }
    }
    if (!isDataSourceValid) {
        return;
    }
    self.dataSourceArr = dataArr;
    
    if ([[self.dataSourceArr firstObject] isKindOfClass:[NSString class]]) {
        self.type = BRStringPickerComponentSingle;
    } else if ([[self.dataSourceArr firstObject] isKindOfClass:[NSArray class]]) {
        self.type = BRStringPickerComponentMore;
    }
    if (self.type == BRStringPickerComponentSingle) {
        if (defaultSelValue && [defaultSelValue isKindOfClass:[NSString class]] && [defaultSelValue length] > 0 && [self.dataSourceArr containsObject:defaultSelValue]) {
            self.selectValue = defaultSelValue;
        } else {
            self.selectValue = [self.dataSourceArr firstObject];
        }
        NSInteger row = [self.dataSourceArr indexOfObject:self.selectValue];
        [self.pickerView selectRow:row inComponent:0 animated:NO];
    } else if (self.type == BRStringPickerComponentMore) {
        NSMutableArray *tempArr = [NSMutableArray array];
        for (NSInteger i = 0; i < self.dataSourceArr.count; i++) {
            NSString *selValue = nil;
            if (defaultSelValue && [defaultSelValue isKindOfClass:[NSArray class]] && [defaultSelValue count] > 0 && i < [defaultSelValue count] && [self.dataSourceArr[i] containsObject:defaultSelValue[i]]) {
                [tempArr addObject:defaultSelValue[i]];
                selValue = defaultSelValue[i];
            } else {
                [tempArr addObject:[self.dataSourceArr[i] firstObject]];
                selValue = [self.dataSourceArr[i] firstObject];
            }
            NSInteger row = [self.dataSourceArr[i] indexOfObject:selValue];
            [self.pickerView selectRow:row inComponent:i animated:NO];
        }
        self.selectValueArr = [tempArr copy];
    }
}

- (void)initUI {
    [super initUI];
    self.titleLabel.text = self.title;
    [self.alertView addSubview:self.pickerView];
    if (self.themeColor && [self.themeColor isKindOfClass:[UIColor class]]) {
        [self setupThemeColor:self.themeColor];
    }
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, kTopViewHeight + 0.5, self.alertView.frame.size.width, kPickerHeight)];
        _pickerView.backgroundColor = [UIColor whiteColor];
        _pickerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth;
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.showsSelectionIndicator = YES;
    }
    return _pickerView;
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    switch (self.type) {
        case BRStringPickerComponentSingle:
            return 1;
            break;
        case BRStringPickerComponentMore:
            return self.dataSourceArr.count;
            break;
            
        default:
            break;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    switch (self.type) {
        case BRStringPickerComponentSingle:
            return self.dataSourceArr.count;
            break;
        case BRStringPickerComponentMore:
            return [self.dataSourceArr[component] count];
            break;
            
        default:
            break;
    }
}

#pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (self.type) {
        case BRStringPickerComponentSingle:
        {
            self.selectValue = self.dataSourceArr[row];
            if (self.isAutoSelect) {
                if(self.resultBlock) {
                    self.resultBlock(self.selectValue);
                }
            }
        }
            break;
        case BRStringPickerComponentMore:
        {
            NSMutableArray *tempArr = [NSMutableArray array];
            for (NSInteger i = 0; i < self.selectValueArr.count; i++) {
                if (i == component) {
                    [tempArr addObject:self.dataSourceArr[component][row]];
                } else {
                    [tempArr addObject:self.selectValueArr[i]];
                }
            }
            self.selectValueArr = tempArr;

            if (self.isAutoSelect) {
                if(self.resultBlock) {
                    self.resultBlock([self.selectValueArr copy]);
                }
            }
        }
            break;
            
        default:
            break;
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    //[pickerView.subviews count] = 2(iOS 14) ; = 3 (before iOS 14)
//    ((UIView *)[pickerView.subviews objectAtIndex:1]).backgroundColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0];
//    ((UIView *)[pickerView.subviews objectAtIndex:2]).backgroundColor = [UIColor colorWithRed:195/255.0 green:195/255.0 blue:195/255.0 alpha:1.0];
    
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18.0f * kScaleFit];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.5f;
    if (self.type == BRStringPickerComponentSingle) {
        label.frame = CGRectMake(0, 0, self.alertView.frame.size.width, 35.0f * kScaleFit);
        label.text = self.dataSourceArr[row];
    } else if (self.type == BRStringPickerComponentMore) {
        label.frame = CGRectMake(0, 0, self.alertView.frame.size.width / [self.dataSourceArr[component] count], 35.0f * kScaleFit);
        label.text = self.dataSourceArr[component][row];
    }
    
    return label;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 35.0f * kScaleFit;
}

- (void)didTapBackgroundView:(UITapGestureRecognizer *)sender {
    [self dismissWithAnimation:NO];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)clickLeftBtn {
    [self dismissWithAnimation:YES];
    if (self.cancelBlock) {
        self.cancelBlock();
    }
}

- (void)clickRightBtn {
    [self dismissWithAnimation:YES];
    if(_resultBlock) {
        if (self.type == BRStringPickerComponentSingle) {
            _resultBlock(self.selectValue);
        } else if (self.type == BRStringPickerComponentMore) {
            _resultBlock(self.selectValueArr);
        }
    }
}

- (void)showWithAnimation:(BOOL)animation {
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    [keyWindow addSubview:self];
    if (animation) {
        CGRect rect = self.alertView.frame;
        rect.origin.y = SCREEN_HEIGHT;
        self.alertView.frame = rect;
        [UIView animateWithDuration:0.3 animations:^{
            CGRect rect = self.alertView.frame;
            rect.origin.y -= kPickerHeight + kTopViewHeight + BR_BOTTOM_MARGIN;
            self.alertView.frame = rect;
        }];
    }
}

- (void)dismissWithAnimation:(BOOL)animation {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect rect = self.alertView.frame;
        rect.origin.y += kPickerHeight + kTopViewHeight + BR_BOTTOM_MARGIN;
        self.alertView.frame = rect;
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (NSArray *)dataSourceArr {
    if (!_dataSourceArr) {
        _dataSourceArr = [NSArray array];
    }
    return _dataSourceArr;
}

- (NSMutableArray *)selectValueArr {
    if (!_selectValueArr) {
        _selectValueArr = [[NSMutableArray alloc]init];
    }
    return _selectValueArr;
}

@end
