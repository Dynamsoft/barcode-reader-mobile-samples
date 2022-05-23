//
//  TemplateView.m
//  PerformanceSettingsObjC
//
//  Created by dynamsoft on 5/20/22.
//

#import "TemplateView.h"
#import "BasicTableViewCell.h"

static NSString *singleBarcodeTag              = @"100";
static NSString *speedFirstTag                 = @"101";
static NSString *readRateFirstTag              = @"102";
static NSString *accuracyFirstTag              = @"103";

@interface TemplateView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *templateDataArray;
    NSMutableDictionary *recordTemplateSelectedStateDic;
}

@property (nonatomic, strong) UITableView *templateTableView;

/// Save current templateStyle.
@property (nonatomic, assign) EnumTemplateType currentTemplateType;

@end

@implementation TemplateView

+ (CGFloat)getHeight {
    return 4 * kCellHeight;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.currentTemplateType = EnumTemplateTypeSingleBarcode;
        [self handleData];
        [self setupUI];
    }
    return self;
}

- (void)handleData {
    templateDataArray = @[@{@"cellName":@"Single Barcode", @"tag":singleBarcodeTag},
                          @{@"cellName":@"Speed First", @"tag":speedFirstTag},
                          @{@"cellName":@"Read Rate First", @"tag":readRateFirstTag},
                          @{@"cellName":@"Accuracy First", @"tag":accuracyFirstTag}
    ];
    
    recordTemplateSelectedStateDic = [NSMutableDictionary dictionary];
    for (NSDictionary *templateDic in templateDataArray) {
        NSString *cellName = [templateDic valueForKey:@"cellName"];
        NSInteger tag = [[templateDic valueForKey:@"tag"] integerValue];
        if (tag == [singleBarcodeTag integerValue]) {
            [recordTemplateSelectedStateDic setValue:@(1) forKey:cellName];
        } else {
            [recordTemplateSelectedStateDic setValue:@(0) forKey:cellName];
        }
    }
}

- (void)setupUI {
    [self addSubview:self.templateTableView];
}

//MARK: UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return templateDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [BasicTableViewCell cellHeight];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemDic = templateDataArray[indexPath.row];
    NSString *title = [itemDic valueForKey:@"cellName"];
    NSInteger templateSelectedState = [[recordTemplateSelectedStateDic valueForKey:title] integerValue];
    static NSString *identifier = @"basicCellIdentifier";
    BasicTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[BasicTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    weakSelfs(self)
    cell.questionBlock = ^{
        [weakSelf handleQuestionWithIndexPath:indexPath];
    };
    [cell updateUIWithTitle:title andOptionalState:templateSelectedState];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *itemDic = templateDataArray[indexPath.row];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];

    [recordTemplateSelectedStateDic removeAllObjects];
    for (NSDictionary *templateDic in templateDataArray) {
        NSString *cellName = [templateDic valueForKey:@"cellName"];
        NSInteger tag = [[templateDic valueForKey:@"tag"] integerValue];
        if (tag == selectTag) {
            [recordTemplateSelectedStateDic setValue:@(1) forKey:cellName];
        } else {
            [recordTemplateSelectedStateDic setValue:@(0) forKey:cellName];
        }
    }
    
    [self.templateTableView reloadData];
    
    if (selectTag == [singleBarcodeTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeSingleBarcode;
    } else if (selectTag == [speedFirstTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeSpeedFirst;
    } else if (selectTag == [readRateFirstTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeReadRateFirst;
    } else if (selectTag == [accuracyFirstTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeAccuracyFirst;
    }
    
    if ([self.delegate respondsToSelector:@selector(transformModeAction:templateType:)]) {
        [self.delegate transformModeAction:self templateType:self.currentTemplateType];
    }

}

/// Handle question.
- (void)handleQuestionWithIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *itemDic = templateDataArray[indexPath.row];
    NSInteger selectTag = [[itemDic valueForKey:@"tag"] integerValue];
    if (selectTag == [singleBarcodeTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeSingleBarcode;
    } else if (selectTag == [speedFirstTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeSpeedFirst;
    } else if (selectTag == [readRateFirstTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeReadRateFirst;
    } else if (selectTag == [accuracyFirstTag integerValue]) {
        self.currentTemplateType = EnumTemplateTypeAccuracyFirst;
    }
    
    if ([self.delegate respondsToSelector:@selector(explainAction:templateType:)]) {
        [self.delegate explainAction:self templateType:self.currentTemplateType];
    }
}

//MARK: Lazy loading
- (UITableView *)templateTableView {
    if (!_templateTableView) {
        _templateTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.width, templateDataArray.count * kCellHeight) style:UITableViewStylePlain];
        _templateTableView.backgroundColor = [UIColor clearColor];
        _templateTableView.bounces = NO;
        _templateTableView.delegate = self;
        _templateTableView.dataSource = self;
        _templateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _templateTableView;
}

@end
