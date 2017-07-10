//
//  Demo1ViewController.m
//  LKCalendar
//
//  Created by karos li on 2017/7/7.
//  Copyright © 2017年 karos. All rights reserved.
//

#import "Demo1ViewController.h"
#import "LKCalendarCollectionViewLayout.h"
#import "LKCalendarCell.h"
#import "LKCalendarSectionView.h"
#import "NSDate+LKCalendar.h"

@interface Demo1ViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) LKCalendarCollectionViewLayout *layout;

@property (nonatomic, strong) NSDate *currentMonth;
@property (nonatomic, strong) NSMutableArray<NSDate *> *dates;

@end

@implementation Demo1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.isPagingEnabled = YES;
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerClass:[LKCalendarCell class] forCellWithReuseIdentifier:NSStringFromClass([LKCalendarCell class])];
    [self.collectionView registerClass:[LKCalendarSectionView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LKCalendarSectionView class])];
    
    self.dates = [NSMutableArray array];
    NSDate *currentMonth = [NSDate date];
    [self.dates addObject:currentMonth];
    
    NSDate *previousMonth = currentMonth;
    for (NSInteger i = 0; i < 1 * 3; i++) {
        previousMonth = [previousMonth lk_previousMonth];
        [self.dates insertObject:previousMonth atIndex:0];
    }
    
    NSDate *nextMonth = currentMonth;
    for (NSInteger i = 0; i < 1 * 3; i++) {
        nextMonth = [nextMonth lk_nextMonth];
        [self.dates addObject:nextMonth];
    }
    
    self.currentMonth = currentMonth;
    self.layout.dates = self.dates;
    
    self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 500);
    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];
    [self scrollToToday:NO];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.dates.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.dates[section] lk_numberOfDaysOfMonth];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    LKCalendarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([LKCalendarCell class]) forIndexPath:indexPath];
    
    NSDate *month = self.dates[indexPath.section];
    if ([NSDate lk_isDate:self.currentMonth inSameDayAsDate:[NSDate lk_setDay:indexPath.item + 1 toMonth:month]]) {
        cell.textLabel.text = @"今天";
    } else {
        cell.textLabel.text = [@(indexPath.item + 1) stringValue];
    }
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    LKCalendarSectionView *section = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass([LKCalendarSectionView class]) forIndexPath:indexPath];
    section.textLabel.text = [[self dateFormatter] stringFromDate:self.dates[indexPath.section]];
    
    return section;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isPagingEnabled) {
            if (scrollView.contentOffset.y < CGRectGetHeight(scrollView.bounds) * 2) {
                [self appendPastMonths];
            }
            
            if (scrollView.contentOffset.y + CGRectGetHeight(scrollView.bounds) * 2 > scrollView.contentSize.height) {
                [self appendFutureMonths];
            }
        }
    });
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    if (self.isPagingEnabled) {
        // 升序
        NSArray *sortedIndexPathsForVisibleItems = [[self.collectionView indexPathsForVisibleItems]  sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath * obj2) {
            return obj1.section > obj2.section;
        }];

        NSInteger visibleSection;
        NSInteger nextSection;
        if (velocity.y > 0.0) { // 加速度情况下 下一页
            NSArray *filterItems = [sortedIndexPathsForVisibleItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath  * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject item] == 0;
            }]];

            visibleSection = [[filterItems firstObject] section];
            nextSection = visibleSection + 1;
        } else if (velocity.y < 0.0) { // 加速度情况下 上一页
            // 由于一个月最小是28天，进行过滤只取出27号以后的 indexPath.
            NSArray *filterItems = [sortedIndexPathsForVisibleItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath  * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                return [evaluatedObject item] > 26;
            }]];
            
            visibleSection = [[filterItems lastObject] section];
            nextSection = visibleSection - 1;
        } else { // 非加速度情况下，取中间 item 来决定去哪一页
            visibleSection = [sortedIndexPathsForVisibleItems[sortedIndexPathsForVisibleItems.count / 2] section];
            nextSection = visibleSection;
        }
    
        // 安全判断
        nextSection = MAX(MIN([self.collectionView numberOfSections] - 1, nextSection), 0);
    
        // 获取 section 的frame
        NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:nextSection];
        CGRect sectionFrame = [self.layout sectionFrameAtIndexPath:sectionIndexPath];
    
        // 设置最终 collectionView 的滚动位置
        CGPoint topOfHeader = CGPointMake(0, sectionFrame.origin.y - self.collectionView.contentInset.top);
        *targetContentOffset = topOfHeader;
        scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

#pragma mark - load more months
- (void)appendFutureMonths {
    NSDate *lastMonth = self.dates.lastObject;
    NSDate *nextMonth = lastMonth;
    for (NSInteger i = 0; i < 1 * 3; i++) {
        nextMonth = [nextMonth lk_nextMonth];
        [self.dates addObject:nextMonth];
    }
    [self.collectionView reloadData];
}

- (void)appendPastMonths {
//    NSArray *sortedIndexPathsForVisibleItems = [[self.collectionView indexPathsForVisibleItems]  sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *obj1, NSIndexPath * obj2) {
//        return obj1.section > obj2.section;
//    }];
//    
//    NSArray *filterItems = [sortedIndexPathsForVisibleItems filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSIndexPath  * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
//        return [evaluatedObject item] == 0;
//    }]];
//
//    NSIndexPath *originSectionIndexPath = filterItems.firstObject;
//    NSDate *originSectionDate = [self.dates objectAtIndex:originSectionIndexPath.section];
//    CGRect originSectionFrame = [self.layout sectionFrameAtIndexPath:originSectionIndexPath];
//    
//    NSDate *firstMonth = self.dates.firstObject;
//    NSDate *previousMonth = firstMonth;
//    for (NSInteger i = 0; i < 1 * 3; i++) {
//        previousMonth = [previousMonth lk_previousMonth];
//        [self.dates insertObject:previousMonth atIndex:0];
//    }
//    
//    [self.collectionView reloadData];
//    [self.collectionView layoutIfNeeded];
//    
//    NSInteger nowSectionIndex = [self.dates indexOfObject:originSectionDate];
//    NSIndexPath *nowSectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:nowSectionIndex];
//    CGRect nowSectionFrame = [self.layout sectionFrameAtIndexPath:nowSectionIndexPath];
//    
//    [self.collectionView setContentOffset:CGPointMake(0, self.collectionView.contentOffset.y + (nowSectionFrame.origin.y - originSectionFrame.origin.y))];
    
    NSArray *visibleCells = [self.collectionView visibleCells];
    if (![visibleCells count])
        return;
    
    NSIndexPath *originIndexPath = [self.collectionView indexPathForCell:((UICollectionViewCell *)visibleCells[0]) ];
    NSInteger originSection = originIndexPath.section;
    
    NSDate *firstMonth = self.dates.firstObject;
    NSDate *previousMonth = firstMonth;
    for (NSInteger i = 0; i < 1 * 3; i++) {
        previousMonth = [previousMonth lk_previousMonth];
        [self.dates insertObject:previousMonth atIndex:0];
    }

    [self.collectionView reloadData];
    [self.collectionView layoutIfNeeded];

    NSInteger nowSectionIndex = originSection + 3;
    NSIndexPath *nowSectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:nowSectionIndex];
    CGRect nowSectionFrame = [self.layout sectionFrameAtIndexPath:nowSectionIndexPath];
    
    [self.collectionView setContentOffset:CGPointMake(0, nowSectionFrame.origin.y)];
}

#pragma mark - private methods
- (void)scrollToToday:(BOOL)animated {
    [self scrollToDate:self.currentMonth animated:animated];
}

- (void)scrollToDate:(NSDate *)date animated:(BOOL)animated {
    NSIndexPath *sectionIndexPath = [NSIndexPath indexPathForItem:0 inSection:[self.dates indexOfObject:date]];
    
    CGRect sectionFrame = [self.layout sectionFrameAtIndexPath:sectionIndexPath];
    [self.collectionView setContentOffset:CGPointMake(0, sectionFrame.origin.y - self.collectionView.contentInset.top) animated:animated];
}

#pragma mark - getter and setter
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    
    return _collectionView;
}

- (LKCalendarCollectionViewLayout *)layout {
    if (!_layout) {
        _layout = [[LKCalendarCollectionViewLayout alloc] init];
    }
    
    return _layout;
}

- (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy . M"];
    });

    return formatter;
}

@end
