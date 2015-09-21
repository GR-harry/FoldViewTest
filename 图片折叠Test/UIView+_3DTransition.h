//
//  UIView+_3DTransition.h
//  图片折叠Test
//
//  Created by GR on 15/9/20.
//  Copyright © 2015年 GR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (_3DTransition)
/**
 *  @brief  将正交矩阵变为透视矩阵
 */
- (CATransform3D)setTransform3D;
@end
