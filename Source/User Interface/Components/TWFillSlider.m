//
//  TWFillSlider.m
//  Travelling Waves
//
//  Created by Govinda Pingali on 2/17/16.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import "TWFillSlider.h"
#import <QuartzCore/QuartzCore.h>


#define BOUND(VALUE, UPPER, LOWER)	MIN(MAX(VALUE, LOWER), UPPER)

#define DISPLAY_VALUE_LABEL     0

@interface TWFillSlider()
{
    CALayer*            _onTrackLayer;
    CALayer*            _offTrackLayer;
    CAShapeLayer*       _borderLayer;
    CGPoint             _previousPoint;

#if DISPLAY_VALUE_LABEL
    UILabel*            _valueLabel;
#endif
}
@end


@implementation TWFillSlider

- (id)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}


- (void)initialize {
    
    _isHorizontal = NO;
    
    _maximumValue = 1.0f;
    _minimumValue = 0.0f;
    _value = 0.0f;
    
    _onTrackColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
    
    _onTrackLayer = [CALayer layer];
    [_onTrackLayer setBackgroundColor:_onTrackColor.CGColor];
    [self.layer addSublayer:_onTrackLayer];
    
    _offTrackLayer = [CALayer layer];
    [_offTrackLayer setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.5f].CGColor];
    [self.layer addSublayer:_offTrackLayer];
    
    _borderLayer = [CAShapeLayer layer];
    [_borderLayer setStrokeColor:[UIColor blackColor].CGColor];
    [_borderLayer setFillColor:[UIColor clearColor].CGColor];
    [_borderLayer setLineWidth:1.0f];
    [self.layer addSublayer:_borderLayer];
    
#if DISPLAY_VALUE_LABEL
    _valueLabel = [[UILabel alloc] init];
    [_valueLabel setBackgroundColor:[UIColor clearColor]];
    [_valueLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_valueLabel setTextColor:[UIColor colorWithWhite:0.3f alpha:0.8f]];
    [_valueLabel setTextAlignment:NSTextAlignmentCenter];
    [self addSubview:_valueLabel];
#endif
    
    [self setBackgroundColor:[UIColor clearColor]];
}



#pragma mark - Public Methods

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGMutablePathRef borderPath = CGPathCreateMutable();
    CGPathAddRect(borderPath, nil, CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height));
    [_borderLayer setPath:borderPath];
    CGPathRelease(borderPath);
    
#if DISPLAY_VALUE_LABEL
    [_valueLabel setFrame:CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height)];
#endif
    
    [self setLayerFrames];
}

- (void)setValue:(CGFloat)value {
    _value = value;
    _value = BOUND(_value, _maximumValue, _minimumValue);
    [self setLayerFrames];
    
#if DISPLAY_VALUE_LABEL
    [_valueLabel setText:[NSString stringWithFormat:@"%.2f", _value]];
#endif
}

- (void)setOnTrackColor:(UIColor *)onTrackColor {
    _onTrackColor = onTrackColor;
    [_onTrackLayer setBackgroundColor:_onTrackColor.CGColor];
    [_borderLayer setStrokeColor:_onTrackColor.CGColor];
}

//- (void)setCenterText:(NSString *)centerText {
//    _centerText = centerText;
//    [_valueLabel setText:centerText];
//}


#pragma mark - UIControl Methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _previousPoint = [touch locationInView:self];
    
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    CGPoint touchPoint = [touch locationInView:self];
    
    float delta = 0.0f;
    
    if (_isHorizontal) {
        delta = (touchPoint.x - _previousPoint.x) / self.bounds.size.width;
    } else {
        delta = (_previousPoint.y - touchPoint.y) / self.bounds.size.height;
    }
    
    float valueDelta = (_maximumValue - _minimumValue) * delta;
    
    _previousPoint = touchPoint;
    
    _value += valueDelta;
    _value = BOUND(_value, _maximumValue, _minimumValue);
    
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES] ;
    [self setLayerFrames];
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
#if DISPLAY_VALUE_LABEL
    [_valueLabel setText:[NSString stringWithFormat:@"%.2f", _value]];
#endif
    
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
}


#pragma mark - Private Methods

- (void)setLayerFrames {
    
    float scaledValue = (_value - _minimumValue) / (_maximumValue - _minimumValue);
    
    if (_isHorizontal) {
        CGFloat sliderX = self.bounds.size.width * scaledValue;
        
        [_onTrackLayer setFrame:CGRectMake(0.0f, 0.0f, sliderX, self.bounds.size.height)];
        [_offTrackLayer setFrame:CGRectMake(sliderX, 0.0f, self.bounds.size.width - sliderX, self.bounds.size.height)];
        
        [_onTrackLayer setNeedsDisplay];
        [_offTrackLayer setNeedsDisplay];
    }
    
    else {
        CGFloat sliderY = self.bounds.size.height * scaledValue;
        
        [_offTrackLayer setFrame:CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height - sliderY)];
        [_onTrackLayer setFrame:CGRectMake(0.0f, self.bounds.size.height - sliderY, self.bounds.size.width, sliderY)];
        
        [_onTrackLayer setNeedsDisplay];
        [_offTrackLayer setNeedsDisplay];
    }
}

@end
