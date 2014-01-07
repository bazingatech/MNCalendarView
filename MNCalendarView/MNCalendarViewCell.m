//
//  MNCalendarViewCell.m
//  MNCalendarView
//
//  Created by Min Kim on 7/26/13.
//  Copyright (c) 2013 min. All rights reserved.
//

#import "MNCalendarViewCell.h"

void MNContextDrawLine(CGContextRef c, CGPoint start, CGPoint end, CGColorRef color, CGFloat lineWidth) {
  CGContextSetAllowsAntialiasing(c, false);
  CGContextSetStrokeColorWithColor(c, color);
  CGContextSetLineWidth(c, lineWidth);
  CGContextMoveToPoint(c, start.x, start.y - (lineWidth/2.f));
  CGContextAddLineToPoint(c, end.x, end.y - (lineWidth/2.f));
  CGContextStrokePath(c);
  CGContextSetAllowsAntialiasing(c, true);
}

NSString *const MNCalendarViewCellIdentifier = @"MNCalendarViewCellIdentifier";

@interface MNCalendarViewCell()

@property(nonatomic,strong,readwrite) UILabel *titleLabel;

@end

@implementation MNCalendarViewCell

- (id)initWithFrame:(CGRect)frame {
  if (self = [super initWithFrame:frame]) {
      
      _font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
      
      self.backgroundColor = UIColor.whiteColor;
      self.contentView.backgroundColor = UIColor.clearColor;
      
      self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
      self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
      self.titleLabel.font = [self.font fontWithSize:14.0f];
      self.titleLabel.textColor = [UIColor whiteColor];
      self.titleLabel.highlightedTextColor = [UIColor colorWithRed:0.541 green:0.42 blue:0.616 alpha:1.0];
      self.titleLabel.textAlignment = NSTextAlignmentCenter;
      self.titleLabel.userInteractionEnabled = NO;
      self.titleLabel.backgroundColor = [UIColor clearColor];
      
      [self.contentView addSubview:self.titleLabel];
      
      UIView *backgroundView = [[UIView alloc] initWithFrame:self.bounds];
      
      [backgroundView setBackgroundColor:[UIColor whiteColor]];
      
      // Apply mask to bound on image
      backgroundView.layer.masksToBounds = YES;
      
      // Apply corner radius
      backgroundView.layer.cornerRadius = backgroundView.frame.size.width / 2;
      
      self.selectedBackgroundView = backgroundView;
      self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
  }
  return self;
}

- (void) setFont:(UIFont *)font
{
    _font = font;
    
    _titleLabel.font = [_font fontWithSize:14.0f];
}

- (void)layoutSubviews {
  [super layoutSubviews];
  
  self.contentView.frame = self.bounds;
  self.selectedBackgroundView.frame = self.bounds;
}

- (void)drawRect:(CGRect)rect {
  CGContextRef context = UIGraphicsGetCurrentContext();
  
  CGColorRef separatorColor = self.separatorColor.CGColor;
  
  CGFloat pixel = 1.f / [UIScreen mainScreen].scale;
  MNContextDrawLine(context,
                    CGPointMake(0.f, self.bounds.size.height),
                    CGPointMake(self.bounds.size.width, self.bounds.size.height),
                    separatorColor,
                    pixel);
}

@end
