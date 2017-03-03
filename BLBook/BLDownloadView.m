//
//  BLDownloadView.m
//  BLBook
//
//  Created by bigliang on 2017/2/27.
//  Copyright © 2017年 5i5j. All rights reserved.
//

#import "BLDownloadView.h"

@interface BLDownloadView ()<CAAnimationDelegate>

@property (nonatomic, strong)CAShapeLayer           *circleLayer;
@property (nonatomic, strong)CAShapeLayer           *arrowLayer;
@property (nonatomic, strong)UIBezierPath           *circlePath;
@property (nonatomic, strong)UIBezierPath           *arrowPath;
@property (nonatomic, strong)UITapGestureRecognizer *tapGesture;
@property (nonatomic, assign)BOOL                    isAnimation;
@property (nonatomic, assign)BOOL                    isDownload;
@property (nonatomic, strong)CAShapeLayer           *progressLayer;
@property (nonatomic, strong)UILabel                *tipLabel;

@end

@implementation BLDownloadView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self bl_init];
    }
    return self;
}

- (void)bl_init
{
    _isAnimation = NO;
    _isDownload = NO;
    [self bl_initGesture];
    self.backgroundColor = [UIColor clearColor];
}

- (void)drawRect:(CGRect)rect
{
    [self bl_initUI];
}

- (void)bl_initUI
{
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint center = CGPointMake(width/2, height/2);
    CGFloat longLineHeight = height/2;
    CGFloat shortLineHeight = longLineHeight/2;
    CGFloat offset = shortLineHeight * sin(M_PI_4);
    
    self.circlePath = ({
        UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake((width - height)/2, 0, height, height)];
        path;
    });
    
    self.arrowPath = ({
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(center.x, center.y - longLineHeight/2)];
        [path addLineToPoint:CGPointMake(center.x, center.y + longLineHeight/2)];
        [path addLineToPoint:CGPointMake(center.x - offset, center.y + longLineHeight/2 - offset)];
        [path moveToPoint:CGPointMake(center.x, center.y + longLineHeight/2)];
        [path addLineToPoint:CGPointMake(center.x + offset, center.y + longLineHeight/2 - offset)];
        path;
    });
    
    self.circleLayer = ({
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        layer.lineWidth = 3;
        layer;
    });
    
    self.arrowLayer= ({
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        layer.lineWidth = 3;
        layer;
    });
    
    self.progressLayer = ({
        CAShapeLayer *layer = [CAShapeLayer layer];
        layer.frame = self.bounds;
        layer.fillColor = [UIColor clearColor].CGColor;
        layer.strokeColor = [UIColor yellowColor].CGColor;
        layer.lineCap = kCALineCapRound;
        layer.lineJoin = kCALineJoinRound;
        layer.lineWidth = 3;
        layer;
    });
    
    self.tipLabel = ({
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, 30)];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label;
    });
    
    self.circleLayer.path = self.circlePath.CGPath;
    self.arrowLayer.path  = self.arrowPath.CGPath;
    
    [self addSubview:self.tipLabel];
    [self.layer addSublayer:self.circleLayer];
    [self.layer addSublayer:self.arrowLayer];
    [self.layer addSublayer:self.progressLayer];
}

- (void)bl_initGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent)];
    [self addGestureRecognizer:self.tapGesture];
}

- (void)tapEvent
{
    [self.delegate didClickDownloadView:self];
}

- (void)startDownload
{
    if (_isAnimation) {
        return;
    }
    _isAnimation = YES;
    
    CAKeyframeAnimation *circleAnimation = [self circleLayerAnimation];
    [self.circleLayer addAnimation:circleAnimation forKey:@"bl_circleAnimation"];
    
    CAAnimationGroup *arrowAniamtion = [self arrowLayerAnimation];
    arrowAniamtion.delegate = self;
    [self.arrowLayer addAnimation:arrowAniamtion forKey:@"bl_arrowAnimation"];
}

- (void)resume
{
    [self.arrowLayer removeFromSuperlayer];
    [self.circleLayer removeFromSuperlayer];
    [self.progressLayer removeFromSuperlayer];
    [self.tipLabel removeFromSuperview];
    self.arrowPath = nil;
    self.circlePath = nil;
    self.tapGesture = nil;
    [self bl_init];
    [self bl_initUI];
}

- (CAKeyframeAnimation *)circleLayerAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
    animation.duration = 0.5f;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.values = @[(__bridge id)[self caveBezierPathByOffset:0.2].CGPath,
                         (__bridge id)[self caveBezierPathByOffset:0.4].CGPath,
                         (__bridge id)[self caveBezierPathByOffset:0.6].CGPath,
                         (__bridge id)[self caveBezierPathByOffset:0.8].CGPath,
                         (__bridge id)[self caveBezierPathByOffset:1.0].CGPath,
                         (__bridge id)[self convexBezierPathByOffset:0.7].CGPath,
                         (__bridge id)[self caveBezierPathByOffset:1.0].CGPath,
                         ];
    return animation;
}

- (CAAnimationGroup *)arrowLayerAnimation
{
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    moveAnimation.toValue = @(self.arrowLayer.position.y - 20);
    moveAnimation.removedOnCompletion = NO;
    moveAnimation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *toPenAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    toPenAnimation.toValue = (__bridge id _Nullable)([self pencilPath].CGPath);
    toPenAnimation.removedOnCompletion = NO;
    toPenAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.duration = 0.5f;
    group.animations = @[moveAnimation, toPenAnimation];
    return group;
}

- (CAAnimationGroup *)pencilMoveToBeginPoint
{
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint center = CGPointMake(width/2, height/2);
    CABasicAnimation *moveAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    moveAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(center.x - height, height - 7)];
    
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.toValue = @(M_PI/8);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[moveAnimation,rotateAnimation];
    group.removedOnCompletion = NO;
    group.duration = 0.5;
    group.fillMode = kCAFillModeForwards;
    return group;
}

- (UIBezierPath *)pencilPath
{
    CGFloat width = 8.f;
    CGFloat height = 35.f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint startPoint = CGPointMake(self.arrowLayer.position.x-width/2, self.arrowLayer.position.y);
    CGPoint point1 = CGPointMake(startPoint.x+width, startPoint.y);
    CGPoint point2 = CGPointMake(point1.x, point1.y-height);
    CGPoint point3 = CGPointMake(startPoint.x, point2.y);
    CGPoint point4 = CGPointMake(self.arrowLayer.position.x, startPoint.y+7);
    
    [path moveToPoint:startPoint];
    [path addLineToPoint:point1];
    [path addLineToPoint:point2];
    [path addLineToPoint:point3];
    [path addLineToPoint:startPoint];
    [path addLineToPoint:point4];
    [path addLineToPoint:point1];
    [path closePath];
    return path;
}

- (UIBezierPath *)caveBezierPathByOffset:(CGFloat)offsetScale
{
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint center = CGPointMake(width/2, height/2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint beginPoint = CGPointMake(center.x - offsetScale * height , offsetScale * height);
    CGPoint endPoint = CGPointMake(center.x + offsetScale * height, offsetScale * height);
    CGPoint controlPoint = CGPointMake(center.x, height);
    [path moveToPoint:beginPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    return path;
}

- (UIBezierPath *)convexBezierPathByOffset:(CGFloat)offsetScale
{
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint center = CGPointMake(width/2, height/2);
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGPoint beginPoint = CGPointMake(center.x - height , height);
    CGPoint endPoint = CGPointMake(center.x + height, height);
    CGPoint controlPoint = CGPointMake(center.x, height * offsetScale);
    [path moveToPoint:beginPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    return path;
}

- (UIBezierPath *)bezierPathByProgress:(CGFloat)progress
{
    CGFloat width  = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGPoint center = CGPointMake(width/2, height/2);
    
    CGPoint beginPoint = CGPointMake(center.x - height, height);
    CGPoint endPoint   = CGPointMake(center.x - height + height *2 *progress, height);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:beginPoint];
    [path addLineToPoint:endPoint];
    return path;
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    if (!_isDownload) {
        //[self ]
        _isDownload = YES;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressLayer.path = [self bezierPathByProgress:progress].CGPath;
        self.arrowLayer.transform = CATransform3DMakeTranslation(progress*self.frame.size.height*2, 0, 0);
        self.tipLabel.text = [NSString stringWithFormat:@"正在下载:%.1f%@",progress*100,@"%"];
    });
    
    if (progress == 1) {
        dispatch_async(dispatch_get_main_queue(), ^{
             self.tipLabel.text = @"正在解压...";
        });
    }
}

#pragma mark - delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.arrowLayer animationForKey:@"bl_arrowAnimation"] && flag ) {
        [self.arrowLayer addAnimation:[self pencilMoveToBeginPoint] forKey:@"bl_pencilMoveToBeginPoint"];
    }
}

@end
