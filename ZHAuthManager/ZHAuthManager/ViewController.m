//
//  ViewController.m
//  ZHAuthManager
//
//  Created by Lee on 2018/10/11.
//  Copyright © 2018年 leezhihua All rights reserved.
//

#import "ViewController.h"
#import "ZHAuthManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [ZHAuthManager requestAuthorization:AuthTypeLocationAlways authorizedResult:^(BOOL granted) {
        //do something
    }];
}

@end
