//
//  UIView+_3DTransition.m
//  图片折叠Test
//
//  Created by GR on 15/9/20.
//  Copyright © 2015年 GR. All rights reserved.
//

#import "UIView+_3DTransition.h"

@implementation UIView (_3DTransition)
- (CATransform3D)setTransform3D
{
    //如果不设置这个值，无论转多少角度都不会有3D效果
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = 2.5/-2000;
    return transform;
}
@end
