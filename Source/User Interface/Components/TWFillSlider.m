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

@interface TWFillSlider()
{
    CALayer*            _onTrackLayer;
    CALayer*            _offTrackLayer;
    CAShapeLayer*       _borderLayer;
    
    CGPoint             _previousPoint;
    
    UILabel*            _valueLabel;
    
    CGRect              _sliderFrame;
    CGRect              _uiFrame;
    
    int                 _doubleTapCounter;
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
    _displayValueLabelInSlider = NO;
//    _doubleTapValueEditor = NO;
    
    _maximumValue = 1.0f;
    _minimumValue = 0.0f;
    _value = 0.0f;
    
    _UIFromTouchFrameInset = CGPointMake(0.0f, 0.0f);
    _borderThickness = 0.0f;
    _cornerRadius = 0.0f;
    
    _onTrackColor = [UIColor colorWithWhite:0.4f alpha:1.0f];
    _offTrackColor = [UIColor colorWithWhite:0.0f alpha:0.5f];
    _valueLabelColor = [UIColor colorWithWhite:1.0f alpha:1.0f];
    
    _offTrackLayer = [CALayer layer];
    [_offTrackLayer setBackgroundColor:_offTrackColor.CGColor];
    [self.layer addSublayer:_offTrackLayer];
    
    _onTrackLayer = [CALayer layer];
    [_onTrackLayer setBackgroundColor:_onTrackColor.CGColor];
    [self.layer addSublayer:_onTrackLayer];
    
    _borderLayer = [CAShapeLayer layer];
    [_borderLayer setStrokeColor:[UIColor blackColor].CGColor];
    [_borderLayer setFillColor:[UIColor clearColor].CGColor];
    [_borderLayer setLineCap:kCALineCapRound];
    [self.layer addSublayer:_borderLayer];
    
    _valueLabel = [[UILabel alloc] init];
    [_valueLabel setBackgroundColor:[UIColor clearColor]];
    [_valueLabel setUserInteractionEnabled:NO];
    [_valueLabel setFont:[UIFont systemFontOfSize:10.0f]];
    [_valueLabel setTextColor:_valueLabelColor];
    [_valueLabel setTextAlignment:NSTextAlignmentCenter];
    [_valueLabel setHidden:YES];
    [self addSubview:_valueLabel];
    
    _doubleTapCounter = 2;
    
    [self setClipsToBounds:YES];
    
    [self setBackgroundColor:[UIColor clearColor]];
}



#pragma mark - Public Methods

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    if (frame.size.width == 0.0f) {
        return;
    }
    
    _sliderFrame = CGRectMake(0.0f, 0.0f, frame.size.width, frame.size.height);
    
    [self updateFrame];
}

- (void)updateFrame {
    
    if (_sliderFrame.size.width == 0.0f) {
        return;
    }
    
    CGRect tempUIFrame = CGRectInset(_sliderFrame, _UIFromTouchFrameInset.x, _UIFromTouchFrameInset.y);
    
    _uiFrame = CGRectMake(tempUIFrame.origin.x + (_borderThickness / 2.0),
                                    tempUIFrame.origin.y + (_borderThickness / 2.0),
                                    tempUIFrame.size.width - _borderThickness,
                                    tempUIFrame.size.height - _borderThickness);

    
    [_borderLayer setLineWidth:_borderThickness];
    
    CGFloat cornerWidth, cornerHeight, cornerRadius;
    
    if (_isHorizontal) {
        cornerHeight = _cornerRadius * _uiFrame.size.height / 2.0f;
        cornerWidth = cornerHeight;
        cornerRadius = cornerHeight;
    } else {
        cornerWidth = _cornerRadius * _uiFrame.size.width / 2.0f;
        cornerHeight = cornerWidth;
        cornerRadius = cornerWidth;
    }
    
    CGMutablePathRef borderPath = CGPathCreateMutable();
    CGPathAddRoundedRect(borderPath, nil, _uiFrame, cornerWidth, cornerHeight);
    [_borderLayer setPath:borderPath];
    CGPathRelease(borderPath);
    
    
    
    
    [_valueLabel setFrame:_uiFrame];
    [_offTrackLayer setFrame:_uiFrame];
    
    [_onTrackLayer setCornerRadius:cornerRadius];
    [_offTrackLayer setCornerRadius:cornerRadius];
    
    
    [self setLayerFrames];
}

- (void)setBorderThickness:(CGFloat)borderThickness {
    _borderThickness = borderThickness;
    [self updateFrame];
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    [self updateFrame];
}

- (void)setUIFromTouchFrameInset:(CGPoint)UIFromTouchFrameInset {
    _UIFromTouchFrameInset = UIFromTouchFrameInset;
    [self updateFrame];
}






- (void)setOnTrackColor:(UIColor *)onTrackColor {
    _onTrackColor = onTrackColor;
    [_onTrackLayer setBackgroundColor:_onTrackColor.CGColor];
    [_borderLayer setStrokeColor:_onTrackColor.CGColor];
}

- (void)setOffTrackColor:(UIColor *)offTrackColor {
    _offTrackColor = offTrackColor;
    [_offTrackLayer setBackgroundColor:_offTrackColor.CGColor];
}

- (void)setValueLabelColor:(UIColor *)valueLabelColor {
    _valueLabelColor = valueLabelColor;
    [_valueLabel setTextColor:_valueLabelColor];
}

- (void)setDisplayValueLabelInSlider:(BOOL)displayValueLabelInSlider {
    _displayValueLabelInSlider = displayValueLabelInSlider;
    [_valueLabel setHidden:!_displayValueLabelInSlider];
}





- (void)setValue:(CGFloat)value {
    _value = value;
    _value = BOUND(_value, _maximumValue, _minimumValue);
    [self setLayerFrames];
    
    [_valueLabel setText:[NSString stringWithFormat:@"%.2f", _value]];
}






#pragma mark - UIControl Methods

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    
    _previousPoint = [touch locationInView:self];
    
    _doubleTapCounter--;
    [NSTimer scheduledTimerWithTimeInterval:0.2f repeats:NO block:^(NSTimer * _Nonnull timer) {
        self->_doubleTapCounter = 2;
    }];
    
    if (_doubleTapCounter == 0) {
        [self sendActionsForControlEvents:UIControlEventTouchDownRepeat];
        _doubleTapCounter = 2;
    }
    
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
    [CATransaction setDisableActions:YES];
    [self setLayerFrames];
    [CATransaction commit];
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    [_valueLabel setText:[NSString stringWithFormat:@"%.2f", _value]];
    
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
//    NSLog(@"End Tracking With Touch ");
}



#pragma mark - Private Methods

- (void)setLayerFrames {
    
    float scaledValue = (_value - _minimumValue) / (_maximumValue - _minimumValue);
    
    if (_isHorizontal) {
        CGFloat sliderX = _uiFrame.size.width * scaledValue;
        
        [_onTrackLayer setFrame:CGRectMake(_uiFrame.origin.x, _uiFrame.origin.y, sliderX, _uiFrame.size.height)];
//        [_offTrackLayer setFrame:CGRectMake(sliderX, _sliderUIFrame.origin.y, _sliderUIFrame.size.width - sliderX, _sliderUIFrame.size.height)];
        
        [_onTrackLayer setNeedsDisplay];
//        [_offTrackLayer setNeedsDisplay];
    }
    
    else {
        CGFloat sliderY = _uiFrame.size.height * scaledValue;
        
//        [_offTrackLayer setFrame:CGRectMake(_sliderUIFrame.origin.x, _sliderUIFrame.origin.y, _sliderUIFrame.size.width, _sliderUIFrame.size.height - sliderY)];
        [_onTrackLayer setFrame:CGRectMake(_uiFrame.origin.x, _uiFrame.size.height - sliderY, _uiFrame.size.width, sliderY)];
        
        [_onTrackLayer setNeedsDisplay];
//        [_offTrackLayer setNeedsDisplay];
    }
}

@end
