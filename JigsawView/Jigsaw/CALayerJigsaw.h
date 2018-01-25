//
//  UIViewJigsawLayer.h
//  ImageView
//
//  Created by Malcome on 2018/1/22.
//  Copyright © 2018年 Malcome. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifndef THJJGDSWSTYLE
#define THJJGDSWSTYLE
typedef NS_OPTIONS(NSUInteger, THJigsawStyle){
        
    THJigsawStyle_Top               = 1 << 1,//上边凸起
    THJigsawStyle_Top_Sunken        = 1 << 2,//上边凹陷
    THJigsawStyle_Top_Smoothness    = 1 << 3,//上边平滑
    
    THJigsawStyle_Bottom            = 1 << 4,//下边凸起
    THJigsawStyle_Bottom_Sunken     = 1 << 5,//下边凹陷
    THJigsawStyle_Bottom_Smoothness = 1 << 6,//下边平滑
    
    THJigsawStyle_Left              = 1 << 7,//左边凸起
    THJigsawStyle_Left_Sunken       = 1 << 8,//左边凹陷
    THJigsawStyle_Left_Smoothness   = 1 << 9,//左边平滑
    
    THJigsawStyle_Right             = 1 << 10,//右边凸起
    THJigsawStyle_Right_Sunken      = 1 << 11,//右边凹陷
    THJigsawStyle_Right_Smoothness  = 1 << 12,//右边平滑

};
#endif

@interface CALayer(Jigsaw)

/**
 将本视图改变成拼图的样式
 返回视图变化成拼图的层
 子母配套
 @param style 拼图样式
 @return 拼图样式层
 */
+ (CAShapeLayer *)JigsawViewSize:(CGSize)size WithStyle:(THJigsawStyle)style;

@end
