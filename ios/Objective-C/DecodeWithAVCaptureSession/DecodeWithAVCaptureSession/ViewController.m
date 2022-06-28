//
//  ViewController.m
//  DecodeWithAVCaptureSession
//
//  Created by dynamsoft on 2022/3/21.
//

#import "ViewController.h"
#import "CameraViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UIButton *cameraButton;

@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor]};
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:59.003/255.0 green:61.9991/255.0 blue:69.0028/255.0 alpha:1]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.cameraButton];
}

- (void)cameraAction {
    CameraViewController *cameraVC = [[CameraViewController alloc] init];
    cameraVC.modalPresentationStyle = UIModalPresentationPageSheet;
    [self presentViewController:cameraVC animated:YES completion:nil];
}

// MARK: - Lazy

- (UIButton *)cameraButton {
    if (!_cameraButton) {
        _cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cameraButton setTitle:@"Start Scanning" forState:UIControlStateNormal];
        [_cameraButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_cameraButton sizeToFit];
        _cameraButton.frame = CGRectMake((kScreenWidth - (_cameraButton.frame.size.width + 20)) / 2.0, (kScreenHeight - (_cameraButton.frame.size.height + 20)) / 2.0, _cameraButton.frame.size.width + 20, _cameraButton.frame.size.height + 20);
        [_cameraButton addTarget:self action:@selector(cameraAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraButton;
}

@end
