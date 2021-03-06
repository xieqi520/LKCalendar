//
//  HomeTestViewController.m
//  LKTopMessage
//
//  Created by karos li on 2017/6/30.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "HomeTestViewController.h"
#import "Demo1ViewController.h"
#import "Demo2ViewController.h"
#import "Demo3ViewController.h"
#import "Demo4ViewController.h"
#import "Demo5ViewController.h"

typedef  NS_ENUM(NSInteger, TestType) {
    TestTypeRangeCalendar,
    TestTypePageCalendar,
    TestTypePageCalendarDynamic,
    TestTypePageCalendarEvent,
    TestTypePageCalendarSinglePageCustomStyle,
};

static NSArray *testTypes;

@interface HomeTestViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation HomeTestViewController

+ (void)initialize {
    if (self == [HomeTestViewController self]) {
        testTypes = @[@{@"type" : @(TestTypeRangeCalendar),
                        @"desc" : @"显示日历"},
                      @{@"type" : @(TestTypePageCalendar),
                        @"desc" : @"日历分页"},
                      @{@"type" : @(TestTypePageCalendarDynamic),
                        @"desc" : @"日历分页并改变自身大小"},
                      @{@"type" : @(TestTypePageCalendarEvent),
                        @"desc" : @"日历分页并显示事件"},
                      @{@"type" : @(TestTypePageCalendarSinglePageCustomStyle),
                        @"desc" : @"日历单页并显示自定义事件"}
                      ];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.tableView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:self.tableView];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return testTypes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = testTypes[indexPath.row][@"desc"];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TestType type = [testTypes[indexPath.row][@"type"] integerValue];
    
    if (type == TestTypeRangeCalendar) {
        [self.navigationController pushViewController:[Demo1ViewController new] animated:YES];
    } else if (type == TestTypePageCalendar) {
        [self.navigationController pushViewController:[Demo2ViewController new] animated:YES];
    } else if (type == TestTypePageCalendarDynamic) {
        [self.navigationController pushViewController:[Demo3ViewController new] animated:YES];
    } else if (type == TestTypePageCalendarEvent) {
        [self.navigationController pushViewController:[Demo4ViewController new] animated:YES];
    } else if (type == TestTypePageCalendarSinglePageCustomStyle) {
        [self.navigationController pushViewController:[Demo5ViewController new] animated:YES];
    }
}

#pragma mark - getter and setter
- (UITableView *)tableView {
    if (!_tableView) {
        UITableView *tableView = [[UITableView alloc] init];
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
        tableView.tableFooterView = [UIView new];
        _tableView = tableView;
    }
    
    return _tableView;
}

@end
