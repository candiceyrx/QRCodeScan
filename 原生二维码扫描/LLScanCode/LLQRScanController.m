//
//  LLQRScanController.m
//  原生二维码扫描
//
//  Created by Candice on 16/12/21.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import "LLQRScanController.h"
#import "LLScanView.h"

@interface LLQRScanController()<LLScanViewDelegate>

@property (nonatomic,strong) LLScanView *scanView;
@end

@implementation LLQRScanController

#pragma mark - Init
+ (instancetype)scanCodeController {
    return [[self alloc] init];
}

- (instancetype)init {
    if (self = [super init]) {
        self.scanView = [LLScanView initScanViewInController:self];
    }
    return self;
}

#pragma mark - LifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scanView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.scanView start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.scanView stop];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.scanView stop];
}

#pragma mark - LLQRScanControllerDelegate
//扫描成功时回调
- (void)scanView:(LLScanView *)scanView codeInfo:(NSString *)codeInfo {
    if ([_delegate respondsToSelector:@selector(scanCodeController:codeInfo:)]) {
        [_delegate scanCodeController:self codeInfo:codeInfo];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
         [[NSNotificationCenter defaultCenter] postNotificationName: LLSuccessScanQRCodeNotification object: self userInfo: @{ LLScanQRCodeMessageKey: codeInfo }];
    }
}
@end
