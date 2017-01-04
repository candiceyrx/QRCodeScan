//
//  LLScanView.m
//  原生二维码扫描
//
//  Created by Candice on 16/12/21.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import "LLScanView.h"
#import <AVFoundation/AVFoundation.h>

NSString *const LLSuccessScanQRCodeNotification = @"LLSuccessScanQRCodeNotification";
NSString *const LLScanQRCodeMessageKey = @"LLScanQRCodeMessageKey";

#define SCANSPACEOFFSET 0.15f
#define REMAINTEXT @"将二维码放入框内，即可自动扫描"
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)

@interface LLScanView()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureSession * session;
@property (nonatomic, strong) AVCaptureDeviceInput * input;
@property (nonatomic, strong) AVCaptureMetadataOutput * output;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * scanView;

@property (nonatomic, strong) CAShapeLayer * maskLayer;
@property (nonatomic, strong) CAShapeLayer * shadowLayer;
@property (nonatomic, strong) CAShapeLayer * scanRectLayer;

@property (nonatomic, assign) CGRect scanRect;
@property (nonatomic, strong) UILabel * remindLabel;

@end

@implementation LLScanView

#pragma mark - Init
+ (instancetype)initScanViewInController:(UIViewController *)controller {
    if (!controller) {
        return nil;
    }
    
    LLScanView *scanView = [[LLScanView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    
    if ([controller conformsToProtocol:@protocol(LLScanViewDelegate)]) {
        scanView.delegate = (UIViewController<LLScanViewDelegate> *)controller;
    }
    
    return scanView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.f alpha:0.2f];
        [self.layer addSublayer:self.scanView];
        [self setupScanRect];
        [self addSubview:self.remindLabel];
        self.layer.masksToBounds = YES;
    }
    return self;
}

#pragma mark - LifeCycle
#pragma mark -- 释放前停止会话
- (void)dealloc {
    [self stop];
}

#pragma mark -- 开始视频会话
- (void)start {
    [self.session startRunning];
}

#pragma mark -- 停止视频会话
- (void)stop {
    [self.session stopRunning];
}

#pragma mark - Getter
#pragma mark -- 会话对象
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [AVCaptureSession new];
        [_session setSessionPreset:AVCaptureSessionPresetHigh];
        [self setupIODevice];
    }
    return _session;
}

#pragma mark -- 视频输入设备
- (AVCaptureDeviceInput *)input {
    if (!_input) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    }
    return _input;
}

#pragma mark -- 数据输出对象
- (AVCaptureMetadataOutput *)output {
    if (!_output) {
        _output = [AVCaptureMetadataOutput new];
       [ _output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    }
    return _output;
}

#pragma mark -- 扫描视图
- (AVCaptureVideoPreviewLayer *)scanView {
    if (!_scanView) {
        _scanView = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        _scanView.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _scanView.frame = self.bounds;
    }
    return _scanView;
}

#pragma mark -- 扫描范围
- (CGRect)scanRect {
    if (CGRectEqualToRect(_scanRect, CGRectZero)) {
        CGRect rectOfInterest = self.output.rectOfInterest;
        CGFloat yOffset = rectOfInterest.size.width - rectOfInterest.origin.x;
        CGFloat xOffset = 1 - 2 * SCANSPACEOFFSET;
        _scanRect = CGRectMake(rectOfInterest.origin.y * SCREEN_WIDTH, rectOfInterest.origin.x * SCREEN_HEIGHT, xOffset * SCREEN_WIDTH, yOffset * SCREEN_HEIGHT);
    }
    return _scanRect;
}

#pragma mark -- 提示文本
- (UILabel *)remindLabel {
    if (!_remindLabel) {
        CGRect textRect = self.scanRect;
        textRect.origin.y += CGRectGetHeight(textRect) + 20;
        textRect.size.height = 25.f;
        
        _remindLabel = [[UILabel alloc]initWithFrame:textRect];
        _remindLabel.font = [UIFont systemFontOfSize:15.f * SCREEN_WIDTH / 375.f];
        _remindLabel.textColor = [UIColor whiteColor];
        _remindLabel.textAlignment = NSTextAlignmentCenter;
        _remindLabel.text = REMAINTEXT;
        _remindLabel.backgroundColor = [UIColor clearColor];
    }
    return _remindLabel;
}

#pragma mark -- 扫描框
- (CAShapeLayer *)scanRectLayer {
    if (!_scanRectLayer) {
        CGRect scanRect = self.scanRect;
        scanRect.origin.x -= 1;
        scanRect.origin.y -= 1;
        scanRect.size.width += 2;
        scanRect.size.height += 2;
        
        _scanRectLayer = [CAShapeLayer layer];
        _scanRectLayer.path = [UIBezierPath bezierPathWithRect:scanRect].CGPath;
        _scanRectLayer.fillColor = [UIColor clearColor].CGColor;
        _scanRectLayer.strokeColor = [UIColor orangeColor].CGColor;
    }
    return _scanRectLayer;
}

#pragma mark -- 阴影层
- (CAShapeLayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [CAShapeLayer layer];
        _shadowLayer.path = [UIBezierPath bezierPathWithRect: self.bounds].CGPath;
        _shadowLayer.fillColor = [UIColor colorWithWhite: 0 alpha: 0.75].CGColor;
        _shadowLayer.mask = self.maskLayer;
    }
    return _shadowLayer;
}

#pragma mark -- 遮掩层
- (CAShapeLayer *)maskLayer {
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer = [self generateMaskLayerWithRect:SCREEN_BOUNDS exceptRect:self.scanRect];
    }
    return _maskLayer;
}

#pragma mark - 扫描设置
#pragma mark -- 配置输入输出设置
- (void)setupIODevice {
    if ([self.session canAddInput: self.input]) {
        [_session addInput: _input];
    }
    if ([self.session canAddOutput: self.output]) {
        [_session addOutput: _output];
        _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    }
}

#pragma mark -- 配置扫描范围
- (void)setupScanRect {
    CGFloat size = SCREEN_WIDTH * (1 - 2 * SCANSPACEOFFSET);
    CGFloat minY = (SCREEN_HEIGHT - size) * 0.5 / SCREEN_HEIGHT;
    CGFloat maxY = (SCREEN_HEIGHT + size) * 0.5 / SCREEN_HEIGHT;
    self.output.rectOfInterest = CGRectMake(minY, SCANSPACEOFFSET, maxY, 1 - SCANSPACEOFFSET * 2);
    
    [self.layer addSublayer: self.shadowLayer];
    [self.layer addSublayer: self.scanRectLayer];
}

#pragma mark - Delegate
#pragma mark -- AVCaptureMetadataOutputObjectsDelegate
//二维码扫描数据返回
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        [self stop];
        AVMetadataMachineReadableCodeObject * metadataObject = metadataObjects[0];
        if ([self.delegate respondsToSelector:@selector(scanView:codeInfo:)]) {
            [self.delegate scanView:self codeInfo:metadataObject.stringValue];
            [self removeFromSuperview];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:LLSuccessScanQRCodeNotification object:self userInfo:@{LLScanQRCodeMessageKey:metadataObject.stringValue}];
        }
    }
}

#pragma mark - Private
#pragma mark -- 生成空缺部分rect的layer
- (CAShapeLayer *)generateMaskLayerWithRect: (CGRect)rect exceptRect: (CGRect)exceptRect {
    CAShapeLayer * maskLayer = [CAShapeLayer layer];
    if (!CGRectContainsRect(rect, exceptRect)) {
        return nil;
    }
    else if (CGRectEqualToRect(rect, CGRectZero)) {
        maskLayer.path = [UIBezierPath bezierPathWithRect: rect].CGPath;
        return maskLayer;
    }
    
    CGFloat boundsInitX = CGRectGetMinX(rect);
    CGFloat boundsInitY = CGRectGetMinY(rect);
    CGFloat boundsWidth = CGRectGetWidth(rect);
    CGFloat boundsHeight = CGRectGetHeight(rect);
    
    CGFloat minX = CGRectGetMinX(exceptRect);
    CGFloat maxX = CGRectGetMaxX(exceptRect);
    CGFloat minY = CGRectGetMinY(exceptRect);
    CGFloat maxY = CGRectGetMaxY(exceptRect);
    CGFloat width = CGRectGetWidth(exceptRect);
    
    /** 添加路径*/
    UIBezierPath * path = [UIBezierPath bezierPathWithRect: CGRectMake(boundsInitX, boundsInitY, minX, boundsHeight)];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, boundsInitY, width, minY)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(maxX, boundsInitY, boundsWidth - maxX, boundsHeight)]];
    [path appendPath: [UIBezierPath bezierPathWithRect: CGRectMake(minX, maxY, width, boundsHeight - maxY)]];
    maskLayer.path = path.CGPath;
    
    return maskLayer;
}

#pragma mark -- 点击空白处停止扫描
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self stop];
    [self removeFromSuperview];
}

@end
