//
//  MNCalendarView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/23/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarView.h"
#import "MNCalendarViewLayout.h"
#import "MNCalendarViewDayCell.h"
#import "MNCalendarViewWeekdayCell.h"
#import "MNCalendarHeaderView.h"
#import "MNFastDateEnumeration.h"
#import "NSDate+MNAdditions.h"

@interface MNCalendarView() <UICollectionViewDataSource, UICollectionViewDelegate>

@property(nonatomic,strong,readwrite) UIView           *weekdayLegendsView;
@property(nonatomic,strong,readwrite) UICollectionView *collectionView;
@property(nonatomic,strong,readwrite) UICollectionViewFlowLayout *layout;

@property(nonatomic,strong,readwrite) NSArray *monthDates;
@property(nonatomic,strong,readwrite) NSArray *weekdaySymbols;
@property(nonatomic,assign,readwrite) NSUInteger daysInWeek;

@property(nonatomic,strong,readwrite) NSDateFormatter *monthFormatter;

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date;
- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date;

- (BOOL)dateEnabled:(NSDate *)date;
- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)applyConstraints;

@end

@implementation MNCalendarView

- (void)commonInit {
  
    self.backgroundColor = [UIColor colorWithRed:0.682 green:0.549 blue:0.761 alpha:1.0];
    self.calendar        = NSCalendar.currentCalendar;
    self.fromDate        = [NSDate.date mn_beginningOfDay:self.calendar];
    self.toDate          = [self.fromDate dateByAddingTimeInterval:MN_YEAR * 4];
    self.daysInWeek      = 7;
    
    self.headerViewClass  = MNCalendarHeaderView.class;
    self.dayCellClass     = MNCalendarViewDayCell.class;
    
    
    _legendFont     = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _contentFont    = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    _separatorColor = [UIColor clearColor];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.calendar = self.calendar;
    
    self.weekdaySymbols = formatter.shortWeekdaySymbols;
    
    [self addSubview:self.collectionView];
    [self addSubview:self.weekdayLegendsView];
    [self applyConstraints];
    [self reloadData];
}

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder: aDecoder];
  if ( self ) {
    [self commonInit];
  }
  
  return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    // legend views should be dynamic based on orientation so are drawn in layout subviews
    // start off by clear all subviews of weekday legends view
    [[_weekdayLegendsView subviews]
        makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat xOrigin = 10.0f;
    
    for (NSString *weekdaySymbol in self.weekdaySymbols) {
        
        CGFloat viewWidth = (_weekdayLegendsView.frame.size.width - 20.0f) / 7;
        
        UILabel *weekdaySymbolLabel =
            [[UILabel alloc] initWithFrame:CGRectMake(xOrigin,
                                                     0.0f,
                                                     viewWidth,
                                                     _weekdayLegendsView.frame.size.height)];
        
        [weekdaySymbolLabel setBackgroundColor:[UIColor clearColor]];
        [weekdaySymbolLabel setText:weekdaySymbol];
        [weekdaySymbolLabel setTextColor:[UIColor colorWithRed:0.682 green:0.549 blue:0.761 alpha:1.0]];
        [weekdaySymbolLabel setTextAlignment:NSTextAlignmentCenter];
        [weekdaySymbolLabel setFont:[self.legendFont fontWithSize:12.0f]];
        
        [_weekdayLegendsView addSubview:weekdaySymbolLabel];
        
        xOrigin += viewWidth;
    }
}

- (UIView *) weekdayLegendsView
{
    if (nil == _weekdayLegendsView) {
        
        _weekdayLegendsView =
            [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.frame.size.width, 25.0f)];
        
        _weekdayLegendsView.backgroundColor =
            [UIColor colorWithRed:0.4 green:0.259 blue:0.482 alpha:1.0];
        _weekdayLegendsView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    
    return _weekdayLegendsView;
}

- (UICollectionView *)collectionView {
  if (nil == _collectionView) {
    MNCalendarViewLayout *layout = [[MNCalendarViewLayout alloc] init];

    _collectionView =
      [[UICollectionView alloc] initWithFrame:CGRectZero
                         collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    
    [self registerUICollectionViewClasses];
  }
  return _collectionView;
}

- (void)setLegendFont:(UIFont *)legendFont {
    _legendFont = legendFont;
}

- (void)setContentFont:(UIFont *)contentFont {
    _contentFont = contentFont;
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
  _separatorColor = separatorColor;
}

- (void)setCalendar:(NSCalendar *)calendar {
  _calendar = calendar;
  
  self.monthFormatter = [[NSDateFormatter alloc] init];
  self.monthFormatter.calendar = calendar;
  [self.monthFormatter setDateFormat:@"MMMM yyyy"];
}

- (void)setSelectedDate:(NSDate *)selectedDate {
  _selectedDate = [selectedDate mn_beginningOfDay:self.calendar];
}

- (void)reloadData {
  NSMutableArray *monthDates = @[].mutableCopy;
  MNFastDateEnumeration *enumeration =
    [[MNFastDateEnumeration alloc] initWithFromDate:[self.fromDate mn_firstDateOfMonth:self.calendar]
                                             toDate:[self.toDate mn_firstDateOfMonth:self.calendar]
                                           calendar:self.calendar
                                               unit:NSMonthCalendarUnit];
  for (NSDate *date in enumeration) {
    [monthDates addObject:date];
  }
  self.monthDates = monthDates;
  
  [self.collectionView reloadData];
}

- (void)registerUICollectionViewClasses {
  [_collectionView registerClass:self.dayCellClass
      forCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier];
  
  [_collectionView registerClass:self.headerViewClass
      forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:MNCalendarHeaderViewIdentifier];
}

- (NSDate *)firstVisibleDateOfMonth:(NSDate *)date {
  date = [date mn_firstDateOfMonth:self.calendar];
  
  NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                fromDate:date];
  
  return
    [[date mn_dateWithDay:-((components.weekday - 1) % self.daysInWeek) calendar:self.calendar] dateByAddingTimeInterval:MN_DAY];
}

- (NSDate *)lastVisibleDateOfMonth:(NSDate *)date {
  date = [date mn_lastDateOfMonth:self.calendar];
  
  NSDateComponents *components =
    [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSWeekdayCalendarUnit
                     fromDate:date];
  
  return
    [date mn_dateWithDay:components.day + (self.daysInWeek - 1) - ((components.weekday - 1) % self.daysInWeek)
                calendar:self.calendar];
}

- (void)applyConstraints {
    NSDictionary *views =
        @{@"weekdayLegendsView" : self.weekdayLegendsView,
          @"collectionView" : self.collectionView};
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[weekdayLegendsView]|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[collectionView]-10-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-25-[collectionView]|"
                                             options:0
                                             metrics:nil
                                               views:views]
     ];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[weekdayLegendsView]-0-[collectionView]|"
                                             options:0
                                             metrics:nil
                                               views:views]
     ];
}

- (BOOL)dateEnabled:(NSDate *)date {
  if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)]) {
    return [self.delegate calendarView:self shouldSelectDate:date];
  }
  return YES;
}

- (BOOL)canSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:self.collectionView cellForItemAtIndexPath:indexPath];

  BOOL enabled = cell.enabled;

  if ([cell isKindOfClass:MNCalendarViewDayCell.class] && enabled) {
    MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;

    enabled = [self dateEnabled:dayCell.date];
  }

  return enabled;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
  return self.monthDates.count;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    
    MNCalendarHeaderView *headerView =
        [collectionView dequeueReusableSupplementaryViewOfKind:kind
                                           withReuseIdentifier:MNCalendarHeaderViewIdentifier
                                                  forIndexPath:indexPath];
    
    headerView.backgroundColor = self.collectionView.backgroundColor;
    headerView.font = self.contentFont;
    headerView.titleLabel.text = [self.monthFormatter stringFromDate:self.monthDates[indexPath.section]];

  return headerView;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
  NSDate *monthDate = self.monthDates[section];
  
  NSDateComponents *components =
    [self.calendar components:NSDayCalendarUnit
                     fromDate:[self firstVisibleDateOfMonth:monthDate]
                       toDate:[self lastVisibleDateOfMonth:monthDate]
                      options:0];
  
  return components.day + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MNCalendarViewDayCell *cell =
        [collectionView dequeueReusableCellWithReuseIdentifier:MNCalendarViewDayCellIdentifier
                                                  forIndexPath:indexPath];
    
    cell.font         = self.contentFont;
    cell.separatorColor = self.separatorColor;
    
    NSDate *monthDate = self.monthDates[indexPath.section];
    NSDate *firstDateInMonth = [self firstVisibleDateOfMonth:monthDate];
    
    NSUInteger day = indexPath.item;
    
    NSDateComponents *components =
        [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit
                         fromDate:firstDateInMonth];
    components.day += day;
    
    NSDate *date = [self.calendar dateFromComponents:components];
    [cell setDate:date
            month:monthDate
         calendar:self.calendar];
    
    if (cell.enabled) {
        [cell setEnabled:[self dateEnabled:date]];
    }
    
    if (self.selectedDate && cell.enabled) {
        [cell setSelected:[date isEqualToDate:self.selectedDate]];
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self canSelectItemAtIndexPath:indexPath];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  return [self canSelectItemAtIndexPath:indexPath];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
  MNCalendarViewCell *cell = (MNCalendarViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];

  if ([cell isKindOfClass:MNCalendarViewDayCell.class] && cell.enabled) {
    MNCalendarViewDayCell *dayCell = (MNCalendarViewDayCell *)cell;
    
    self.selectedDate = dayCell.date;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(calendarView:didSelectDate:)]) {
      [self.delegate calendarView:self didSelectDate:dayCell.date];
    }
    
    [self.collectionView reloadData];
  }
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
  
  CGFloat width      = self.bounds.size.width - 20.0f;
  CGFloat itemWidth  = roundf(width / self.daysInWeek);
  CGFloat itemHeight = itemWidth;
  
  NSUInteger weekday = indexPath.item % self.daysInWeek;
  
  if (weekday == self.daysInWeek - 1) {
    itemWidth = width - (itemWidth * (self.daysInWeek - 1));
  }
  
  return CGSizeMake(itemWidth, itemHeight);
}

@end
