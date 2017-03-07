//
//  BookView.m
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BookView.h"
#import <CoreText/CoreText.h>
#import "PageViewCell.h"
#import "BLBookParser.h"

@interface BookView ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong)UITapGestureRecognizer   *tap;
@property (nonatomic, strong)UICollectionView         *collectionView;
@property (nonatomic, strong)NSMutableArray           *pageArray;
@property (nonatomic, strong)NSMutableArray           *lastPageArray;
@property (nonatomic, strong)NSMutableArray           *nextPageArray;
@property (nonatomic, strong)NSMutableArray           *dataSource;
@property (nonatomic, assign)NSInteger                 currentPage;
@property (nonatomic, assign)NSInteger                 lastPage;
@property (nonatomic, assign)BLBookViewEvent           bookViewEvent;

@end

@implementation BookView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initData];
        [self initUI:frame];
    }
    return self;
}

- (void)initData
{
    self.pageArray = [[NSMutableArray alloc]init];
    self.lastPageArray = [[NSMutableArray alloc]init];
    self.nextPageArray = [[NSMutableArray alloc]init];
    self.dataSource = [[NSMutableArray alloc]init];
    
    _currentPage = 0;
    _lastPage    = 0;
}

- (void)initUI:(CGRect)frame
{
    self.collectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.itemSize = CGSizeMake(kScreenWidth,kScreenHeight);
        
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) collectionViewLayout:layout];
        collectionView.delegate     = self;
        collectionView.dataSource   = self;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.pagingEnabled = YES;
        [collectionView registerNib:[UINib nibWithNibName:@"PageViewCell" bundle:nil] forCellWithReuseIdentifier:@"PageViewCellId"];
        collectionView;
    });
    
    self.tap = ({
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
        tap;
    });
    
    [self addSubview: self.collectionView];
    [self.collectionView addGestureRecognizer:self.tap];
}

- (void)tapGesture:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:self];
    if (point.x >= 0 && point.x < kScreenWidth/4) {
        if (_currentPage == 0) {
            //[self.delegate bookView:self didSelectEvent:BLBookViewEventLastChapter];
        }else{
            //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem: --_currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            //[self operateDataSource];
            //BLLogInfo(@"%ld",_currentPage);
        }
    }else if(point.x > kScreenWidth/4*3 && point.x <= kScreenWidth){
        if (_currentPage == self.pageArray.count -1) {
            //[self.delegate bookView:self didSelectEvent:BLBookViewEventNextChapter];
        }else{
            //[self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem: ++_currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
            //[self operateDataSource];
            BLLogInfo(@"%ld",_currentPage);
        }
    }else{
        [self.delegate bookView:self didSelectEvent:BLBookViewEventTouchCenter];
    }
}

- (NSArray *)breakUpToPageFromContent:(NSString *)content
{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineSpacing = kBLLineHeight;
    NSInteger fontSize;
    if ([[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"] == 0) {
        fontSize = kFontSizeNormal;
    }else{
        fontSize = [[NSUserDefaults standardUserDefaults] integerForKey:@"FontSize"];
    }
    NSDictionary *dic =@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paraStyle,NSStrokeColorAttributeName:[UIColor darkGrayColor]};
    NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:content attributes:dic];
    NSArray *arr = [BLBookParser breakUpToPageFromContent:attStr];
    return arr;
}

- (void)ParserChapterToPage
{
    //清空数组
    [self.pageArray removeAllObjects];
    [self.lastPageArray removeAllObjects];
    [self.nextPageArray removeAllObjects];
    [self.dataSource removeAllObjects];
    //数据源添加章节
    [self.pageArray addObjectsFromArray:[self breakUpToPageFromContent:_content]];
    if (_lastContent) {
        [self.lastPageArray addObjectsFromArray:[self breakUpToPageFromContent:_lastContent]];
    }
    if (_nextContent) {
        [self.nextPageArray addObjectsFromArray:[self breakUpToPageFromContent:_nextContent]];
    }
    [self.dataSource addObjectsFromArray:self.lastPageArray];
    [self.dataSource addObjectsFromArray:self.pageArray];
    [self.dataSource addObjectsFromArray:self.nextPageArray];
    [self.collectionView reloadData];
    if (_bookViewEvent == BLBookViewEventLastChapter) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.lastPageArray.count + self.pageArray.count - 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        _currentPage = self.lastPageArray.count + self.pageArray.count - 1;
        _lastPage    = self.lastPageArray.count + self.pageArray.count - 1;
    }else{
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.lastPageArray.count inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        _currentPage = self.lastPageArray.count;
        _lastPage    = self.lastPageArray.count;
    }
}

- (void)operateDataSource
{
    if (_currentPage == self.lastPageArray.count - 1 && _lastPage - _currentPage == 1) {
        //变换数据源
        _bookViewEvent = BLBookViewEventLastChapter;
        [self.delegate bookView:self didSelectEvent:_bookViewEvent];
    }else if(_currentPage == self.lastPageArray.count + self.pageArray.count && _currentPage - _lastPage == 1){
        //变换数据源
        _bookViewEvent = BLBookViewEventNextChapter;
        [self.delegate bookView:self didSelectEvent:_bookViewEvent];
    }
    _lastPage = _currentPage;
}

- (void)changeCurrentPageTextColor
{
    PageViewCell *cell = [[self.collectionView visibleCells] firstObject];
    [self changeTextColor:cell];
}

- (void)changeTextColor:(PageViewCell *)cell
{
    NSString *theme = [[NSUserDefaults standardUserDefaults]stringForKey:@"Theme"];
    if (!theme || [theme isEqualToString:@"day"]) {
        cell.textLabel.textColor = [UIColor darkGrayColor];
    }else{
        cell.textLabel.textColor = UIColorFromRGB(0x8B7D7B);
    }
}

#pragma mark - delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PageViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PageViewCellId" forIndexPath:indexPath];
    cell.textLabel.attributedText = self.dataSource[indexPath.row] ;
    [self changeTextColor:cell];
    return cell;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _currentPage = scrollView.contentOffset.x / kScreenWidth;
    [self operateDataSource];
    self.collectionView.userInteractionEnabled = YES;
    BLLogInfo(@"%ld",_currentPage);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.collectionView.userInteractionEnabled = NO;
}


@end
