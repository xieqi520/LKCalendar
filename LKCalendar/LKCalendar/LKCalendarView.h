//
//  LKCalendarView.h
//  LKCalendar
//
//  Created by karos li on 2017/7/10.
//  Copyright © 2017年 karos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LKCalendarConfig.h"

@class LKCalendarView;

@protocol LKCalendarViewDelegate <NSObject>

@optional
- (void)calendarView:(LKCalendarView *)calendarView scrollToMonth:(NSDate *)month withMonthHeight:(CGFloat)monthHeight;
- (void)calendarView:(LKCalendarView *)calendarView didSelectDate:(NSDate *)date;
- (NSInteger)calendarView:(LKCalendarView *)calendarView numberOfEventsForDate:(NSDate *)date;

@end

@interface LKCalendarView : UIView

@property (nonatomic, weak) id<LKCalendarViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame config:(LKCalendarConfig *)config;

- (void)scrollToToday:(BOOL)animated;
- (void)reloadData;

@end
