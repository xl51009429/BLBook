//
//  BLDownloadView.h
//  BLBook
//
//  Created by bigliang on 2017/2/27.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BLDownloadView;

@protocol BLDownloadViewDelegate <NSObject>

- (void)didClickDownloadView:(BLDownloadView *)downloadView;

@end

@interface BLDownloadView : UIView

@property (nonatomic, assign)CGFloat progress;
@property (nonatomic, assign)id<BLDownloadViewDelegate> delegate;

- (void)startDownload;
- (void)resume;

@end
