//
//  BookViewController.m
//  BLBook
//
//  Created by bigliang on 2017/2/21.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BookViewController.h"
#import "BookView.h"
#import "Chapter.h"
#import "ChapterViewController.h"
#import "BLBook-Swift.h"
#import "BLBookParser.h"

@interface BookViewController ()<BookViewDelegate,ChapterViewControllerDelegate,BLToolBarViewDelegate>

@property (nonatomic, strong)BookView                  *bookView;
@property (nonatomic, strong)UIImageView               *backView;
@property (nonatomic, strong)BLToolBarView             *toolBar;
@property (nonatomic, assign)ToolBarButtonTag           FontTag;
@property (nonatomic, assign)ToolBarButtonTag           ThemeTag;

@end

@implementation BookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bl_initUI];
    [self bl_initData];
}

- (void)bl_initUI
{
    self.view.backgroundColor = [UIColor redColor];

    UIButton *rightButton = ({
        UIButton *button = [[UIButton alloc]init];
        [button setTitle:@"目录" forState:UIControlStateNormal];
        [button setTintColor:[UIColor whiteColor]];
        [button sizeToFit];
        [button addTarget:self action:@selector(rightBarButtonClick) forControlEvents:UIControlEventTouchUpInside];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        button;
    });
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    self.bookView = ({
        BookView *bookView = [[BookView alloc]initWithFrame:self.view.bounds];
        bookView.delegate = self;
        bookView;
    });
    
    self.backView = ({
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        imageView.image = [UIImage imageNamed:@"background.jpeg"];
        imageView;
    });
    
    self.toolBar = ({
        BLToolBarView *view = [[BLToolBarView alloc]initWithFrame:CGRectMake(0, kScreenHeight, kScreenWidth, 44)];
        view.delegate = self;
        view.backgroundColor = UIColorFromRGB(0xA20E15);
        view;
    });
    
    [self.view addSubview:self.backView];
    [self.view addSubview:self.bookView];
    [self.view addSubview:self.toolBar];
    
    NSString *themeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"Theme"];
    if (!themeName || [themeName isEqualToString: @"day"]) {
        self.bookView.backgroundColor = [UIColor clearColor];
    }else{
        self.bookView.backgroundColor = [UIColor blackColor];
    }
}

- (void)bl_initData
{
    [BLBookParser setLineNums];
    [self setChapterContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFontSize:) name:@"bl_changeFontSize" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTheme:) name:@"bl_changeTheme" object:nil];
}

- (void)changeFontSize:(NSNotification *)info
{
    [[NSUserDefaults standardUserDefaults]setObject:info.userInfo[@"FontSize"] forKey:@"FontSize"];
    [BLBookParser setLineNums];
    [self.bookView ParserChapterToPage];
}

- (void)changeTheme:(NSNotification *)info
{
    [[NSUserDefaults standardUserDefaults]setObject:info.userInfo[@"Theme"] forKey:@"Theme"];
    NSString *themeName = info.userInfo[@"Theme"];
    if ([themeName isEqualToString: @"day"]) {
        self.bookView.backgroundColor = [UIColor clearColor];
    }else{
        self.bookView.backgroundColor = [UIColor blackColor];
    }
    [self.bookView changeCurrentPageTextColor];
}

- (void)showAndDissmisToolBar
{
    @weakify(self)
    [UIView animateWithDuration:0.2 animations:^{
        @strongify(self)
        if (self.toolBar.frame.origin.y == kScreenHeight) {
            CGRect newFrame = CGRectMake(self.toolBar.frame.origin.x, kScreenHeight - self.toolBar.frame.size.height, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
            self.toolBar.frame = newFrame;
        }else{
            CGRect newFrame = CGRectMake(self.toolBar.frame.origin.x, kScreenHeight, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
            self.toolBar.frame = newFrame;
        }
    }];
}

- (void)setChapterContent
{
    if([[NSUserDefaults standardUserDefaults] integerForKey:self.book.name] == 0){ //第一次打开小说
        Chapter *chapter = [[Chapter selectTableWhereKey:@"bookID" equalTo:@(self.book.blID)] firstObject];
        [[NSUserDefaults standardUserDefaults] setInteger:chapter.blID forKey:self.book.name];
    }
    
    //打开上次存储的章节
    Chapter *chapter = [[Chapter selectTableWhereKey:@"blID" equalTo:@([[NSUserDefaults standardUserDefaults] integerForKey:self.book.name])] firstObject];
    self.bookView.content = chapter.content;
    
    //判断是否存在上一章
    NSArray *lastChapters = [Chapter selectTableWhereKey:@"blID" equalTo: @([[NSUserDefaults standardUserDefaults] integerForKey:self.book.name] - 1)];
    if (lastChapters.count > 0 && [lastChapters[0] bookID].integerValue == self.book.blID) {
        Chapter *lastChapter = lastChapters[0];
        self.bookView.lastContent = lastChapter.content;
    }
    //判断是否存在下一章
    NSArray *nextChapters = [Chapter selectTableWhereKey:@"blID" equalTo: @([[NSUserDefaults standardUserDefaults] integerForKey:self.book.name] + 1)];
    if (nextChapters.count > 0 && [nextChapters[0] bookID].integerValue == self.book.blID) {
        Chapter *nextChapter = nextChapters[0];
        self.bookView.nextContent = nextChapter.content;
    }
    //开始解析章节分页
    [self.bookView ParserChapterToPage];
    
    self.title = chapter.title;
}

- (void)rightBarButtonClick
{
    ChapterViewController *chapterVC = [[ChapterViewController alloc]init];
    chapterVC.book = self.book;
    chapterVC.delegate = self;
    [self.navigationController pushViewController:chapterVC animated:YES];
}

#pragma mark - lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.toolBar.frame = CGRectMake(self.toolBar.frame.origin.x, kScreenHeight, self.toolBar.frame.size.width, self.toolBar.frame.size.height);
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //[[UIApplication sharedApplication] setStatusBarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - BookView's delegate

- (void)bookView:(BookView *)bookView didSelectEvent:(BLBookViewEvent)event
{
    if (event  == BLBookViewEventTouchCenter) {
        //[[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden];
        [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
        [self showAndDissmisToolBar];
    }else{
        NSInteger currentPage = [[NSUserDefaults standardUserDefaults] integerForKey:self.book.name];
        [[NSUserDefaults standardUserDefaults] setInteger:event == BLBookViewEventNextChapter?currentPage + 1:currentPage - 1 forKey:self.book.name];
        [self setChapterContent];
        
    }
}

#pragma mark - ChapterViewController's delegate

- (void)chapterViewController:(ChapterViewController *)controller didSelectChapterID:(NSInteger)chapterID
{
    [[NSUserDefaults standardUserDefaults] setInteger:chapterID forKey:self.book.name];
    [self setChapterContent];
}

#pragma mark - BLToolBarView's Delegate

- (void)didSelectWithToolBarView:(BLToolBarView *)toolBar index:(NSInteger)index
{
    switch (index) {
        case ToolBarButtonTagSmall:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bl_changeFontSize" object:nil userInfo:@{@"FontSize":@(kFontSizeSmall)}];
            break;
        case ToolBarButtonTagNormal:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bl_changeFontSize" object:nil userInfo:@{@"FontSize":@(kFontSizeNormal)}];
            break;
        case ToolBarButtonTagBig:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bl_changeFontSize" object:nil userInfo:@{@"FontSize":@(kFontSizeBig)}];
            break;
        case ToolBarButtonTagDay:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bl_changeTheme" object:nil userInfo:@{@"Theme":@"day"}];
            break;
        case ToolBarButtonTagNight:
            [[NSNotificationCenter defaultCenter]postNotificationName:@"bl_changeTheme" object:nil userInfo:@{@"Theme":@"night"}];
            break;
            
        default:
            break;
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end
