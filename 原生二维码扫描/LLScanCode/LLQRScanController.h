//
//  LLQRScanController.h
//  原生二维码扫描
//
//  Created by Candice on 16/12/21.
//  Copyright © 2016年 刘灵. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LLQRScanController;
@protocol LLQRScanControllerDelegate <NSObject>

- (void)scanCodeController:(LLQRScanController *)scanController codeInfo: (NSString *)codeInfo;

@end

@interface LLQRScanController : UIViewController

@property (nonatomic, weak) id<LLQRScanControllerDelegate>delegate;

+ (instancetype)scanCodeController;

@end
