//
//  BookView.h
//  BLBook
//
//  Created by bigliang on 2017/2/23.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, BLBookViewEvent) {
    BLBookViewEventNextChapter = 1,
    BLBookViewEventLastChapter,
    BLBookViewEventTouchCenter,
};

@class BookView;

@protocol BookViewDelegate <NSObject>

- (void)bookView:(BookView *)bookView didSelectEvent:(BLBookViewEvent)event;

@end

@interface BookView : UIView

@property (nonatomic, strong)NSString *content;
@property (nonatomic, strong)NSString *lastContent;
@property (nonatomic, strong)NSString *nextContent;
@property (nonatomic, assign)id<BookViewDelegate> delegate;

- (void)ParserChapterToPage;

@end
