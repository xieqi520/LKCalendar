//
//  Demo4ViewController.m
//  LKCalendar
//
//  Created by karos li on 2017/7/11.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "Demo5ViewController.h"
#import "LKCalendar.h"

@interface EventView : UIView

@property (nonatomic, strong, readonly) UIView *dotView;

@end

@interface EventView()

@property (nonatomic, strong) UIView *dotView;

@end

@implementation EventView

- (instancetype)init {
    self = [super init];
    [self addSubview:self.dotView];
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.dotView.frame = CGRectMake((CGRectGetWidth(self.bounds) - 6) / 2, CGRectGetHeight(self.bounds) - 6, 6, 6);
}

- (UIView *)dotView {
    if (!_dotView) {
        _dotView = [UIView new];
    }
    
    return _dotView;
}

@end

@interface Demo5ViewController () <LKCalendarViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) LKCalendarView *calendarView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray<NSString *> *stringArray;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) NSMutableArray<NSDate *> *eventDates;

@end

@implementation Demo5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"选中上个月当天的后一天";
    self.view.backgroundColor = [UIColor colorWithRed:253.0 / 255.0 green:159.0 / 255.0 blue:17.0 / 255.0 alpha:1];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"今天" style:UIBarButtonItemStylePlain target:self action:@selector(onClickToday)];
    
    [self.view addSubview:self.calendarView];
    [self.view addSubview:self.tableView];
    
    NSDate *now = [NSDate date];
    [self.eventDates addObject:now];
    [self.eventDates addObjectsFromArray:[self generateNextDaysEventOfQuanlity:8 fromDay:now]];
    NSDate *nextMonth = [now lk_nextMonth];
    [self.eventDates addObjectsFromArray:[self generateNextDaysEventOfQuanlity:10 fromDay:nextMonth]];
    
    NSDate *previousMonth = [[NSDate date] lk_previousMonth];
    self.calendarView.monthsDataSourse = @[previousMonth];
    [self.calendarView selectDate:[previousMonth lk_nextDay]];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSDate *previousM = [previousMonth lk_previousMonth];
//        self.calendarView.monthsDataSourse = @[previousM];
//        [self.calendarView selectDate:[previousM lk_previousDay]];
//    });
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.frame = CGRectMake(0, CGRectGetMaxY(self.calendarView.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(self.calendarView.frame));
}

#pragma mark - LKCalendarViewDelegate
- (void)calendarView:(LKCalendarView *)calendarView scrollToMonth:(NSDate *)month withMonthHeight:(CGFloat)monthHeight {
    CGRect rect = self.calendarView.frame;
    rect.size.height = monthHeight;
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveLinear animations:^{
        self.calendarView.frame = rect;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        
    }];
}

- (void)calendarView:(LKCalendarView *)calendarView didSelectDate:(NSDate *)date {
    NSLog(@"%@", date);
}

- (NSInteger)calendarView:(LKCalendarView *)calendarView numberOfEventsForDate:(NSDate *)date {
    
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    for (NSDate *eventDate in self.eventDates) {
        NSString *eventDateString = [self.dateFormatter stringFromDate:eventDate];
        if ([dateString isEqualToString:eventDateString]) {
            return 1;
        }
    }
    
    return 0;
}

- (UIView *)calendarViewEventView:(LKCalendarView *)calendarView forDate:(NSDate *)date {
    NSInteger day = [date lk_day];
    
    if (day == 10) {
        EventView *eventView = [EventView new];
        eventView.backgroundColor = [UIColor brownColor];
        eventView.layer.borderWidth = 1;
        eventView.layer.borderColor = [UIColor redColor].CGColor;
        
        return eventView;
    } else if (day == 25) {
        EventView *eventView = [EventView new];
        eventView.dotView.layer.cornerRadius = 6.0 / 2.0;
        eventView.dotView.backgroundColor = [UIColor whiteColor];
        
        return eventView;
    } else if (day == 27) {
        EventView *eventView = [EventView new];
        eventView.dotView.layer.cornerRadius = 6.0 / 2.0;
        eventView.dotView.layer.borderWidth = 1;
        eventView.dotView.layer.borderColor = [UIColor whiteColor].CGColor;
        
        return eventView;
    }

    return nil;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class]) forIndexPath:indexPath];
    cell.textLabel.text = self.stringArray[indexPath.row];
    
    return cell;
}

#pragma mark - event response
- (void)onClickToday {
    [self.calendarView scrollToToday:YES];
}

#pragma mark - private methods
- (NSMutableArray<NSDate *> *)generateNextDaysEventOfQuanlity:(NSInteger)quanlity fromDay:(NSDate *)fromDay {
    NSDate *nextDay = fromDay;
    NSMutableArray<NSDate *> *days = @[].mutableCopy;
    for (NSInteger i = 0; i < quanlity; i++) {
        nextDay = [nextDay lk_nextDay];
        [days addObject:nextDay];
    }
    
    return days;
}

#pragma mark - getter and setter
- (LKCalendarView *)calendarView {
    if (!_calendarView) {
        LKCalendarConfig *config = [[LKCalendarConfig alloc] init];
        config.menuHeight = 40;
        config.menuTextColor = [UIColor colorWithWhite:1 alpha:0.6];
        config.monthHeight = 0;
        config.dayTextColor = [UIColor whiteColor];
        config.dayOutOfMonthTextColor = [UIColor colorWithWhite:1 alpha:0.6];
        config.selectedDayBackgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
        
        _calendarView = [[LKCalendarView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 400) config:config];
        _calendarView.delegate = self;
        _calendarView.allowsDisplayDayOutOfMonth = YES;
    }
    
    return _calendarView;
}

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

- (NSArray<NSString *> *)stringArray {
    if (!_stringArray) {
        NSMutableArray *stringArray = @[].mutableCopy;
        for (NSInteger i = 1; i <= 20; i++) {
            NSString *string = [NSString stringWithFormat:@"你是猴子派来的逗比 %zd 吗", i];
            [stringArray addObject:string];
        }
        
        _stringArray = [stringArray copy];
    }
    
    return _stringArray;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return _dateFormatter;
}

- (NSMutableArray<NSDate *> *)eventDates {
    if (!_eventDates) {
        _eventDates = @[].mutableCopy;
    }
    
    return _eventDates;
}

@end
