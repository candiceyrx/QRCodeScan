//
//  ViewController.m
//  原生二维码扫描
//
//  Created by Candice on 16/12/21.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import "ViewController.h"
#import "LLQRScanController.h"

@interface ViewController ()<LLQRScanControllerDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *scanButton = [UIButton buttonWithType:UIButtonTypeSystem];
    scanButton.frame = CGRectMake(200, 200, 100, 60);
    [scanButton setTitle:@"二维码扫描" forState:UIControlStateNormal];
    [scanButton addTarget:self action:@selector(jumpToScan:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:scanButton];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)jumpToScan:(UIButton *)sender {
    LLQRScanController *scanController = [[LLQRScanController alloc]init];
    scanController.delegate = self;
    [self.navigationController pushViewController:scanController animated:YES];
}

- (void)scanCodeController:(LLQRScanController *)scanController codeInfo:(NSString *)codeInfo {
    NSLog(@"=======扫描返回的结果:%@",codeInfo);
    NSURL *url = [NSURL URLWithString:codeInfo];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle: @"警告" message: [NSString stringWithFormat: @"%@", codeInfo] delegate: nil cancelButtonTitle: @"确定" otherButtonTitles: nil];
        [alertView show];
    }
    
}

@end
