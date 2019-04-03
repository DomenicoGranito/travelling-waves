//
//  TWEnvelopeView.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/10/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TWEnvelopeViewDelegate<NSObject>
- (void)intervalUpdated:(id)sender;
@end


@interface TWEnvelopeView : UIView
@property (nonatomic, assign) int sourceIdx;
@property (nonatomic, weak) id<TWEnvelopeViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
