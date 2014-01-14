//
//  MNCalendarHeaderView.m
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarHeaderView.h"

NSString *const MNCalendarHeaderViewIdentifier = @"MNCalendarHeaderViewIdentifier";
static const CGFloat kSidePadding = 10.0f;
static const CGFloat kSeparatorHeight = 0.5f;

@interface MNCalendarHeaderView()

@property(nonatomic,strong,readwrite) UILabel *titleLabel;

@end

@implementation MNCalendarHeaderView

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
      
      self.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
      
      self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(kSidePadding, 0.0f, self.bounds.size.width - kSidePadding, self.bounds.size.height)];
      self.titleLabel.backgroundColor = UIColor.clearColor;
      self.titleLabel.textColor       = UIColor.whiteColor;
      self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
      self.titleLabel.font = [self.font fontWithSize:18.0f];
      self.titleLabel.textAlignment = NSTextAlignmentLeft;
      
      UIView *bottomSeparator =
        [[UIView alloc] initWithFrame:
            CGRectMake(kSidePadding,
                       self.bounds.size.height - kSeparatorHeight - kSidePadding / 2,
                       self.bounds.size.width - kSidePadding * 2,
                       kSeparatorHeight)];
      
      bottomSeparator.backgroundColor = [UIColor whiteColor];
      
      [self addSubview:self.titleLabel];
      [self addSubview:bottomSeparator];
  }
  return self;
}

- (void) setFont:(UIFont *)font
{
    _font = font;
    
    _titleLabel.font = _font;
}

- (void)setDate:(NSDate *)date {
  _date = date;

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

  [dateFormatter setDateFormat:@"MMMM yyyy"];

  self.titleLabel.text = [dateFormatter stringFromDate:self.date];
}

@end
