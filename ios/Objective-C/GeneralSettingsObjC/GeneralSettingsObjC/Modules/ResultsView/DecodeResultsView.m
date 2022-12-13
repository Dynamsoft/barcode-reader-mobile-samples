//
//  DecodeResultsView.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/24.
//

#import "DecodeResultsView.h"
#import "DecodeResultsCentreTableViewCell.h"
#import "DecodeResultsBottomTableViewCell.h"

#define kResultBottomLocationBorderColor [UIColor clearColor]

@interface DecodeResultsView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *resultsArray;
    NSMutableArray *recordCellHeightArray;
    
    NSMutableDictionary *recordCopyStateDic;
    EnumDecodeResultsLocation resultLocation;
}

@property (nonatomic, strong) UIView *resultBackgroundView;

@property (nonatomic, strong) UITableView *resultTableView;

@property (nonatomic, strong) UIView *headerBackgroundView;

@property (nonatomic, strong) UILabel *resultsLabel;

@property (nonatomic, strong) UILabel *totalNumberLabel;

@property (nonatomic, strong) UIView *footerBackgroundView;

@property (nonatomic, strong) UIButton *continueButton;

@property (nonatomic, strong) UILabel *bottomTypeTotalResultNumLabel;

@property (nonatomic, copy) void(^completion)(void);

@end

@implementation DecodeResultsView


- (instancetype)initWithFrame:(CGRect)frame location:(EnumDecodeResultsLocation)location withTargetVC:(UIViewController *)targetVC
{
    self = [super initWithFrame:frame];
    if (self) {
        recordCellHeightArray = [NSMutableArray array];
        recordCopyStateDic = [NSMutableDictionary dictionary];
        resultLocation = location;
        
        [self setupUI];
        
        [targetVC.view addSubview:self];
        self.hidden = YES;
    }
    return self;
}

// MARK: - SetupUI
- (void)setupUI
{
    CGFloat resultsTableViewHeight = 0;
    self.height = KDecodeResultBottomTypeBackgroundHeight;
    self.top = kScreenHeight - KDecodeResultBottomTypeBackgroundHeight - kTabBarAreaHeight;
    
    self.resultBackgroundView.frame = CGRectMake(0, 0, kScreenWidth, self.height);
    [self addSubview:self.resultBackgroundView];
    
    self.resultTableView.frame = CGRectMake(0, kDecodeResultsHeaderHeight, self.resultBackgroundView.width, resultsTableViewHeight);
    [self.resultBackgroundView addSubview:self.resultTableView];
    
    self.headerBackgroundView.frame = CGRectMake(0, 0, self.resultBackgroundView.width, kDecodeResultsHeaderHeight);
    [self.resultBackgroundView addSubview:self.headerBackgroundView];
    
    self.resultsLabel.frame = CGRectMake(10, 0, 100, self.headerBackgroundView.height);
    [self.headerBackgroundView addSubview:self.resultsLabel];
    
    self.totalNumberLabel.frame = CGRectMake(self.resultBackgroundView.width - 10 - 100, 0, 100, self.headerBackgroundView.height);
    [self.headerBackgroundView addSubview:self.totalNumberLabel];
    
    self.footerBackgroundView.frame = CGRectMake(0, self.resultBackgroundView.height - kDecodeResultsFooterHeight, self.resultBackgroundView.width, kDecodeResultsFooterHeight);
    [self.resultBackgroundView addSubview:self.footerBackgroundView];
    
    self.continueButton.frame = CGRectMake(self.footerBackgroundView.width - 10 - 100, 0, 100, self.footerBackgroundView.height);
    [self.footerBackgroundView addSubview:self.continueButton];

    self.bottomTypeTotalResultNumLabel.frame = CGRectMake(0, 0, self.resultTableView.width, kDecodeResultBottomTypeTableHeaderViewHeight);
    self.resultTableView.tableHeaderView = self.bottomTypeTotalResultNumLabel;

    [self updateLocation:resultLocation];
}

- (void)clickContinueButton
{
    if (self.completion) {
        self.hidden = YES;
        self.completion();
    }
}

// MARK: - UpdateLocation
/// updateLocation
- (void)updateLocation:(EnumDecodeResultsLocation)location
{
    resultsArray = @[];
    resultLocation = location;
    
    if (location == EnumDecodeResultsLocationCentre) {
        self.hidden = YES;
        self.resultBackgroundView.backgroundColor = [UIColor whiteColor];
        self.resultBackgroundView.layer.borderWidth = 0;
        self.resultBackgroundView.layer.borderColor = kResultBottomLocationBorderColor.CGColor;
        self.resultBackgroundView.layer.cornerRadius = 5;

        self.resultTableView.backgroundColor = [UIColor whiteColor];

        self.headerBackgroundView.hidden = NO;
        self.footerBackgroundView.hidden = NO;
        self.resultsLabel.hidden = NO;
        self.totalNumberLabel.hidden = NO;
        self.continueButton.hidden = NO;
        self.bottomTypeTotalResultNumLabel.hidden = YES;

    } else if (location == EnumDecodeResultsLocationBottom) {
        self.hidden = NO;
        self.resultBackgroundView.backgroundColor = [UIColor clearColor];
        self.resultBackgroundView.layer.borderWidth = 1;
        self.resultBackgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.resultBackgroundView.layer.cornerRadius = 5;

        self.resultTableView.backgroundColor = [UIColor clearColor];

        self.headerBackgroundView.hidden = YES;
        self.footerBackgroundView.hidden = YES;
        self.resultsLabel.hidden = YES;
        self.totalNumberLabel.hidden = YES;
        self.continueButton.hidden = YES;
        self.bottomTypeTotalResultNumLabel.hidden = NO;
    }
    [self refreshData];
}

// MARK: - ShowDecodeResult
- (void)showDecodeResultWith:(NSArray<iTextResult *> *)results location:(EnumDecodeResultsLocation)location completion:(void (^)(void))completion
{
    self.hidden = NO;
    resultsArray = results;
    resultLocation = location;
    self.completion = completion;
    
    [self refreshData];
}

// MARK: - RefreshUI with results
- (void)refreshData
{
    if (resultLocation == EnumDecodeResultsLocationCentre) {
        
        CGFloat resultBackgroundHeight = 0;
        CGFloat resultsTableViewHeight = 0;
        
        [recordCellHeightArray removeAllObjects];
        if (resultsArray.count <= 3) {
            
            CGFloat cellHeight = 0;
            for (int i = 0; i < resultsArray.count; i++) {
                iTextResult *textResult = resultsArray[i];
                NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
                CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
                
                cellHeight = 35 + textHeight + 15;
                if (cellHeight <= kDecodeResultsCellHeight) {
                    cellHeight = kDecodeResultsCellHeight;
                }
                
                [recordCellHeightArray addObject:@(cellHeight)];
                resultsTableViewHeight += cellHeight;
                
                [recordCopyStateDic setValue:@"1" forKey:[NSString stringWithFormat:@"%@%d", textResult.barcodeText, i]];
            }
            
            resultBackgroundHeight = kDecodeResultsHeaderHeight + resultsTableViewHeight + kDecodeResultsFooterHeight;
        } else {
            
            CGFloat cellHeight = 0;
            for (int i = 0; i < resultsArray.count; i++) {
                iTextResult *textResult = resultsArray[i];
                NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
                CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
                
                cellHeight = 35 + textHeight + 15;
                if (cellHeight <= kDecodeResultsCellHeight) {
                    cellHeight = kDecodeResultsCellHeight;
                }
                
                [recordCellHeightArray addObject:@(cellHeight)];
                if (i < 3) {
                    resultsTableViewHeight += cellHeight;
                }
                [recordCopyStateDic setValue:@"1" forKey:[NSString stringWithFormat:@"%@%d", textResult.barcodeText, i]];
            }

            resultBackgroundHeight = kDecodeResultsHeaderHeight + resultsTableViewHeight + kDecodeResultsFooterHeight;
        }
        
        self.height = resultBackgroundHeight;
        self.top = (kScreenHeight - resultBackgroundHeight) / 2.0;
        
        self.resultBackgroundView.frame = CGRectMake((self.width - kDecodeResultsBackgroundWidth) / 2.0, 0, kDecodeResultsBackgroundWidth, resultBackgroundHeight);
        self.resultTableView.frame = CGRectMake(0, kDecodeResultsHeaderHeight, self.resultBackgroundView.width, resultsTableViewHeight);
        self.resultTableView.tableHeaderView = nil;
        [self.resultTableView reloadData];

        if (resultsArray.count <= 1) {
            self.resultsLabel.text = @"Result";
        } else {
            self.resultsLabel.text = @"Result(s)";
        }
        self.resultsLabel.frame = CGRectMake(10, 0, 100, self.headerBackgroundView.height);
        
        self.totalNumberLabel.text = [NSString stringWithFormat:@"Total: %ld", resultsArray.count];
        self.totalNumberLabel.frame = CGRectMake(self.resultBackgroundView.width - 10 - 100, 0, 100, self.headerBackgroundView.height);

        self.footerBackgroundView.frame = CGRectMake(0, self.resultBackgroundView.height - kDecodeResultsFooterHeight, self.resultBackgroundView.width, kDecodeResultsFooterHeight);
        self.continueButton.frame = CGRectMake(self.footerBackgroundView.width - 10 - 100, 0, 100, self.footerBackgroundView.height);
    } else if (resultLocation == EnumDecodeResultsLocationBottom) {
        
        self.height = KDecodeResultBottomTypeBackgroundHeight;
        self.top = kScreenHeight - KDecodeResultBottomTypeBackgroundHeight - kTabBarAreaHeight;
        
        self.resultBackgroundView.frame = CGRectMake(0, 0, kScreenWidth, self.height);

        self.resultTableView.frame = CGRectMake(0, 0, self.resultBackgroundView.width, self.resultBackgroundView.height);

        [recordCellHeightArray removeAllObjects];
        CGFloat cellHeight = 0;
        for (iTextResult *textResult in resultsArray) {
            NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
            CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultBottomTypeContentCellTextFont AndComponentWidth:kDecodeResultBottomTypeContentCellWidth];
            
            cellHeight = 25 + textHeight + 15;
            if (cellHeight <= kDecodeResultBottomTypeContentCellHeight) {
                cellHeight = kDecodeResultBottomTypeContentCellHeight;
            }
            
            [recordCellHeightArray addObject:@(cellHeight)];
        }
        
        [self.resultTableView reloadData];
        
        self.bottomTypeTotalResultNumLabel.frame = CGRectMake(0, 0, self.resultTableView.width, kDecodeResultBottomTypeTableHeaderViewHeight);
        
        if (resultsArray.count <= 1) {
            self.bottomTypeTotalResultNumLabel.text = [NSString stringWithFormat:@"Total Result:%ld", resultsArray.count];
        } else {
            self.bottomTypeTotalResultNumLabel.text = [NSString stringWithFormat:@"Total Result(s):%ld", resultsArray.count];
        }
        self.bottomTypeTotalResultNumLabel.hidden = resultsArray.count > 0 ? NO : YES;
        self.resultTableView.tableHeaderView = self.bottomTypeTotalResultNumLabel;
    }
}

// MARK: - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return resultsArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [recordCellHeightArray[indexPath.row] floatValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (resultLocation == EnumDecodeResultsLocationCentre) {
        iTextResult *result = resultsArray[indexPath.row];
        NSString *copyState = [recordCopyStateDic valueForKey:[NSString stringWithFormat:@"%@%ld", result.barcodeText, indexPath.row]];
        
        static NSString *identifier = @"DecodeResultCentreCell";
        DecodeResultsCentreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[DecodeResultsCentreTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        weakSelfs(self)
        cell.copyBlock = ^{
            [weakSelf refreshCopyStateWithIndexPath:indexPath];
        };
        
        [cell updateCopyState:copyState];
        [cell updateUIWithResult:result];
        
        if (indexPath.row < 9) {
            cell.countNumberLabel.text = [NSString stringWithFormat:@"0%ld", (long)indexPath.row + 1];
        } else {
            cell.countNumberLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
        }
        
        return cell;
    } else if (resultLocation == EnumDecodeResultsLocationBottom) {
        iTextResult *result = resultsArray[indexPath.row];
        static NSString *identifier = @"DecodeResultBottomCell";
        DecodeResultsBottomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[DecodeResultsBottomTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }

        [cell updateUIWithResult:result];

        return cell;
    }
   
    return [UITableViewCell new];
}

- (void)refreshCopyStateWithIndexPath:(NSIndexPath *)indexPath
{
    iTextResult *result = resultsArray[indexPath.row];
    [recordCopyStateDic setValue:@"0" forKey:[NSString stringWithFormat:@"%@%ld", result.barcodeText, indexPath.row]];
    
    [self.resultTableView reloadData];
}


// MARK: - LazyLoading
- (UITableView *)resultTableView {
    if (!_resultTableView) {
        _resultTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _resultTableView.backgroundColor = [UIColor whiteColor];
        _resultTableView.delegate = self;
        _resultTableView.dataSource = self;
        _resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _resultTableView.showsVerticalScrollIndicator = NO;
    }
    return  _resultTableView;
}

- (UIView *)resultBackgroundView
{
    if (!_resultBackgroundView) {
        _resultBackgroundView = [[UIView alloc] init];
        _resultBackgroundView.backgroundColor = [UIColor whiteColor];
        _resultBackgroundView.layer.cornerRadius = 5;
    }
    return _resultBackgroundView;
}

- (UIView *)headerBackgroundView
{
    if (!_headerBackgroundView) {
        _headerBackgroundView = [[UIView alloc] init];
        _headerBackgroundView.backgroundColor = [UIColor clearColor];
        _headerBackgroundView.layer.cornerRadius = 5;
    }
    return _headerBackgroundView;
}

- (UILabel *)resultsLabel
{
    if (!_resultsLabel) {
        _resultsLabel = [[UILabel alloc] init];
        _resultsLabel.font = kFont_Regular(18);
        _resultsLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _resultsLabel;
}

- (UILabel *)totalNumberLabel
{
    if (!_totalNumberLabel) {
        _totalNumberLabel = [[UILabel alloc] init];
        _totalNumberLabel.font = kFont_Regular(18);
        _totalNumberLabel.textAlignment = NSTextAlignmentRight;
    }
    return _totalNumberLabel;
}

- (UIView *)footerBackgroundView
{
    if (!_footerBackgroundView) {
        _footerBackgroundView = [[UIView alloc] init];
        _footerBackgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    }
    return _footerBackgroundView;
}

- (UIButton *)continueButton
{
    if (!_continueButton) {
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _continueButton.titleLabel.font = kFont_Regular(15);
        [_continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [_continueButton setTitleColor:[UIColor colorWithRed:62/255.0 green:130/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
        _continueButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_continueButton addTarget:self action:@selector(clickContinueButton) forControlEvents:UIControlEventTouchUpInside];
    }
    return _continueButton;
}

- (UILabel *)bottomTypeTotalResultNumLabel
{
    if (!_bottomTypeTotalResultNumLabel) {
        _bottomTypeTotalResultNumLabel = [[UILabel alloc] init];
        _bottomTypeTotalResultNumLabel.backgroundColor = [UIColor clearColor];
        _bottomTypeTotalResultNumLabel.textColor = [UIColor whiteColor];
        _bottomTypeTotalResultNumLabel.font = kDecodeResultBottomTypeContentCellTextFont;
        _bottomTypeTotalResultNumLabel.textAlignment = NSTextAlignmentCenter;
        _bottomTypeTotalResultNumLabel.layer.cornerRadius = 5;
        _bottomTypeTotalResultNumLabel.layer.masksToBounds = YES;
    }
    return _bottomTypeTotalResultNumLabel;
}

@end
