//
//  PullListView.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/29.
//

#import "PullListView.h"

@interface PullListView ()<UIPickerViewDelegate, UIPickerViewDataSource>
{
    NSString *pullViewTitle;
    NSArray *pullListDataArray;
    
    /// Record currentSelectedDic.
    NSDictionary *recordCurrerntSelectedDic;
}

@property (nonatomic, strong) UIView *backgroundMaskView;

@property (nonatomic, strong) UIView *pullListBackgroundView;

@property (nonatomic, strong) UIView *headerView;

@property (nonatomic, strong) UIButton *cancelButton;

@property (nonatomic, strong) UIButton *confirmButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIPickerView *pickerView;

/// Selected completion block.
@property (nonatomic, copy) void(^completion)(NSDictionary *selectedDic);

@end

@implementation PullListView

+ (void)showPullListViewWithArray:(NSArray *)pullListArray titleName:(NSString *)title selectedDicInfo:(NSDictionary *)selectedDicInfo completion:(void (^)(NSDictionary *selectedDic))completion
{
    PullListView *pullListView = [[PullListView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight) WithArray:pullListArray titleName:title selectedDicInfo:selectedDicInfo completion:completion];
    
    [pullListView show];
}

- (instancetype)initWithFrame:(CGRect)frame WithArray:(NSArray *)pullListArray titleName:(NSString *)title selectedDicInfo:(NSDictionary *)selectedDicInfo completion:(void (^)(NSDictionary *selectedDic))completion
{
    self = [super initWithFrame:frame];
    if (self) {
        pullViewTitle = title;
        pullListDataArray = pullListArray;
        recordCurrerntSelectedDic = selectedDicInfo;
        self.completion = completion;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.backgroundMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, self.height)];
    self.backgroundMaskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    self.backgroundMaskView.userInteractionEnabled = YES;
    [self addSubview:self.backgroundMaskView];
    
    CGFloat pullListHeight = 0;
    if (kIs_iPhoneXAndLater) {
        pullListHeight = 270 * kScreenAdaptationRadio + 34;
    } else {
        pullListHeight = 270 * kScreenAdaptationRadio;
    }
    
    self.pullListBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - pullListHeight, kScreenWidth, pullListHeight)];
    self.pullListBackgroundView.backgroundColor = [UIColor whiteColor];
    [self.backgroundMaskView addSubview:self.pullListBackgroundView];
    
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 40 * kScreenAdaptationRadio)];
    self.headerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
    [self.pullListBackgroundView addSubview:self.headerView];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((kScreenWidth - 100 * kScreenAdaptationRadio) / 2.0, 0, 100 * kScreenAdaptationRadio, self.headerView.height)];
    self.titleLabel.text = pullViewTitle;
    self.titleLabel.textColor = [UIColor grayColor];
    self.titleLabel.font = kFont_Regular(13 * kScreenAdaptationRadio);
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.headerView addSubview:self.titleLabel];
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelButton.frame = CGRectMake(0, 0, 60 * kScreenAdaptationRadio, self.headerView.height);
    [self.cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = kFont_Regular(12 * kScreenAdaptationRadio);
    [self.cancelButton addTarget:self action:@selector(clickCancel) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.cancelButton];
    
    self.confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmButton.frame = CGRectMake(kScreenWidth - 60 * kScreenAdaptationRadio, 0, 60 * kScreenAdaptationRadio, self.headerView.height);
    [self.confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    [self.confirmButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.confirmButton.titleLabel.font = kFont_Regular(12 * kScreenAdaptationRadio);
    [self.confirmButton addTarget:self action:@selector(clickConfirm) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView addSubview:self.confirmButton];
    
    // PickerView
    CGFloat pickViewHeight = 0;
    if (kIs_iPhoneXAndLater) {
        pickViewHeight = pullListHeight - self.headerView.height - 34;
    } else {
        pickViewHeight = pullListHeight - self.headerView.height;
    }
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.headerView.bottom, kScreenWidth, pickViewHeight)];
    self.pickerView.backgroundColor = [UIColor whiteColor];
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    [self.pullListBackgroundView addSubview:self.pickerView];
    
    // Jump to seleted row.
    NSString *selectedName = [recordCurrerntSelectedDic valueForKey:@"showName"];
    NSInteger selectedRow = 0;
    for (int i = 0; i < pullListDataArray.count; i++) {
        NSDictionary *showDic = pullListDataArray[i];
        NSString *showName = [showDic valueForKey:@"showName"];
        if ([selectedName isEqualToString:showName]) {
            selectedRow = i;
            break;
        }
    }
    
    [self.pickerView selectRow:selectedRow inComponent:0 animated:YES];
    
}

/// Click maskView.
- (void)maskClick
{
    [self removeFromSuperview];
    
    [self dismiss];
}

/// Click cancel.
- (void)clickCancel
{
    [self dismiss];
}

/// Click confirm.
- (void)clickConfirm
{
    if (self.completion) {
        self.completion(recordCurrerntSelectedDic);
    }
    [self dismiss];
}

//MARK: - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return kScreenWidth;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35 * kScreenAdaptationRadio;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return pullListDataArray.count;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    NSDictionary *pullListDic = pullListDataArray[row];
    NSString *showName = [pullListDic valueForKey:@"showName"];
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 35 * kScreenAdaptationRadio)];
    contentLabel.text = showName;
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.font = kFont_Regular(16 * kScreenAdaptationRadio);
    return contentLabel;
}


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    recordCurrerntSelectedDic = pullListDataArray[row];
}


- (void)show
{
    self.pullListBackgroundView.top = kScreenHeight;
    [UIView animateWithDuration:0.2 animations:^{
        self.pullListBackgroundView.top = kScreenHeight - self.pullListBackgroundView.height;
    } completion:^(BOOL finished) {
        
    }];
    
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    [window addSubview:self];
}

- (void)dismiss
{

    [UIView animateWithDuration:0.2 animations:^{
        self.pullListBackgroundView.top = kScreenHeight;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }

    }];
}

@end
