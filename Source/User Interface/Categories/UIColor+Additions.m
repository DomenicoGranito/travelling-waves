//
//  UIColor+Additions.m
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/11/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import "UIColor+Additions.h"

@implementation UIColor (Additions)

+ (UIColor *)colorWithRGBHex:(UInt32)hex {
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)color {
    NSScanner *scanner = [NSScanner scannerWithString:color];
    unsigned hexNum = 0x0;
    if (![scanner scanHexInt:&hexNum]) return nil;
    return [self colorWithRGBHex:hexNum];
}

+ (UIColor*)colorFromUIColor:(UIColor *)color withBrightnessOffset:(CGFloat)offset {
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    brightness += offset;
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:alpha];
}

+ (UIColor*)desaturate:(UIColor *)color {
    CGFloat hue, saturation, brightness, alpha;
    [color getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    return [UIColor colorWithHue:hue saturation:0.0f brightness:brightness alpha:alpha];
}


#pragma mark - Custom Colors

+ (UIColor*)appBackgroundColor {
    return [UIColor colorWithWhite:0.12f alpha:1.0f];
}



+ (UIColor*)sliderOnColor {
    return [UIColor colorWithWhite:0.6f alpha:1.0f];
}

+ (UIColor*)sliderOffColor {
    return [UIColor colorWithWhite:0.25f alpha:1.0f];
}



+ (UIColor*)switchOnColor {
    return [UIColor colorWithWhite:0.35f alpha:1.0f];
}



+ (UIColor*)segmentedControlBackgroundColor {
    return [UIColor colorWithWhite:0.2f alpha:1.0f];
}

+ (UIColor*)segmentedControlTintColor {
    return [UIColor colorWithWhite:0.5f alpha:1.0f];
}



+ (UIColor*)soloEnableColor {
    return [UIColor colorWithRed:0.5f green:0.5f blue:0.1f alpha:0.3f];
}

+ (UIColor*)soloDisableColor {
    return [UIColor colorWithWhite:0.2f alpha:0.2f];
}

+ (UIColor*)sequencerEnableColor {
    return [UIColor colorWithRed:0.0 green:0.0 blue:0.2 alpha:0.4];
}


+ (UIColor*)valueTextDarkWhiteColor {
    return [UIColor colorWithWhite:0.4f alpha:1.0f];
}

+ (UIColor*)valueTextLightWhiteColor {
    return [UIColor colorWithWhite:0.8f alpha:1.0f];
}


#include "TWHeader.h"

+ (UIColor*)frequencyRatioControlBackgroundColor {
    return [UIColor colorWithWhite:0.16f alpha:1.0f];
}

+ (NSArray<UIColor*>*)timeRatioControlTintColors {
    NSMutableArray<UIColor*>* array = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumTimeRatioControls; i++) {
        if (i==0) {
            [array addObject:[UIColor segmentedControlTintColor]];
        } else {
            CGFloat hue = (float)i / kNumTimeRatioControls;
            UIColor* color = [UIColor colorWithHue:hue saturation:0.4f brightness:0.5f alpha:1.0f];
            [array addObject:color];
        }
    }
    return array;
}

+ (NSArray<UIColor*>*)timeRatioControlBackColors {
    NSMutableArray<UIColor*>* array = [[NSMutableArray alloc] init];
    for (int i=0; i < kNumTimeRatioControls; i++) {
        if (i==0) {
            [array addObject:[UIColor colorWithWhite:0.16f alpha:0.6f]];
        } else {
            CGFloat hue = (float)i / kNumTimeRatioControls;
            UIColor* color = [UIColor colorWithHue:hue saturation:0.5f brightness:0.16f alpha:0.6f];
            [array addObject:color];
        }
    }
    return array;
}

@end
