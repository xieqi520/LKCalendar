//
//  Demo2ViewController.m
//  LKCalendar
//
//  Created by karos li on 2017/7/10.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "Demo2ViewController.h"
#import "LKCalendar.h"

@interface Demo2ViewController () <LKCalendarViewDelegate>

@property (nonatomic, strong) LKCalendarView *calendarView;

@end

@implementation Demo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    [self.view addSubview:self.calendarView];
}

#pragma mark - LKCalendarViewDelegate
- (void)calendarView:(LKCalendarView *)calendarView didSelectDay:(NSDate *)day {
    NSLog(@"%@", day);
}

#pragma mark - getter and setter
- (LKCalendarView *)calendarView {
    if (!_calendarView) {
        LKCalendarConfig *config = [[LKCalendarConfig alloc] init];
        config.isPagingEnabled = YES;
        
        _calendarView = [[LKCalendarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 400) config:config];
        _calendarView.delegate = self;
    }
    
    return _calendarView;
}

@end
