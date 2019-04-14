//
//  UIColor+Additions.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 4/11/19.
//  Copyright © 2019 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Additions)

/** Creates and returns a color object using the specified hexadecimal value.
 @param hex hexadecimal int value.
 @return the UIColor object. */
+ (UIColor*)colorWithRGBHex:(UInt32)hex;

/** Creates and returns a color object using the specified hexadecimal value.
 @param color hexadecimal value as a string.
 @return the UIColor object. */
+ (UIColor*)colorWithHexString:(NSString *)color;

/** Returns a UIColor that is darker or lighter than the specified UIColor.
 @param offset of brightness (positive values will be lighter, negative will be darker).
 @return UIColor. */
+ (UIColor*)colorFromUIColor:(UIColor*)color withBrightnessOffset:(CGFloat)offset;

/** Returns a desaturated UIColor, ie. same hue and brightness but zero saturation.
 @return UIColor */
+ (UIColor*)desaturate:(UIColor*)color;



//** App Custom Colors **/

+ (UIColor*)appBackgroundColor;

+ (UIColor*)sliderOnColor;
+ (UIColor*)sliderOffColor;

+ (UIColor*)switchOnColor;

+ (UIColor*)segmentedControlBackgroundColor;
+ (UIColor*)segmentedControlTintColor;


+ (UIColor*)soloEnableColor;
+ (UIColor*)soloDisableColor;

+ (UIColor*)sequencerEnableColor;


+ (UIColor*)valueTextDarkWhiteColor;
+ (UIColor*)valueTextLightWhiteColor;


+ (UIColor*)frequencyRatioControlBackgroundColor;
+ (NSArray<UIColor*>*)timeRatioControlTintColors;
+ (NSArray<UIColor*>*)timeRatioControlBackColors;

@end

NS_ASSUME_NONNULL_END
