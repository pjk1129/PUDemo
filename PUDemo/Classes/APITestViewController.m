//
//  APITestViewController.m
//  PUDemo
//
//  Created by JK.Peng on 13-11-3.
//  Copyright (c) 2013年 njut. All rights reserved.
//

#import "APITestViewController.h"
#import "TestManager.h"
#import "QiuShi.h"

@interface APITestViewController ()<TestManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) TestManager    *testManager;
@property (nonatomic, strong) UITableView    *myTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@end

@implementation APITestViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.navigationItem.title = @"糗事API测试";
    [self.myTableView reloadData];
    [self.testManager requestApiStrollSuggest];
    
}

#pragma mark - getter
- (TestManager *)testManager{
    if (!_testManager) {
        _testManager = [[TestManager alloc] init];
        _testManager.delegate = self;
    }
    return _testManager;
}

- (UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        [self.view addSubview:_myTableView];
    }
    return _myTableView;
}

- (void)setDataArray:(NSMutableArray *)dataArray{
    _dataArray = dataArray;
    
    [self.myTableView reloadData];
}

#pragma mark - UITableView datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"StrollCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    QiuShi  *qiushi = [self.dataArray objectAtIndex:[indexPath row]];
    cell.textLabel.text = qiushi.author;
    cell.detailTextLabel.text = qiushi.content;
    return cell;
}


#pragma mark - TestManagerDelegate
- (void)testManagerAPIStrollSuggestDidSuccess:(NSArray *)result;
{
    self.dataArray = [NSMutableArray arrayWithArray:result];
}

@end
