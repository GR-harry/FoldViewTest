
//
//  PageView2.m
//  图片折叠Test
//
//  Created by GR on 15/9/20.
//  Copyright © 2015年 GR. All rights reserved.
//

#import "PageView2.h"
#import <POP.h>
#import "UIView+_3DTransition.h"

@interface PageView2 ()
@property (nonatomic, weak) UIImageView *topView;
@property (nonatomic, weak) UIImageView *bottomView;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, weak) CAGradientLayer *topShadowLayer;
@property (nonatomic, weak) CAGradientLayer *bottomShadowLayer;
@end

@implementation PageView2

- (void)setImage:(UIImage *)image
{
    _image = image;
    
    [self setupTopView];
    [self setupBottomView];
    [self setupGestureRecongnizer];
}

- (void)setupGestureRecongnizer
{
    UIPanGestureRecognizer *topRecongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(topPanGestureReconginzer:)];
    [self.topView addGestureRecognizer:topRecongnizer];
    
    UIPanGestureRecognizer *bottomRecongnizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomPanGestureReconginzer:)];
    [self.bottomView addGestureRecognizer:bottomRecongnizer];
}

#pragma mark - GestureMethod
- (void)topPanGestureReconginzer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    /*
        对于topView， 手势移动y轴距离和旋转的角度之间的关系：
        手指在pageView内可连续向下移动的最大y轴距离，用该值将180°平分（该值记为percent）。用perce乘上手指移动距离就为旋转角度。
     */
    
    // 1. 记录初始y值并将图片带到最上层
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.startY = location.y;
        [self bringSubviewToFront:self.topView];
    }
    
    // 2. 判断触摸点十分在pageView内
    if ([self isLocation:location inView:self]) {
        // 阴影动画
        [self top_shadowAnimationWithLocation:location];
        
        // 计算转动角度
        CGFloat percent = - M_PI / (CGRectGetHeight(self.bounds) - self.startY);
        CGFloat progress = percent * (location.y - self.startY);
        
        if (recognizer.state == UIGestureRecognizerStateChanged)
        {
            POPBasicAnimation *rotationAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            rotationAnim.duration = 0.01;
            rotationAnim.toValue = @(progress);
            [self.topView.layer pop_addAnimation:rotationAnim forKey:@"topViewAnimation"];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
        {
            POPSpringAnimation *recoverAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            recoverAnim.springBounciness = 18.0f;
            recoverAnim.dynamicsMass = 2.0f;
            recoverAnim.dynamicsTension = 200;
            recoverAnim.toValue = @0;
            [self.topView.layer pop_addAnimation:recoverAnim forKey:@"recoverAnimation"];
            self.topShadowLayer.opacity = 0;
            self.bottomShadowLayer.opacity = 0;
        }
        
    } else { // 超出触摸范围
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        recoverAnim.springBounciness = 18.0f;
        recoverAnim.dynamicsMass = 2.0f;
        recoverAnim.dynamicsTension = 200;
        recoverAnim.toValue = @0;
        [self.topView.layer pop_addAnimation:recoverAnim forKey:@"recoverAnimation"];
        self.topShadowLayer.opacity = 0;
        self.bottomShadowLayer.opacity = 0;
    }
    
    recognizer.enabled = YES;
}

- (void)bottomPanGestureReconginzer:(UIPanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:self];
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.startY = location.y;
        [self bringSubviewToFront:self.bottomView];
    }
    
    if ([self isLocation:location inView:self]) {
        // 阴影动画
        [self bottom_shadowAnimationWithLocation:location];
        
        // 计算转换后的角度
        CGFloat percent = M_PI / self.startY;
        CGFloat progress = percent * (self.startY - location.y);
        
        if (recognizer.state == UIGestureRecognizerStateChanged)
        {
            POPBasicAnimation *rotationAnim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            rotationAnim.duration = 0.01f;
            rotationAnim.toValue = @(progress);
            [self.bottomView.layer pop_addAnimation:rotationAnim forKey:@"bottomViewRotationAnimation"];
        }
        else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled)
        {
            POPSpringAnimation *recoverAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
            recoverAnim.springBounciness = 18.0f;
            recoverAnim.dynamicsMass = 2.0f;
            recoverAnim.dynamicsTension = 200.f;
            recoverAnim.toValue = @0;
            [self.bottomView.layer pop_addAnimation:recoverAnim forKey:@"bottomViewRecoverAnimation"];
            self.topShadowLayer.opacity = self.bottomShadowLayer.opacity = 0.0f;
        }
    } else {
        recognizer.enabled = NO;
        POPSpringAnimation *recoverAnim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotationX];
        recoverAnim.springBounciness = 18.0f;
        recoverAnim.dynamicsMass = 2.0f;
        recoverAnim.dynamicsTension = 200.f;
        recoverAnim.toValue = @0;
        [self.bottomView.layer pop_addAnimation:recoverAnim forKey:@"bottomViewRecoverAnimation"];
        self.topShadowLayer.opacity = self.bottomShadowLayer.opacity = 0.0f;
    }
    recognizer.enabled = YES;
}

#pragma mark - 阴影动画
- (void)top_shadowAnimationWithLocation:(CGPoint)location
{
    CGFloat percent0 = 1 / (CGRectGetHeight(self.bounds) - self.startY);
    CGFloat progress0 = percent0 * (location.y - self.startY);
    if ([[self.topView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] > - M_PI_2) {
        self.bottomShadowLayer.opacity = progress0;
        self.topShadowLayer.opacity = progress0;
    } else {
        self.bottomShadowLayer.opacity = progress0;
        self.topShadowLayer.opacity = 0.0f;
    }
}
- (void)bottom_shadowAnimationWithLocation:(CGPoint)location
{
    CGFloat percent0 = 1 / self.startY;
    CGFloat progress0 = percent0 * (self.startY - location.y);
    if ([[self.bottomView.layer valueForKeyPath:@"transform.rotation.x"] floatValue] < M_PI_2) {
        self.bottomShadowLayer.opacity = 0;
        self.topShadowLayer.opacity = 0;
    } else {
        self.bottomShadowLayer.opacity = 0;
        self.topShadowLayer.opacity = progress0;
    }
}

#pragma mark - UI
- (void)setupTopView
{
    UIImageView *topView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) * 0.5)];
    topView.image = [self cutImageWithTag:@"top"];
    topView.userInteractionEnabled = YES;
    [self addSubview:topView];
    self.topView = topView;
    
    // 设置layer层
    // 1. 锚点（0.5，1）和position。
    /*position指的是视图锚点在其父视图中的坐标.默认值是锚点为（0.5，0.5）时，即视图center在父视图中的坐标。*/
    topView.layer.anchorPoint = CGPointMake(0.5, 1);
    topView.layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    // 正交矩阵转透视矩阵
    topView.layer.transform = [topView setTransform3D];
    
    // 设置阴影层
    CAGradientLayer *topShadowLayer = [CAGradientLayer layer];
    topShadowLayer.frame = self.topView.bounds;
    topShadowLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor, (__bridge id)[UIColor blackColor].CGColor];
    topShadowLayer.opacity = 0.0f;
    [self.topView.layer addSublayer:topShadowLayer];
    self.topShadowLayer = topShadowLayer;
}

- (void)setupBottomView
{
    UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.bounds), CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) * 0.5)];
    bottomView.image = [self cutImageWithTag:@"bottom"];
    bottomView.userInteractionEnabled = YES;
    [self addSubview:bottomView];
    self.bottomView = bottomView;
    
    // 设置layer层
    // 1. 锚点（0.5，0）和position。
    bottomView.layer.anchorPoint = CGPointMake(0.5, 0);
    bottomView.layer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    // 正交矩阵转透视矩阵
    bottomView.layer.transform = [bottomView setTransform3D];
    
    // 设置阴影层
    CAGradientLayer *bottomShadowLayer = [CAGradientLayer layer];
    bottomShadowLayer.frame = self.bottomView.bounds;
    bottomShadowLayer.colors = @[(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor clearColor].CGColor];
    bottomShadowLayer.opacity = 0.0f;
    [self.bottomView.layer addSublayer:bottomShadowLayer];
    self.bottomShadowLayer = bottomShadowLayer;
}

#pragma mark - Tool
- (BOOL)isLocation:(CGPoint)location inView:(UIView *)view
{
    return CGRectContainsPoint(view.bounds, location);
}

- (UIImage *)cutImageWithTag:(NSString *)tag
{
    CGSize imageSize = self.image.size;
    CGRect rect = CGRectMake(0, 0, imageSize.width, imageSize.height * 0.5);
    
    if ([tag isEqualToString:@"bottom"]) {
        rect.origin.y = imageSize.height * 0.5;
    }
    
    // 按照范围挖取图片
    CGImageRef imageRef = CGImageCreateWithImageInRect(self.image.CGImage, rect);
    return [UIImage imageWithCGImage:imageRef];
}
@end
