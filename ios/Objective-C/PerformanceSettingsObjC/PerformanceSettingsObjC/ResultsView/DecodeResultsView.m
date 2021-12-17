//
//  DecodeResultsView.m
//  GeneralSettings
//
//  Created by dynamsoft on 2021/11/24.
//

#import "DecodeResultsView.h"
#import "DecodeResultsCentreTableViewCell.h"
#import "DecodeResultsBottomTableViewCell.h"

@interface DecodeResultsView ()<UITableViewDelegate, UITableViewDataSource>
{
    NSArray *resultsArray;
    NSMutableArray *recordCellHeightArray;
    
    NSMutableDictionary *recordCopyStateDic;
    EnumDecodeResultsLocation resultlocation;
}

@property (nonatomic, strong) UIView *resultBackgroundView;

@property (nonatomic, strong) UITableView *resultTableView;

@property (nonatomic, strong) UIView *headerBackgroundView;

@property (nonatomic, strong) UILabel *resultsLabel;

@property (nonatomic, strong) UILabel *totalNumberLabel;

@property (nonatomic, strong) UIView *footerBackgroundView;

@property (nonatomic, strong) UIButton *continueButton;

@property (nonatomic, strong) UIView * maskView;

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
        resultlocation = location;
        
        [self setupUI];
        
        [targetVC.view addSubview:self];
        self.hidden = YES;
    }
    return self;
}

//MARK: setupUI
- (void)setupUI
{
    if (resultlocation == EnumDecodeResultsLocationCentre) {
        // origin UI
        self.maskView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight);
        self.maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.maskView];
     
        CGFloat resultBackgroundHeight = 0;
        CGFloat resultsTableViewHeight = 0;
        
        [recordCellHeightArray removeAllObjects];
        if (resultsArray.count <= 3) {
            
           
            CGFloat cellHeight = 0;
            for (iTextResult *textResult in resultsArray) {
                NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
                CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
                
                cellHeight = 35 * kScreenAdaptationRadio + textHeight + 15 * kScreenAdaptationRadio;
                if (cellHeight <= kDecodeResultsCellHeight) {
                    cellHeight = kDecodeResultsCellHeight;
                }
                
                [recordCellHeightArray addObject:@(cellHeight)];
                resultsTableViewHeight += cellHeight;
                
                [recordCopyStateDic setValue:@"1" forKey:textResult.barcodeText];
            }
            
            resultBackgroundHeight = kDecodeResultsHeaderHeight + resultsTableViewHeight + kDecodeResultsFooterHeight;
        } else {
            
            CGFloat cellHeight = 0;
            for (int i = 0; i < resultsArray.count; i++) {
                iTextResult *textResult = resultsArray[i];
                NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
                CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
                
                cellHeight = 35 * kScreenAdaptationRadio + textHeight + 15 * kScreenAdaptationRadio;
                if (cellHeight <= kDecodeResultsCellHeight) {
                    cellHeight = kDecodeResultsCellHeight;
                }
                
                [recordCellHeightArray addObject:@(cellHeight)];
                if (i < 3) {
                    resultsTableViewHeight += cellHeight;
                }
                [recordCopyStateDic setValue:@"1" forKey:textResult.barcodeText];
            }

            resultBackgroundHeight = kDecodeResultsHeaderHeight + resultsTableViewHeight + kDecodeResultsFooterHeight;
        
        }
        
        self.resultBackgroundView.frame = CGRectMake((kScreenWidth - kDecodeResultsBackgroundWidth) / 2.0, (self.maskView.height - resultBackgroundHeight) / 2.0, kDecodeResultsBackgroundWidth, resultBackgroundHeight);
        self.resultBackgroundView.backgroundColor = [UIColor whiteColor];
        self.resultBackgroundView.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        [self.maskView addSubview:self.resultBackgroundView];
        
        self.resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kDecodeResultsHeaderHeight, self.resultBackgroundView.width, resultsTableViewHeight) style:UITableViewStylePlain];
        self.resultTableView.backgroundColor = [UIColor whiteColor];
        self.resultTableView.delegate = self;
        self.resultTableView.dataSource = self;
        self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.resultTableView.showsVerticalScrollIndicator = NO;
        [self.resultBackgroundView addSubview:self.resultTableView];
        
        // tableHeaderView
        self.bottomTypeTotalResultNumLabel.frame = CGRectMake(0, 0, self.resultTableView.width, 0 * kScreenAdaptationRadio);
        self.bottomTypeTotalResultNumLabel.backgroundColor = [UIColor clearColor];
        self.bottomTypeTotalResultNumLabel.textColor = [UIColor whiteColor];
        self.bottomTypeTotalResultNumLabel.font = kDecodeResultBottomTypeContentCellTextFont;
        self.bottomTypeTotalResultNumLabel.textAlignment = NSTextAlignmentCenter;
        self.bottomTypeTotalResultNumLabel.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        self.bottomTypeTotalResultNumLabel.layer.masksToBounds = YES;
        self.resultTableView.tableHeaderView = self.bottomTypeTotalResultNumLabel;
        
        // header
        self.headerBackgroundView.frame = CGRectMake(0, 0, self.resultBackgroundView.width, kDecodeResultsHeaderHeight);
        self.headerBackgroundView.backgroundColor = [UIColor clearColor];
        self.headerBackgroundView.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        [self.resultBackgroundView addSubview:self.headerBackgroundView];
        
        self.resultsLabel.frame = CGRectMake(10 * kScreenAdaptationRadio, 0, 100 * kScreenAdaptationRadio, self.headerBackgroundView.height);
        if (resultsArray.count <= 1) {
            self.resultsLabel.text = @"Result";
        } else {
            self.resultsLabel.text = @"Result(s)";
        }
        
        self.resultsLabel.font = kFont_Regular(18 * kScreenAdaptationRadio);
        self.resultsLabel.textAlignment = NSTextAlignmentLeft;
        [self.headerBackgroundView addSubview:self.resultsLabel];
        
        self.totalNumberLabel.frame = CGRectMake(self.resultBackgroundView.width - 10 * kScreenAdaptationRadio - 100 * kScreenAdaptationRadio, 0, 100 * kScreenAdaptationRadio, self.headerBackgroundView.height);
        self.totalNumberLabel.text = [NSString stringWithFormat:@"Total: %ld", resultsArray.count];
        self.totalNumberLabel.font = kFont_Regular(18 * kScreenAdaptationRadio);
        self.totalNumberLabel.textAlignment = NSTextAlignmentRight;
        [self.headerBackgroundView addSubview:self.totalNumberLabel];
        
        // footer
        self.footerBackgroundView.frame = CGRectMake(0, self.resultBackgroundView.height - kDecodeResultsFooterHeight, self.resultBackgroundView.width, kDecodeResultsFooterHeight);
        self.footerBackgroundView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
        [self.resultBackgroundView addSubview:self.footerBackgroundView];
        
        self.continueButton.frame = CGRectMake(self.footerBackgroundView.width - 10 * kScreenAdaptationRadio - 100 * kScreenAdaptationRadio, 0, 100 * kScreenAdaptationRadio, self.footerBackgroundView.height);
        self.continueButton.titleLabel.font = kFont_Regular(15 * kScreenAdaptationRadio);
        [self.continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [self.continueButton setTitleColor:[UIColor colorWithRed:62/255.0 green:130/255.0 blue:249/255.0 alpha:1] forState:UIControlStateNormal];
        self.continueButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.continueButton addTarget:self action:@selector(clickContinueButton) forControlEvents:UIControlEventTouchUpInside];
        [self.footerBackgroundView addSubview:self.continueButton];
    } else if (resultlocation == EnumDecodeResultsLocationBottom) {
        // origin UI
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight)];
        self.maskView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.maskView];
        
        CGFloat resultBackgroundTop = resultBackgroundTop = self.maskView.height - KDecodeResultBottomTypeBackgroundHeight - kTabBarHeight;

        self.resultBackgroundView.frame = CGRectMake(0, resultBackgroundTop, kScreenWidth, KDecodeResultBottomTypeBackgroundHeight);
        self.resultBackgroundView.backgroundColor = [UIColor clearColor];
        self.resultBackgroundView.layer.borderWidth = 1 * kScreenAdaptationRadio;
        self.resultBackgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.resultBackgroundView.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        [self.maskView addSubview:self.resultBackgroundView];
        
        
        self.resultTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.resultBackgroundView.width, self.resultBackgroundView.height) style:UITableViewStylePlain];
        self.resultTableView.backgroundColor = [UIColor clearColor];
        self.resultTableView.delegate = self;
        self.resultTableView.dataSource = self;
        self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.resultBackgroundView addSubview:self.resultTableView];
        
        
        // tableHeaderView
        self.bottomTypeTotalResultNumLabel.frame = CGRectMake(0, 0, self.resultTableView.width, kDecodeResultBottomTypeTableHeaderViewHeight);
        self.bottomTypeTotalResultNumLabel.backgroundColor = [UIColor clearColor];
        self.bottomTypeTotalResultNumLabel.textColor = [UIColor whiteColor];
        self.bottomTypeTotalResultNumLabel.font = kDecodeResultBottomTypeContentCellTextFont;
        self.bottomTypeTotalResultNumLabel.textAlignment = NSTextAlignmentCenter;
        self.bottomTypeTotalResultNumLabel.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        self.bottomTypeTotalResultNumLabel.layer.masksToBounds = YES;
        self.resultTableView.tableHeaderView = self.bottomTypeTotalResultNumLabel;
    
    }
    
    
    
}

- (void)clickContinueButton
{
    if (self.completion) {
        self.hidden = YES;
        self.completion();
    }
}

//MARK: updateLocation
/// updateLocation
- (void)updateLocation:(EnumDecodeResultsLocation)location
{
    self.hidden = YES;
    if (location == EnumDecodeResultsLocationCentre) {
        
        self.maskView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight);
        self.maskView.backgroundColor = [UIColor clearColor];
        
        
        self.resultBackgroundView.backgroundColor = [UIColor whiteColor];
        self.resultBackgroundView.layer.borderWidth = 0 * kScreenAdaptationRadio;
        self.resultBackgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.resultBackgroundView.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        
        self.resultTableView.backgroundColor = [UIColor whiteColor];
        
        self.headerBackgroundView.hidden = NO;
        self.footerBackgroundView.hidden = NO;
        self.resultsLabel.hidden = NO;
        self.totalNumberLabel.hidden = NO;
        self.continueButton.hidden = NO;
        self.bottomTypeTotalResultNumLabel.hidden = YES;
        
        
    } else if (location == EnumDecodeResultsLocationBottom) {
        self.maskView.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNaviBarAndStatusBarHeight);
        self.maskView.backgroundColor = [UIColor clearColor];
        
        self.resultBackgroundView.backgroundColor = [UIColor clearColor];
        self.resultBackgroundView.layer.borderWidth = 1 * kScreenAdaptationRadio;
        self.resultBackgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.resultBackgroundView.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        
        self.resultTableView.backgroundColor = [UIColor clearColor];
        
        self.headerBackgroundView.hidden = YES;
        self.footerBackgroundView.hidden = YES;
        self.resultsLabel.hidden = YES;
        self.totalNumberLabel.hidden = YES;
        self.continueButton.hidden = YES;
        self.bottomTypeTotalResultNumLabel.hidden = NO;
        
    }
    
}

//MARK: showDecodeResult
- (void)showDecodeResultWith:(NSArray<iTextResult *> *)results location:(EnumDecodeResultsLocation)location completion:(void (^)(void))completion
{
    self.hidden = NO;
    resultsArray = results;
    resultlocation = location;
    self.completion = completion;
    
    [self refreshData];
}

//MARK: refreshUI with results
- (void)refreshData
{
    
  //  [self updateLocation:resultlocation];
    
    if (resultlocation == EnumDecodeResultsLocationCentre) {
        
        CGFloat resultBackgroundHeight = 0;
        CGFloat resultsTableViewHeight = 0;
        
        [recordCellHeightArray removeAllObjects];
        if (resultsArray.count <= 3) {
            
           
            CGFloat cellHeight = 0;
            for (iTextResult *textResult in resultsArray) {
                NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
                CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
                
                cellHeight = 35 * kScreenAdaptationRadio + textHeight + 15 * kScreenAdaptationRadio;
                if (cellHeight <= kDecodeResultsCellHeight) {
                    cellHeight = kDecodeResultsCellHeight;
                }
                
                [recordCellHeightArray addObject:@(cellHeight)];
                resultsTableViewHeight += cellHeight;
                
                [recordCopyStateDic setValue:@"1" forKey:textResult.barcodeText];
            }
            
            resultBackgroundHeight = kDecodeResultsHeaderHeight + resultsTableViewHeight + kDecodeResultsFooterHeight;
        } else {
            
            CGFloat cellHeight = 0;
            for (int i = 0; i < resultsArray.count; i++) {
                iTextResult *textResult = resultsArray[i];
                NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
                CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultContentCellTextFont AndComponentWidth:kDecodeResultContentCellWidth];
                
                cellHeight = 35 * kScreenAdaptationRadio + textHeight + 15 * kScreenAdaptationRadio;
                if (cellHeight <= kDecodeResultsCellHeight) {
                    cellHeight = kDecodeResultsCellHeight;
                }
                
                [recordCellHeightArray addObject:@(cellHeight)];
                if (i < 3) {
                    resultsTableViewHeight += cellHeight;
                }
                [recordCopyStateDic setValue:@"1" forKey:textResult.barcodeText];
            }

            resultBackgroundHeight = kDecodeResultsHeaderHeight + resultsTableViewHeight + kDecodeResultsFooterHeight;
        
        }
        
        self.resultBackgroundView.frame = CGRectMake((kScreenWidth - kDecodeResultsBackgroundWidth) / 2.0, (self.maskView.height - resultBackgroundHeight) / 2.0, kDecodeResultsBackgroundWidth, resultBackgroundHeight);
        self.resultBackgroundView.backgroundColor = [UIColor whiteColor];
        self.resultTableView.frame = CGRectMake(0, kDecodeResultsHeaderHeight, self.resultBackgroundView.width, resultsTableViewHeight);
        [self.resultTableView reloadData];
        
        self.bottomTypeTotalResultNumLabel.frame = CGRectMake(0, 0, self.resultTableView.width,0);
        
        // header
        if (resultsArray.count <= 1) {
            self.resultsLabel.text = @"Result";
        } else {
            self.resultsLabel.text = @"Result(s)";
        }
        
        self.totalNumberLabel.text = [NSString stringWithFormat:@"Total: %ld", resultsArray.count];
        
        // footer
        self.footerBackgroundView.frame = CGRectMake(0, self.resultBackgroundView.height - kDecodeResultsFooterHeight, self.resultBackgroundView.width, kDecodeResultsFooterHeight);
    } else if (resultlocation == EnumDecodeResultsLocationBottom) {
        
        CGFloat resultBackgroundTop = resultBackgroundTop = self.maskView.height - KDecodeResultBottomTypeBackgroundHeight - kTabBarHeight;
        self.resultBackgroundView.frame = CGRectMake(0, resultBackgroundTop, kScreenWidth, KDecodeResultBottomTypeBackgroundHeight);
        self.resultBackgroundView.backgroundColor = [UIColor clearColor];
        self.resultBackgroundView.layer.borderWidth = 1 * kScreenAdaptationRadio;
        self.resultBackgroundView.layer.borderColor = [UIColor whiteColor].CGColor;
        self.resultBackgroundView.layer.cornerRadius = 5 * kScreenAdaptationRadio;
        
        self.resultTableView.frame = CGRectMake(0, 0, self.resultBackgroundView.width, self.resultBackgroundView.height);
        self.resultTableView.backgroundColor = [UIColor clearColor];
        
        
        
        [recordCellHeightArray removeAllObjects];
        CGFloat cellHeight = 0;
        for (iTextResult *textResult in resultsArray) {
            NSString *text = [NSString stringWithFormat:@"%@%@", decodeResultTextPrefix, textResult.barcodeText];
            CGFloat textHeight = [[ToolsHandle toolManger] calculateHeightWithText:text font:kDecodeResultBottomTypeContentCellTextFont AndComponentWidth:kDecodeResultBottomTypeContentCellWidth];
            
            cellHeight = 25 * kScreenAdaptationRadio + textHeight + 15 * kScreenAdaptationRadio;
            if (cellHeight <= kDecodeResultBottomTypeContentCellHeight) {
                cellHeight = kDecodeResultBottomTypeContentCellHeight;
            }
            
            [recordCellHeightArray addObject:@(cellHeight)];
        }
        
        [self.resultTableView reloadData];
        
        self.bottomTypeTotalResultNumLabel.frame = CGRectMake(0, 0, self.resultTableView.width, kDecodeResultBottomTypeTableHeaderViewHeight);
        
        // header
        if (resultsArray.count <= 1) {
            self.bottomTypeTotalResultNumLabel.text = [NSString stringWithFormat:@"Total Result:%ld", resultsArray.count];
        } else {
            self.bottomTypeTotalResultNumLabel.text = [NSString stringWithFormat:@"Total Result(s):%ld", resultsArray.count];
        }
        
    }
    
    
}

#pragma mark - UITableViewDelegate
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
    if (resultlocation == EnumDecodeResultsLocationCentre) {
        iTextResult *result = resultsArray[indexPath.row];
        NSString *copyState = [recordCopyStateDic valueForKey:result.barcodeText];
        
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
    } else if (resultlocation == EnumDecodeResultsLocationBottom) {
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
    [recordCopyStateDic setValue:@"0" forKey:result.barcodeText];
    
    [self.resultTableView reloadData];
}


#pragma mark - LazyLoading
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
    }
    return _maskView;
}

- (UIView *)resultBackgroundView
{
    if (!_resultBackgroundView) {
        _resultBackgroundView = [[UIView alloc] init];
    }
    return _resultBackgroundView;
}

- (UIView *)headerBackgroundView
{
    if (!_headerBackgroundView) {
        _headerBackgroundView = [[UIView alloc] init];
    }
    return _headerBackgroundView;
}

- (UILabel *)resultsLabel
{
    if (!_resultsLabel) {
        _resultsLabel = [[UILabel alloc] init];
    }
    return _resultsLabel;
}

- (UILabel *)totalNumberLabel
{
    if (!_totalNumberLabel) {
        _totalNumberLabel = [[UILabel alloc] init];
    }
    return _totalNumberLabel;
}

- (UIView *)footerBackgroundView
{
    if (!_footerBackgroundView) {
        _footerBackgroundView = [[UIView alloc] init];
    }
    return _footerBackgroundView;
}

- (UIButton *)continueButton
{
    if (!_continueButton) {
        _continueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    }
    return _continueButton;
}

- (UILabel *)bottomTypeTotalResultNumLabel
{
    if (!_bottomTypeTotalResultNumLabel) {
        _bottomTypeTotalResultNumLabel = [[UILabel alloc] init];
    }
    return _bottomTypeTotalResultNumLabel;
}

@end
