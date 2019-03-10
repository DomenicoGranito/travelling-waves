//
//  TWSeqNoteButton.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/6/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWSeqNoteButton.h"
#import <CoreGraphics/CoreGraphics.h>

@interface TWSeqNoteButton()
{
//    CGPathRef   _path;
}
@end


@implementation TWSeqNoteButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat xCenter = rect.size.width / 2.0f;
    CGFloat yCenter = rect.size.height / 2.0f;
    CGFloat angleWidth = (2.0f * M_PI) / (_interval + 1.0f);
    CGFloat startAngle = _idx * angleWidth;
    CGFloat endAngle = (_idx + 1.0f) * angleWidth;
    CGFloat radius = (_interval + 1) * _radius;
    
    CGPathAddArc(path, NULL,
                 xCenter, yCenter,
                 radius,
                 startAngle,
                 endAngle,
                 NO);
    
    if (_path) {
        CGPathRelease(_path);
    }
    _path = CGPathCreateCopy(path);
    
    CGContextAddPath(context, path);
    CGContextSetLineWidth(context, 2.0);
    
    CGFloat strokeColor = (float)_idx / (_interval + 1.0f);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:strokeColor alpha:1.0f].CGColor);
    CGContextStrokePath(context);
    
//    printf("Int: %d. Idx: %d. S: %f. E: %f. W: %f. R: %f. C: %f\n", _interval, _idx, startAngle, endAngle, angleWidth, radius, strokeColor);
//    CGFloat backgroundWhite = ((_idx % 2) == 0) ? 0.1f : 0.2f;
//    CGContextSetFillColorWithColor(context, [UIColor colorWithWhite:backgroundWhite alpha:1.0f].CGColor);
}


- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    if (CGPathContainsPoint(_path, nil, point, true)) {
        printf("Hit! x(%f), y(%f)\n", point.x, point.y);
        return self;
    } else {
        printf("Fail! x(%f), y(%f)\n", point.x, point.y);
        return nil;
    }
}


- (CGPathRef)drawDonutArcWithCenter:(CGPoint)centerPoint
                         withRadius:(CGFloat)radius
                          withWidth:(CGFloat)width
                     fromStartAngle:(CGFloat)startAngle
                         toEndAngle:(CGFloat)endAngle {
    
    CGMutablePathRef arc = CGPathCreateMutable();
    
    CGPathAddArc(arc, NULL,
                 centerPoint.x, centerPoint.y,
                 radius,
                 startAngle,
                 endAngle,
                 YES);
    
    CGPathRef strokedArc = CGPathCreateCopyByStrokingPath(arc,
                                                          NULL,
                                                          width,
                                                          kCGLineCapSquare,
                                                          kCGLineJoinMiter,
                                                          10); // 10 is default miter limit
    
    return strokedArc;
}
*/
@end
