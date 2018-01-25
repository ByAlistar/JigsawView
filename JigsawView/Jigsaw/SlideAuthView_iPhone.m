//
//  SlideAuthView_iPhone.m
//  Raineye
//
//  Created by Malcome on 2018/1/23.
//  Copyright © 2018年 Rainbow Department Store Co., Ltd. All rights reserved.
//

#import "SlideAuthView_iPhone.h"
#import "CALayerJigsaw.h"

#ifndef Mask8

#define Mask8(x) ( (x) & 0xFF )
#define R(x) ( Mask8(x >> 16 ) )
#define G(x) ( Mask8(x >> 8 ) )
#define B(x) ( Mask8(x) )

#endif

@interface UIColor (THLibraries)

/**
 * @brief   根据十六进制颜色值获取UIColor对象。
 *
 * @param   hexValue    十六进制颜色值。
 *
 * @return  UIColor对象。
 */
+ (UIColor *)colorWithHex:(NSInteger)hexValue;
@end

@implementation UIColor(THLibraries)

+ (UIColor *)colorWithHex:(NSInteger)hexValue{
    
    UIColor * color = [UIColor colorWithRed:R(hexValue)/255.0 green:G(hexValue)/255.0 blue:B(hexValue)/255.0 alpha:1.0];
    
    return color;
}


@end

@interface SlideAuthView_iPhone()<UIGestureRecognizerDelegate>{
    
    CGRect rightJigsawRect_;//拼图范围
    BOOL isScreenshot_;//是否抠出拼图
}
@property (nonatomic,retain) UIView  * contentView;//内容视图
@property (nonatomic,retain) UILabel * placeholderLabel;//提示文栏
@property (nonatomic,retain) UIImageView * presentImageView;//拼图模板视图
@property (nonatomic,retain) UIView * jigsawView;//拼图碎片视图
@property (nonatomic,retain) UIView * slideView;//滑块视图
@property (nonatomic,retain) CAShapeLayer * slideLayer;//滑块中心绘图

@property (nonatomic,assign) CGRect randomRect;//随机截图范围
@property (nonatomic,assign) THJigsawStyle style;//拼图样式

@end

@implementation SlideAuthView_iPhone

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
        self.layer.borderColor = [UIColor colorWithHex:0xe0e0e0].CGColor;
        self.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)layoutSubviews{
    /**
     改变self.frame之后会调用此函数
     作用：1.调整滑块的大小、初始位置、外观
     2.调整拼图背景墙与内容视图的范围与位置
     3.
     */
    [super layoutSubviews];
    //本视图外观设置
    self.layer.cornerRadius = CGRectGetHeight(self.frame)/2;
    //内容视图位置与大小设置
    self.contentView.frame = CGRectMake(0, -self.contentHeight - 10, CGRectGetWidth(self.frame), self.contentHeight);
    //拼图视图位置与大小设置
    self.presentImageView.frame = CGRectInset(self.contentView.bounds, 10, 10);
    
    //滑块位置、大小、外观设置
    CGFloat d = CGRectGetHeight(self.frame) - 10;
    self.slideView.frame = CGRectMake(0, 0, d, d);
    self.slideView.center = CGPointMake(CGRectGetHeight(self.frame)/2, CGRectGetHeight(self.frame)/2);
    self.slideView.layer.cornerRadius = d/2;
    self.slideView.layer.shadowColor = [UIColor colorWithHex:0xe0e0e0].CGColor;
    self.slideView.layer.shadowOffset = CGSizeMake(0, 0);
    self.slideView.layer.shadowOpacity = 1.0;
    
    [self.slideLayer removeFromSuperlayer];
    CGPathRelease(self.slideLayer.path);//将之前的绘制路劲释放掉 配置新的绘制路劲
    self.slideLayer.path = nil;
    self.slideLayer.path = [self drawSlideLine].CGPath;
    [self.slideView.layer addSublayer:self.slideLayer];
    [self bringSubviewToFront:self.slideView];

    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.font = self.placeholderFont;
    self.placeholderLabel.textColor = self.placeholderColor;
}

#pragma mark - 内容属性设置
- (void)setContentHeight:(CGFloat)contentHeight{
    //内容视图高度
    if (fabs(_contentHeight - contentHeight) < 0.0000001) {
        return;
    }
    _contentHeight = contentHeight;
}

- (void)setImageUrl:(NSString *)imageUrl{
    //设置图片地址并显示图片
    if ([_imageUrl isEqualToString:imageUrl]) {
        return;
    }
    
    _imageUrl = imageUrl;
    UIImage * image = [UIImage imageNamed:_imageUrl];
    [self.presentImageView setImage:image];
}

- (void)setJigsawSize:(CGSize)jigsawSize{
    //设置拼图范围
    if (CGSizeEqualToSize(_jigsawSize, jigsawSize)) {
        return;
    }
    _jigsawSize = jigsawSize;
}

- (void)setJigsawOff:(CGSize)jigsawOff{
    //设置拼图确认范围扩大量
    if (CGSizeEqualToSize(_jigsawOff, jigsawOff)) {
        return;
    }
    
    _jigsawOff = CGSizeMake(fabs(jigsawOff.width), fabs(jigsawOff.height));
}

- (void)setClipsToBounds:(BOOL)clipsToBounds{
    //隔绝外界 设置遮蔽属性
    [super setClipsToBounds:NO];
}

- (UIColor *)sliderLineColor{
    if (_sliderLineColor == nil) {
        _sliderLineColor = [UIColor colorWithHex:0xFED226];
    }
    return _sliderLineColor;
}

- (UIColor *)placeholderColor{
    if (_placeholderColor == nil) {
        _placeholderColor = [UIColor colorWithHex:0xe0e0e0];
    }
    return _placeholderColor;
}

- (NSString *)placeholder{
    if (_placeholder) {
        _placeholder = @"按住左边滑动，拖动完成上方拼图";
    }
    return _placeholder;
}

- (THJigsawStyle)style{
    if (_style == 0) {
        //上边为平滑 则下边不为平滑
        int top     = 1 << ( arc4random() % 3 + 1 );
        int T = top == THJigsawStyle_Top_Smoothness ? 2 : 3;
        int bottom  = 1 << ( arc4random() % T + 4 );
        //左边为平滑 则右边不为平滑
        int left    = 1 << ( arc4random() % 3 + 7 );
        int L = left == THJigsawStyle_Left_Smoothness ? 2 : 3;
        int right   = 1 << ( arc4random() % L + 10);
        
        _style = top | left | bottom | right;
    }
    return _style;
}

- (CGRect)randomRect{
    //拼图随机范围
    if (CGRectEqualToRect(CGRectZero, _randomRect)) {
        //呈现图片范围
        CGSize presentImageViewSize = self.presentImageView.frame.size;
        //拼图截图最大宽度
        CGFloat maxWidth = self.jigsawSize.width + 2*self.jigsawOff.width;
        //限定截图位置
        CGFloat maxX = presentImageViewSize.width/2 - maxWidth;
        CGFloat maxY = presentImageViewSize.height - (self.jigsawSize.height + 2 * self.jigsawOff.height);
        //随机截图位置
        CGFloat randomX = arc4random()%((int)( maxX)) + presentImageViewSize.width/2;
        CGFloat randomY = arc4random()%((int)maxY) + self.jigsawOff.height;
        
        _randomRect.size = self.jigsawSize;
        _randomRect.origin = CGPointMake(randomX, randomY);
        
        CGPoint center = CGPointMake(CGRectGetMidX(_randomRect), CGRectGetMidY(_randomRect));
        
        CGFloat width = _jigsawSize.width + 2*_jigsawOff.width;
        CGFloat height = _jigsawSize.height + 2*_jigsawOff.height;
        
        rightJigsawRect_ = CGRectMake(center.x - width/2, center.y - height/2, width, height);
    }
    return _randomRect;
}

#pragma mark - 内容视图创建
- (UIImageView *)presentImageView{
    //拼图模板视图
    if (_presentImageView == nil) {
        _presentImageView = [[UIImageView alloc]init];
        _presentImageView.layer.borderColor = [UIColor colorWithHex:0xe0e0e0].CGColor;
        _presentImageView.layer.borderWidth = 1.0;
        _presentImageView.clipsToBounds = YES;
        _presentImageView.frame = CGRectInset(self.contentView.bounds, 10, 10);
        [self.contentView addSubview:_presentImageView];
    }
    return _presentImageView;
}

- (UIView *)contentView{
    //内容视图
    if (_contentView == nil) {
        _contentView = [[UIView alloc] init];
        [self addSubview:_contentView];
        _contentView.backgroundColor = [UIColor colorWithHex:0xF6F6F6];
        _contentView.layer.borderColor = [UIColor colorWithHex:0xe0e0e0].CGColor;
        _contentView.layer.borderWidth = 1.0;
        _contentView.layer.cornerRadius = 5.0;
        _contentView.hidden = YES;
    }
    return _contentView;
}

- (UILabel *)placeholderLabel{
    //提示语视图
    if (_placeholderLabel == nil) {
        _placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame) - 2 * (CGRectGetHeight(self.frame) - 10) -10, CGRectGetHeight(self.frame))];
        [self addSubview:_placeholderLabel];
        _placeholderLabel.center = CGPointMake(CGRectGetWidth(self.frame)/2, CGRectGetHeight(self.frame)/2);
        _placeholderLabel.textAlignment = NSTextAlignmentCenter;
        _placeholderLabel.adjustsFontSizeToFitWidth = YES;
    }
    
    return _placeholderLabel;
}

- (UIView *)jigsawView{
    if (_jigsawView == nil) {
        //拼图碎片视图
        _jigsawView = [[UIView alloc] init];
        _jigsawView.backgroundColor = [UIColor clearColor];
        _jigsawView.frame = CGRectMake(0, 0, self.jigsawSize.width, self.jigsawSize.height);
        //设置阴影
        _jigsawView.layer.shadowOffset = CGSizeMake(0, 0);
        _jigsawView.layer.shadowRadius = 10;
        _jigsawView.layer.shadowColor = [UIColor blackColor].CGColor;
        _jigsawView.layer.shadowOpacity = 1;
    }
    return _jigsawView;
}

- (UIBezierPath *)drawSlideLine{
    //绘制滑动中心三条竖线
    UIBezierPath * path = [[UIBezierPath alloc] init];
    
    CGFloat centerX = CGRectGetWidth(self.slideView.frame)/2;
    CGFloat centerY = CGRectGetHeight(self.slideView.frame)/2;
    CGFloat lineHeight = CGRectGetWidth(self.slideView.frame)/3;
    //第一条竖线
    [path moveToPoint:CGPointMake(centerX - lineHeight/2, centerY - lineHeight/2)];
    [path addLineToPoint:CGPointMake(centerX - lineHeight/2, centerY + lineHeight/2)];
    //第二条竖线
    [path moveToPoint:CGPointMake(centerX, centerY - lineHeight/2)];
    [path addLineToPoint:CGPointMake(centerX, centerY + lineHeight/2)];
    //第三条竖线
    [path moveToPoint:CGPointMake(centerX + lineHeight/2, centerY - lineHeight/2)];
    [path addLineToPoint:CGPointMake(centerX + lineHeight/2, centerY + lineHeight/2)];
    
    return path;
}

- (UIView *)slideView{
    //滑块视图
    if (_slideView == nil) {
        _slideView = [[UIView alloc] init];
        _slideView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_slideView];
        
        //拖拽手势 移动滑块
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(slideViewMove:)];
        pan.delegate = self;
        [_slideView addGestureRecognizer:pan];
    }
    return _slideView;
}

- (CAShapeLayer *)slideLayer{
    //三竖线路劲上的属性
    if (_slideLayer == nil) {
        _slideLayer = [[CAShapeLayer alloc] init];
        _slideLayer.strokeColor = [UIColor colorWithHex:0xe0e0e0].CGColor;
        _slideLayer.lineWidth = 3.0;
        _slideLayer.lineCap = @"round";
    }
    return _slideLayer;
}

#pragma mark - 滑块触摸事件
- (void)slideViewMove:(UIPanGestureRecognizer *)pan{
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan://开始
            break;
        case UIGestureRecognizerStateChanged://滑动
        {
            NSLog(@"====>move");
            CGPoint p = [pan translationInView:_slideView];
            //限制slideView移动范围
            CGFloat x = self.slideView.center.x + p.x;
            CGFloat minX = CGRectGetHeight(self.frame)/2;
            CGFloat maxX = CGRectGetWidth(self.frame) - minX;
            x = x < minX ? minX : x;
            x = x > maxX ? maxX : x;
            CGFloat offX = x - self.slideView.center.x;
            self.slideView.center = CGPointMake(x, self.slideView.center.y);
            self.jigsawView.center = CGPointMake(self.jigsawView.center.x + offX, self.jigsawView.center.y);
            
            
            //隐藏提示文
            _placeholderLabel.alpha -= p.x/20;
            
            [pan setTranslation:CGPointZero inView:self];
        }
            break;
        case UIGestureRecognizerStateEnded://结束
        case UIGestureRecognizerStateCancelled://中途取消
        case UIGestureRecognizerStateFailed://识别失败
            
            if ([self JigsawViewIsRight]) {
                NSLog(@"验证通过");
                [self refreshJigsaw];
            }else{
                NSLog(@"验证不通过");
            }
            [self hiddenContentView:YES];
            [self touchActionCancel];
            break;
        default:
            break;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesBegan:touches withEvent:event];
    //取出触摸点 判断触摸点位置
    UITouch * touch = [[touches allObjects] firstObject];
    CGPoint point = [touch locationInView:self];
    
    BOOL inSlide = CGRectContainsPoint(_slideView.frame, point);
    if (inSlide) {
        //显示内容视图
        [self hiddenContentView:NO];
        //呈现视图
        [self imageViewDidLoadSuccessful];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.nextResponder touchesEnded:touches withEvent:event];
    //触摸结束 隐藏内容视图
    [self hiddenContentView:YES];
}

#pragma mark - 私有方法
- (void)imageViewDidLoadSuccessful{
   
    if (isScreenshot_) {
        return;
    }
    isScreenshot_ = YES;
   
    //截取拼图碎片图片
    UIImage * image = [self screenshotWithView:self.presentImageView inRect:self.randomRect];
   
    //优先绘制拼图缺少的部分
    CAShapeLayer * JigsawShaowLayer = [CAShapeLayer JigsawViewSize:self.jigsawSize
                                                         WithStyle:self.style];
    JigsawShaowLayer.fillColor = [UIColor colorWithWhite:1.0 alpha:0.5].CGColor;
    JigsawShaowLayer.frame = self.randomRect;
    JigsawShaowLayer.strokeColor = JigsawShaowLayer.fillColor;
    JigsawShaowLayer.shadowColor = [UIColor blackColor].CGColor;
    JigsawShaowLayer.shadowOpacity = 1;
    JigsawShaowLayer.shadowOffset = CGSizeMake(0, 0);
    [JigsawShaowLayer setFillRule:kCAFillRuleEvenOdd];
    [self.presentImageView.layer addSublayer:JigsawShaowLayer];
    
    //拼图碎片边框
    CAShapeLayer * borderLayer = [CAShapeLayer JigsawViewSize:self.jigsawSize
                                                    WithStyle:self.style];
    borderLayer.strokeColor = [UIColor colorWithHex:0xFED226].CGColor;
    borderLayer.lineWidth = 3.0;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    
    //拼图样式裁剪图片视图
    CAShapeLayer * jigsawLayer1 = [CAShapeLayer JigsawViewSize:self.jigsawSize
                                                    WithStyle:self.style];
    UIImageView * smallImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.jigsawSize.width, self.jigsawSize.height)];
    smallImageView.image = image;
    smallImageView.layer.mask = jigsawLayer1;
    smallImageView.center = CGPointMake(CGRectGetWidth(self.jigsawView.bounds)/2, CGRectGetHeight(self.jigsawView.bounds)/2);
    [smallImageView.layer addSublayer:borderLayer];
    [self.jigsawView addSubview:smallImageView];

    self.jigsawView.layer.shadowPath = JigsawShaowLayer.path;
    
    //拼图碎片随机中点
    CGFloat maxX = CGRectGetWidth(self.presentImageView.frame)/2 - CGRectGetWidth(self.jigsawView.frame)/2;
    CGFloat minX = CGRectGetWidth(self.jigsawView.frame)/2 + 5;
    CGFloat randX = arc4random()%((int)(maxX - minX)) + minX;
    self.jigsawView.center = CGPointMake(randX, CGRectGetMidY(self.randomRect));
    
    [self.presentImageView addSubview:_jigsawView];
    [self.presentImageView bringSubviewToFront:self.jigsawView];
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    //当前图片截图
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    CGImageRelease(newImageRef);
    
    return newImage;
}

- (UIImage *)screenshotWithView:(UIView *)view inRect:(CGRect)rect;
{
    //当前视图截图
    CGRect frame = view.frame;
    UIGraphicsBeginImageContext(frame.size);
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:contextRef];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    return [self imageFromImage:image inRect:rect];
}

- (void)touchActionCancel{
    //触摸行为取消
    /**
     1.滑块归位
     2.拼图归位
     3.字体显示
     */
    ///滑块动画结束位置
    CGPoint slideFinishCenter = CGPointMake(CGRectGetHeight(self.frame)/2, CGRectGetHeight(self.frame)/2);
    ///滑块从动画开始到结束位置的距离
    CGFloat space = _slideView.center.x - slideFinishCenter.x;
    ///拼图归位的终点
    CGPoint JigsawViewCenter = CGPointMake(self.jigsawView.center.x - space, self.jigsawView.center.y);
    ///启动动画
    [UIView animateWithDuration:0.2 animations:^{
        _slideView.center = slideFinishCenter;
        _placeholderLabel.alpha = 1.0;
        self.jigsawView.center = JigsawViewCenter;
    }];
}

- (BOOL)JigsawViewIsRight{
    //拼图碎片位置正确判断
    return CGRectContainsRect(rightJigsawRect_, self.jigsawView.frame);
}

- (void)hiddenContentView:(BOOL)isHidden{
    //设置内容视图隐藏属性
    self.contentView.hidden = isHidden;
    self.slideLayer.strokeColor = isHidden ? [UIColor colorWithHex:0xe0e0e0].CGColor :self.sliderLineColor.CGColor;
}

#pragma mark - 公共方法
- (void)refreshJigsaw{
    isScreenshot_ = NO;
    [self.jigsawView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.jigsawView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    [self.presentImageView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.presentImageView.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    self.randomRect = CGRectZero;
    self.style = 0;
}


@end
