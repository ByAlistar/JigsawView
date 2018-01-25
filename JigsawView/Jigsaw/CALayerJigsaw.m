//
//  UIViewJigsawLayer.m
//  ImageView
//
//  Created by Malcome on 2018/1/22.
//  Copyright © 2018年 Malcome. All rights reserved.
//

#import "CALayerJigsaw.h"

struct ArcData {
    BOOL    clockwise;
    CGFloat startAngle;
    CGFloat endAngle;
    CGFloat radius;
    CGPoint center;
};
typedef struct ArcData ArcData;

@implementation CALayer (Jigsaw)

+ (CAShapeLayer *)JigsawViewSize:(CGSize)size WithStyle:(THJigsawStyle)style{
    
    CGFloat width = size.width;
    CGFloat height = size.height;
    
    CGFloat r = width/10;//拼图圆弧半径可修改
    CGFloat l = 2  * r ;//拼图圆弧与边相交线段长度
    //勾股定理 求圆心到边的距离
    CGFloat h = sqrt(pow(r, 2.0) - pow(l/2, 2.0));
    
    //取出各方向上的样式
    NSUInteger top = style & (THJigsawStyle_Top_Sunken | THJigsawStyle_Top_Smoothness | THJigsawStyle_Top);
    NSUInteger right = style & (THJigsawStyle_Right | THJigsawStyle_Right_Sunken | THJigsawStyle_Right_Smoothness);
    NSUInteger bottom = style & (THJigsawStyle_Bottom | THJigsawStyle_Bottom_Sunken | THJigsawStyle_Bottom_Smoothness);
    NSUInteger left = style & (THJigsawStyle_Left | THJigsawStyle_Left_Sunken | THJigsawStyle_Left_Smoothness);
    
    //四个顶点坐标
    CGPoint leftTop = CGPointMake(r + h, r + h);
    CGPoint rightTop = CGPointMake(width - r - h, leftTop.y);
    CGPoint rightBottom = CGPointMake(rightTop.x, height - r - h);
    CGPoint leftBottom = CGPointMake(leftTop.x, rightBottom.y);
    
    //四个圆弧中心点坐标
    ArcData topArc = [self getArcDataWithCenter:CGPointMake(width/2, r + h) Radius:r Distance:h style:top];
    NSValue * topArcValue = [[NSValue alloc] initWithBytes:&topArc objCType:@encode(ArcData)];
    
    ArcData leftArc = [self getArcDataWithCenter:CGPointMake(r + h, height/2) Radius:r Distance:h style:left];
    NSValue * leftArcValue = [[NSValue alloc] initWithBytes:&leftArc objCType:@encode(ArcData)];
    
    ArcData bottomArc = [self getArcDataWithCenter:CGPointMake(width/2, height - r - h) Radius:r Distance:h style:bottom];
    NSValue * bottomArcValue = [[NSValue alloc] initWithBytes:&bottomArc objCType:@encode(ArcData)];
    
    ArcData rightArc = [self getArcDataWithCenter:CGPointMake(width - r - h, height/2) Radius:r Distance:h style:right];
    NSValue * rightArcValue = [[NSValue alloc] initWithBytes:&rightArc objCType:@encode(ArcData)];
    
    //关键数据填入
    NSArray * array = @[@(leftTop),topArcValue,@(rightTop),rightArcValue,@(rightBottom),bottomArcValue,@(leftBottom),leftArcValue];
    
    //绘制路径
    CAShapeLayer * JigsawLayer = [CAShapeLayer layer];
    JigsawLayer.lineWidth = 1;
    JigsawLayer.strokeColor = [UIColor redColor].CGColor;
    JigsawLayer.path = [self drawWithData:array];
   
    return JigsawLayer;
}

/**
 绘制圆弧线数据

 @param center 边的中心点
 @param rauids 圆弧半径
 @param distance 圆点到边的距离
 @param style 圆弧方向类型
 @return 圆弧数据
 */
+ (ArcData)getArcDataWithCenter:(CGPoint)center Radius:(CGFloat)rauids Distance:(CGFloat)distance style:(THJigsawStyle)style {
    
    CGFloat x = center.x;
    CGFloat y = center.y;
    
    //ios 角度是逆时针计算
    //y轴正方向0° y轴负方向180°
    //x轴正方向90° x轴负方向270°   0.5 30 
    CGFloat startAngle = 0;
    CGFloat endAngle = 0;
    CGFloat degree = acos(distance/rauids);
    BOOL clockwise = YES;
    
    switch (style) {
       
        case THJigsawStyle_Top://上边凸出
            y = y - distance;
            startAngle  =   0.5*M_PI + degree;
            endAngle    =   0.5*M_PI - degree;
            clockwise = YES;
            break;
        case THJigsawStyle_Bottom_Sunken://下边凹陷
            y = y - distance;
            startAngle  =   0.5*M_PI - degree;
            endAngle    =   0.5*M_PI + degree;
            clockwise = NO;
            break;
            
        case THJigsawStyle_Top_Sunken://上边凹陷
            y = y + distance;
            startAngle  =   1.5*M_PI - degree;
            endAngle    =   1.5*M_PI + degree;
            clockwise = NO;
            break;
        case THJigsawStyle_Bottom://下边凸出
            y = y + distance;
            startAngle  =   1.5*M_PI + degree;
            endAngle    =   1.5*M_PI - degree;
            clockwise = YES;
            break;
        
        case THJigsawStyle_Left://左边凸出
            x = x - distance;
            startAngle  =   degree;
            endAngle    =   2*M_PI - degree;
            clockwise = YES;
            break;
        case THJigsawStyle_Right_Sunken://右边凹陷
            x = x - distance;
            startAngle  =   2*M_PI - degree;
            endAngle    =   degree;
            clockwise = NO;
            break;
            
        case THJigsawStyle_Left_Sunken://左边凹陷
            x = x + distance;
            startAngle  =   M_PI - degree;
            endAngle    =   M_PI + degree;
            clockwise = NO;
            break;
        case THJigsawStyle_Right://右边凸出
            x = x + distance;
            startAngle  =   M_PI + degree;
            endAngle    =   M_PI - degree;
            clockwise = YES;
            break;
        
        case THJigsawStyle_Bottom_Smoothness://下边平滑
        case THJigsawStyle_Right_Smoothness://右边平滑
        case THJigsawStyle_Left_Smoothness://左边平滑
        case THJigsawStyle_Top_Smoothness://上边平滑
            startAngle = 0;
            endAngle = 0;
            clockwise = NO;
            rauids = 0;
            break;
        default:
            break;
    }
    
    ArcData arc;
    arc.center = CGPointMake(x, y);
    arc.startAngle = startAngle;
    arc.endAngle = endAngle;
    arc.clockwise = clockwise;
    arc.radius = rauids;
    return arc;
}

+ (CGPathRef)drawWithData:(NSArray *)array{
   
    UIBezierPath * path = [[UIBezierPath alloc] init];
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth  = 1.0;
   
    //绘制
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSValue * value = (NSValue *)obj;
        if (idx == 0) {
            //开始移动到绘制点
            CGPoint startPoint = [value CGPointValue];
            [path moveToPoint:startPoint];
        }else{
            if (strcmp(value.objCType, @encode(CGPoint)) == 0) {
                //点连线
                CGPoint linePoint = [value CGPointValue];
                [path addLineToPoint:linePoint];
            }else if (strcmp(value.objCType, @encode(ArcData)) == 0){
                //圆弧
                ArcData arc ;
                [value getValue:&arc];
                if (arc.radius != 0) {
                   [path addArcWithCenter:arc.center radius:arc.radius startAngle:arc.startAngle endAngle:arc.endAngle clockwise:arc.clockwise];
                }
            }
        }
    }];
    
    [path closePath];
    
    return path.CGPath;
}

@end
