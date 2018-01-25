//
//  ViewController.m
//  JigsawView
//
//  Created by Malcome on 2018/1/25.
//  Copyright © 2018年 Malcome. All rights reserved.
//

#import "ViewController.h"
#import "SlideAuthView_iPhone.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setUI];

}

- (void)setUI{
    
    SlideAuthView_iPhone * slideAuthView = [[SlideAuthView_iPhone alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame) - 20, 50)];
    [self.view addSubview:slideAuthView];
    
    slideAuthView.imageUrl = @"avatar";
    slideAuthView.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
    
    slideAuthView.contentHeight = 200;
    slideAuthView.jigsawSize = CGSizeMake(50, 50);
    slideAuthView.jigsawOff = CGSizeMake(5, 5);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
