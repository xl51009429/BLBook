//
//  AddBookViewController.m
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "AddBookViewController.h"
#import "FileUtil.h"
#import "BLBookParser.h"
#import <AFNetworking.h>
#import "Book.h"
#import "BLDownloadView.h"

@interface AddBookViewController ()<BLDownloadViewDelegate>

@property (nonatomic, strong)NSURLSessionDownloadTask *task;

@property (nonatomic, strong)UITextField    *bookNameTextField;
@property (nonatomic, strong)UITextField    *bookUrlTextField;
@property (nonatomic, strong)UIImageView    *backImageView;
@property (nonatomic, strong)BLDownloadView *downloadView;
@property (nonatomic, strong)UIButton       *backButton;
@property (nonatomic, strong)UIButton       *cancelButton;
@property (nonatomic, strong)UILabel        *titleLabel;
@property (nonatomic, strong)UILabel        *line1;
@property (nonatomic, strong)UILabel        *line2;

@property (nonatomic, strong)Book *book;

@end

@implementation AddBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
}

- (void)initUI
{
    self.title = @"添加小说";
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.backImageView = ({
        UIImageView *view = [[UIImageView alloc]init];
        view.image = [UIImage imageNamed:@"login-background"];
        view;
    });
    
    self.backButton = ({
        UIButton *btn = [[UIButton alloc]init];
        [btn setImage:[UIImage imageNamed:@"login-back"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [btn sizeToFit];
        btn;
    });
    
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc]init];
        label.textColor = UIColorFromRGB(0xf8f8f8);
        label.text = @"添加小说";
        label.font = [UIFont systemFontOfSize:18];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    self.line1 = ({
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = UIColorFromRGB(0xc8c8c8);
        label;
    });
    
    self.line2 = ({
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = UIColorFromRGB(0xc8c8c8);
        label;
    });
    
    self.cancelButton = ({
        UIButton *btn = [[UIButton alloc]init];
        [btn setTitleColor:UIColorFromRGB(0xf8f8f8) forState:UIControlStateNormal];
        [btn setTitle:@"取消" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(cancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        btn;
    });
    
    self.bookNameTextField = ({
        UITextField *textField = [[UITextField alloc]init];
        textField.placeholder = @"书名";
        [textField setValue:UIColorFromRGB(0xc8c8c8) forKeyPath:@"_placeholderLabel.textColor"];
        textField.textColor = [UIColor whiteColor];
        textField.font = [UIFont systemFontOfSize:15];
        textField;
    });
    
    self.bookUrlTextField = ({
        UITextField *textField = [[UITextField alloc]init];
        textField.placeholder = @"下载地址";
        [textField setValue:UIColorFromRGB(0xc8c8c8) forKeyPath:@"_placeholderLabel.textColor"];
        textField.textColor = [UIColor whiteColor];
        textField.font = [UIFont systemFontOfSize:15];
        textField;
    });
    
    self.downloadView = ({
        BLDownloadView *view = [[BLDownloadView alloc]init];
        view.delegate = self;
        view;
    });
    
    [self.view addSubview:self.backImageView];
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.bookNameTextField];
    [self.view addSubview:self.bookUrlTextField];
    [self.view addSubview:self.downloadView];
    [self.view addSubview:self.line1];
    [self.view addSubview:self.line2];
    [self bl_makeConstraints];
}

- (void)bl_makeConstraints
{
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kGetNum(12));
        make.top.mas_equalTo(self.mas_topLayoutGuide).offset(kGetNum(20));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(kGetNum(-12));
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.left.mas_equalTo(kGetNum(40));
        make.right.mas_equalTo(-kGetNum(40));
    }];
    
    [self.bookNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kGetNum(32));
        make.right.mas_equalTo(-kGetNum(32));
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(kGetNum(60));
        make.height.mas_equalTo(kGetNum(30));
    }];
    
    [self.line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kGetNum(32));
        make.right.mas_equalTo(-kGetNum(32));
        make.top.mas_equalTo(self.bookNameTextField.mas_bottom).offset(kGetNum(15));
        make.height.mas_equalTo(kGetNum(1));
        
    }];
    
    [self.bookUrlTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kGetNum(32));
        make.right.mas_equalTo(-kGetNum(32));
        make.top.mas_equalTo(self.line1.mas_bottom).offset(kGetNum(15));
        make.height.mas_equalTo(kGetNum(30));
    }];
    
    [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kGetNum(32));
        make.right.mas_equalTo(-kGetNum(32));
        make.top.mas_equalTo(self.bookUrlTextField.mas_bottom).offset(kGetNum(15));
        make.height.mas_equalTo(kGetNum(1));
    }];
    
    [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kGetNum(32));
        make.right.mas_equalTo(-kGetNum(32));
        make.top.mas_equalTo(self.line2.mas_bottom).offset(kGetNum(30));
        make.height.mas_equalTo(kGetNum(60));
    }];
}

- (void)backButtonClick
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cancelButtonClick
{
    [self cancelRequest];
}

- (void)submitButtonClick
{
    if ([self.bookUrlTextField.text bl_isURL] && self.bookNameTextField.text.length > 0) {
        BLLogInfo(@"url and name right");
        NSArray *arr = [Book selectTableWhereKey:@"name" equalTo:self.bookNameTextField.text];
        if (arr.count > 0) {
            [self.view makeToast:@"该书已存在!"];
            return;
        }
        [self.downloadView startDownload];
        self.book = [[Book alloc]initWithName:self.bookNameTextField.text url:self.bookUrlTextField.text];
        [self.book insertObject];
        [self sendRequest];
    }else{
        BLLogError(@"url or name error");
        [self.view makeToast:@"请输入正确的书名或地址!"];
    }
}

- (void)cancelRequest
{
    [self.downloadView resume];
    [_task cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)sendRequest
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc]initWithSessionConfiguration:configuration];
    _task = [manager downloadTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.bookUrlTextField.text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"`#%^{}\"[]|\\<> "].invertedSet]]] progress:^(NSProgress * _Nonnull downloadProgress) {
        BLLogInfo(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
        self.downloadView.progress = 1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount;
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *path = [cachesPath stringByAppendingPathComponent:response.suggestedFilename];
        BLLogInfo(@"download path:%@",path);
        return [NSURL fileURLWithPath:path];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (error) {
            BLLogError(@"download error:%@",error);
            [self.book deleteObject];
        }else{
            BLLogInfo(@"download complete:%@",filePath.absoluteString);
            NSString *destination = [FileUtil createDirectoryForDownloadItemByName:[NSString stringWithFormat:@"%d",self.book.blID]];
            NSString *cachesPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            NSString *path = [cachesPath stringByAppendingPathComponent:filePath.lastPathComponent];
            BOOL isSuccess = [FileUtil unzipFileAtPath:path toPath:destination];
            if (isSuccess) {
                BLLogInfo(@"unzip file success and remove zip file");
                //解压成功 删除压缩文件
                [FileUtil removeItemAtPath:path];
                //退出
                [self.view makeToast:@"download and unzip success!"];
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                BLLogError(@"unzip file failed");
            }
            [self loadBook];
        }
    }];
    [_task resume];
}

- (void)loadBook
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *bookDir = [FileUtil createDirectoryForDownloadItemByName:[NSString stringWithFormat:@"%d",self.book.blID]];
    NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:bookDir];
    NSString *fileName = [enumerator nextObject];
    while (fileName) {
        NSString *url = [bookDir stringByAppendingPathComponent:fileName];
        if ([manager fileExistsAtPath:url] && [url containsString:@".txt"] && [[manager attributesOfItemAtPath:url error:nil] fileSize]/1024 > 100) {
            //存在txt文件 并且大于100kb 开始解析
            BLLogInfo(@"url :%@",url);
            [BLBookParser parserBookAtPath:url deleteWhenSuccess:YES bookId:self.book.blID];
        }else{
            [FileUtil removeItemAtPath:url];
        }
        fileName = [enumerator nextObject];
    }
    
}

- (void)dealloc
{
    if (_task) {
        [_task cancel];
    }
}

#pragma mark - deleagte

- (void)didClickDownloadView:(BLDownloadView *)downloadView
{
    [self submitButtonClick];
}

@end
