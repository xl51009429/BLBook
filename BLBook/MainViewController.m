//
//  ViewController.m
//  BLBook
//
//  Created by bigliang on 2017/2/21.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "MainViewController.h"
#import "BookViewController.h"
#import "AddBookViewController.h"
#import "Book.h"
#import "BookListCell.h"
#import "Chapter.h"

//http://dz.80txt.com/7645/异世灵武天下.zip 测试小说

@interface MainViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, copy)  NSMutableArray                 *books;
@property (nonatomic, strong)UICollectionView               *collectionView;
@property (nonatomic, strong)UILongPressGestureRecognizer   *longPress;
@property (nonatomic, strong)UITapGestureRecognizer         *tap;

@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bl_initUI];
    [self bl_initGesture];
}

- (void)bl_initUI
{
    self.title  = @"小说列表";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBook)];
    
    self.collectionView = ({
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = kPadding;
        layout.minimumInteritemSpacing = kPadding;
        layout.sectionInset = UIEdgeInsetsMake(kPadding, kPadding, kPadding, kPadding);
        layout.itemSize = CGSizeMake((kScreenWidth - kPadding*4)/3, (kScreenWidth - kPadding*4)/3*1.4);
        UICollectionView *collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:layout];
        collectionView.delegate     = self;
        collectionView.dataSource   = self;
        collectionView.backgroundColor = [UIColor lightGrayColor];
        [collectionView registerNib:[UINib nibWithNibName:@"BookListCell" bundle:nil] forCellWithReuseIdentifier:@"BookListCellId"];
        collectionView;
    });
    
    [self.view addSubview:self.collectionView ];
}

- (void)bl_initGesture
{
    self.longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressEvent:)];
    self.longPress.minimumPressDuration = 1.0f;
    [self.collectionView addGestureRecognizer:self.longPress];
    
    self.tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent:)];
}

- (void)longPressEvent:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self showDeleteButton];
    }else if (longPress.state == UIGestureRecognizerStateChanged){
        
    }else if(longPress.state == UIGestureRecognizerStateEnded){
        
    }
}

- (void)showDeleteButton
{
    CAKeyframeAnimation *shake = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    shake.values = @[@(-5 / 180.0 * M_PI),@(5 /180.0 * M_PI),@(-5/ 180.0 * M_PI)];//度数转弧度
    shake.removedOnCompletion = NO;
    shake.fillMode = kCAFillModeForwards;
    shake.duration = 0.15;
    shake.repeatCount = MAXFLOAT;
    NSArray *cells = [self.collectionView visibleCells];
    for (BookListCell *cell in cells) {
        cell.deleteButton.hidden = NO;
        [cell.layer addAnimation:shake forKey:@"bl_shakeAnimation"];
    }
    [[UIApplication sharedApplication].keyWindow  addGestureRecognizer:self.tap];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)tapEvent:(UITapGestureRecognizer *)tap
{
    NSArray *cells = [self.collectionView visibleCells];
    for (BookListCell *cell in cells) {
        cell.deleteButton.hidden = YES;
        [cell.layer removeAnimationForKey:@"bl_shakeAnimation"];
    }
    [[UIApplication sharedApplication].keyWindow removeGestureRecognizer:self.tap];
    self.navigationItem.rightBarButtonItem.enabled = YES;
}

- (void)addBook
{
    AddBookViewController *controller = [[AddBookViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)deleteBook:(NSIndexPath *)indexPath
{
    Book *book = self.books[indexPath.row];
    NSArray *chapters = [Chapter selectTableWhereKey:@"bookID" equalTo:@(book.blID)];
    if ([Chapter deleteObjects:chapters] && [book deleteObject]) {
        self.books = [[NSMutableArray alloc] initWithArray:[Book selectAll]];
        [self.collectionView reloadData];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:book.name];
        [self.view makeToast:@"删除成功"];
    }else{
        [self.view makeToast:@"删除失败"];
    }
    [self tapEvent:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.books = [[NSMutableArray alloc] initWithArray:[Book selectAll]] ;
    [self.collectionView reloadData];
}

#pragma mark - delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.books.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BookListCellId" forIndexPath:indexPath];
    cell.titleLabel.text = [self.books[indexPath.row] name];
    cell.deleteButton.hidden = YES;
    @weakify(self)
    cell.clickBlock = ^(){
        @strongify(self)
        [self deleteBook:indexPath];
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BookViewController *controller = [[BookViewController alloc]init];
    controller.book = self.books[indexPath.row];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
