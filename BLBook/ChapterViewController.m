//
//  ChapterViewController.m
//  BLBook
//
//  Created by bigliang on 2017/2/28.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "ChapterViewController.h"

@interface ChapterViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView    *tableView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, assign)NSInteger       chapterIndex;

@end

@implementation ChapterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bl_initData];
    [self bl_initUI];
}

- (void)bl_initData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        Chapter *currentChapter = [[Chapter selectTableWhereKey:@"blID" equalTo:@([[NSUserDefaults standardUserDefaults] integerForKey:self.book.name])] firstObject];
        self.dataSource = [[NSMutableArray alloc]init];
        NSArray *chapters = [Chapter selectTableWhereKey:@"bookID" equalTo:@(self.book.blID)];
        [self.dataSource addObjectsFromArray:chapters];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
        [chapters enumerateObjectsUsingBlock:^(Chapter *  _Nonnull chapter, NSUInteger idx, BOOL * _Nonnull stop) {
            if (chapter.blID == currentChapter.blID) {
                self.chapterIndex = idx;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                });
                return ;
            }
        }];
    });
}

- (void)bl_initUI
{
    self.title = @"目录";
    
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStylePlain];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"chapterCellId"];
        tableView;
    });
    
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
}

#pragma mark - delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chapterCellId" forIndexPath:indexPath];
    Chapter *chapter = self.dataSource[indexPath.row];
    if (indexPath.row == self.chapterIndex) {
        cell.textLabel.text = [NSString stringWithFormat:@"---> %@",[chapter.title deleteWhiteSpace]] ;
    }else{
        cell.textLabel.text =  [chapter.title deleteWhiteSpace];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(chapterViewController:didSelectChapterID:)]) {
        Chapter *chapter = self.dataSource[indexPath.row];
        [self.delegate chapterViewController:self didSelectChapterID:chapter.blID];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)dealloc
{
    BLLogDebug(@"ChapterViewController release");
}

@end
