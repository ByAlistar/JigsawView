//
//  SlideAuthView_iPhone.h
//  Raineye
//
//  Created by Malcome on 2018/1/23.
//  Copyright © 2018年 Rainbow Department Store Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

//滑动验证码类
//
//
@protocol SlideAuthViewDelegate;

@interface SlideAuthView_iPhone : UIView

///拼图背景墙视图高度 默认为0；
@property (nonatomic,assign) CGFloat contentHeight;
///拼图块范围大小 默认为zero 比jigsawOff优先设置
@property (nonatomic,assign) CGSize jigsawSize;
///拼图确认范围 默认为zero 在拼图范围的基础上做扩大 负数等同正数
@property (nonatomic,assign) CGSize jigsawOff;
///图片地址
@property (nonatomic,copy) NSString * imageUrl;
///提示语文本
@property (nonatomic,copy) NSString * placeholder;
///提示语字体
@property (nonatomic,retain) UIFont * placeholderFont;
///提示语颜色
@property (nonatomic,retain) UIColor * placeholderColor;
///滑块上线条颜色
@property (nonatomic,retain) UIColor * sliderLineColor;

//接受数据对象
@property (nonatomic,weak) id<SlideAuthViewDelegate> delegate;

/**
 重新绘制拼图碎片位置
 */
- (void)refreshJigsaw;

@end

@protocol SlideAuthViewDelegate <NSObject>
//完成拼图返回
- (void)JigsawFinishWith:(SlideAuthView_iPhone *)slideAuthView;

@end
