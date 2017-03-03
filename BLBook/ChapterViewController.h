//
//  ChapterViewController.h
//  BLBook
//
//  Created by bigliang on 2017/2/28.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Book.h"
#import "Chapter.h"

@class ChapterViewController;

@protocol ChapterViewControllerDelegate <NSObject>

- (void)chapterViewController:(ChapterViewController *)controller didSelectChapterID:(NSInteger)chapterID;

@end

@interface ChapterViewController : UIViewController

@property (nonatomic, strong)Book *book;
@property (nonatomic, assign)id<ChapterViewControllerDelegate> delegate;

@end
