//
//  BLNavigationController.m
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BLNavigationController.h"

@interface BLNavigationController ()

@end

@implementation BLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.navigationBar setBarTintColor:UIColorFromRGB(0xA20E15)];
    [self.navigationBar setTintColor:[UIColor whiteColor]];
    self.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:16]};
}

//重写push方法，修改返回按钮样式，push的时候隐藏tabbar
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        [backButton setImage:[UIImage imageNamed:@"login-back"] forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    
    [super pushViewController:viewController animated:animated];
}

//返回按钮点击事件
- (void)back{
    
    [self popViewControllerAnimated:YES];
}

@end
