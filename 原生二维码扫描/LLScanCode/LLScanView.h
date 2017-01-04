//
//  LLScanView.h
//  原生二维码扫描
//
//  Created by Candice on 16/12/21.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import <UIKit/UIKit.h>

//扫描成功发送通知（在代理实现的情况下不发送）
extern NSString *const LLSuccessScanQRCodeNotification;
//通知传递数据中存储二维码信息的关键字
extern NSString *const LLScanQRCodeMessageKey;

@class LLScanView;
@protocol  LLScanViewDelegate <NSObject>

- (void)scanView:(LLScanView *)scanView codeInfo:(NSString *)codeInfo;

@end

//LLScanView--二维码/条形码扫描视图
@interface LLScanView : UIView

//扫描回调代理
@property (nonatomic, weak) id<LLScanViewDelegate> delegate;

//创建扫描视图
+ (instancetype)initScanViewInController:(UIViewController *)controller;

//开始扫描
- (void)start;

//结束扫描
- (void)stop;
@end
