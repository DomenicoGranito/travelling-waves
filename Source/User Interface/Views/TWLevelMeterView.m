//
//  TWLevelMeterView.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/26/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWLevelMeterView.h"

static const float kRectHeightProportion = 0.7;

@implementation TWLevelMeterView

- (id)init {
    if (self = [super init]) {
        _level = 0.0f;
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    [super drawRect:rect];
    
    float width = rect.size.width * _level;
    float height = rect.size.height * kRectHeightProportion;
    float yPos = rect.size.height * (1.0 - kRectHeightProportion) / 2.0f;
    CGRect rectangle = CGRectMake(0.0, yPos, width, height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBFillColor(context, 0.4, 0.3, 0.3, 0.5);
    CGContextFillRect(context, rectangle);
}


- (void)setLevel:(float)level {
    _level = level;
    [self setNeedsDisplay];
}
@end
