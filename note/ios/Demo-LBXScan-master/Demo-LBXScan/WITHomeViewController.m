//
//  WITHomeViewController.m
//  Demo-LBXScan
//
//  Created by witsystem on 2018/3/23.
//  Copyright © 2018年 witsystem. All rights reserved.
//

#import "WITHomeViewController.h"
#import <LBXScanViewStyle.h>
#import "WITOrderScanViewController.h"

@interface WITHomeViewController ()

@end

@implementation WITHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫一扫";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [[UIButton alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width * 0.5-50, [UIScreen mainScreen].bounds.size.height * 0.5, 100, 50)];
    [button addTarget:self action: @selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle: @"扫一扫" forState: UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [self.view addSubview: button];
}


- (IBAction)btnClick:(id)sender {
    //设置扫码区域参数
    LBXScanViewStyle *style = [[LBXScanViewStyle alloc]init];
    style.centerUpOffset = 44;
    style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle_Inner;
    style.photoframeLineW = 3;
    style.photoframeAngleW = 18;
    style.photoframeAngleH = 18;
    style.isNeedShowRetangle = NO;
    style.anmiationStyle = LBXScanViewAnimationStyle_LineMove;
    
    //qq里面的线条图片
    UIImage *imgLine = [UIImage imageNamed:@"CodeScan.bundle/qrcode_scan_light_green"];
    style.animationImage = imgLine;
    
    style.notRecoginitonArea = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    WITOrderScanViewController *vc = [WITOrderScanViewController new];
    vc.style = style;
    vc.isOpenInterestRect = YES;
    vc.libraryType = SLT_Native;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
