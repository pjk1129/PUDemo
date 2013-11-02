//
//  TestViewController.m
//  PUDemo
//
//  Created by JK.Peng on 13-10-31.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "TestViewController.h"
#import "PhotosViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"测试";
    
    UIButton  *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:@"图片浏览测试" forState:UIControlStateNormal];
    button.frame = CGRectMake(110, CGRectGetHeight(self.view.frame)/2-60, 100, 40);
    [button addTarget:self action:@selector(photoBrowsers) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton  *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button1 setTitle:@"HTTP请求测试" forState:UIControlStateNormal];
    button1.frame = CGRectMake(110, CGRectGetHeight(self.view.frame)/2+20, 100, 40);
    [button1 addTarget:self action:@selector(httpRequest) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    
}

- (void)photoBrowsers{
    PhotosViewController  *controller = [[PhotosViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)httpRequest{
    
}

@end
