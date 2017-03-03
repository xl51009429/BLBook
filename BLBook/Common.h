//
//  Common.h
//  SogaBook
//
//  Created by 解梁 on 16/9/18.
//  Copyright © 2016年 5i5j. All rights reserved.
//

#ifndef Common_h
#define Common_h

/////////////////////////// 屏幕尺寸


//屏幕宽高
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

//屏幕适配比例
#define kScreen320Scale kScreenWidth/320.0
#define kScreen375Scale kScreenWidth/375.0

//边距
#define kPadding 10 

//适配函数
#define kGetNum(num) num * kScreen320Scale

//状态栏 ＋ 导航栏
#define kStatusAndNavHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + self.navigationController.navigationBar.frame.size.height)

//导航栏高度
#define kNavHeight self.navigationController.navigationBar.frame.size.height

//tabbar高度
#define kTabHeight self.tabBarController.tabBar.frame.size.height

//首页左侧控制器显示比例
#define kLeftViewControllerShowScale 0.2

//网络请求错误
#define kErrorCode -100

//每页多少行数据
#define kPageNum 10

//keychain
#define SXS_BL_SERVICE @"www.bacic5i5j.com"
#define SXS_BL_UUID @"sxs_bl_uuid"

//颜色
#define kDarkGrayColor   0xa9a9a9
#define kGrayColor       0x808080
#define kDimGrayColor    0x696969

#define kRedColor        0xA20E15


/////////////////////////// 常用全局


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#define weakify(o) autoreleasepool{} __weak typeof(o) o##Weak = o;
#define strongify(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

#endif /* Common_h */
