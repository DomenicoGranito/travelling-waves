//
//  TWSeqNoteButton.h
//  Travelling Waves
//
//  Created by Govinda Ram Pingali on 10/6/18.
//  Copyright © 2018 Govinda Ram Pingali. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWSeqNoteButton : UIButton

@property (nonatomic, assign) int sourceIdx;
@property (nonatomic, assign) int beat;

@property (nonatomic, assign) float radius;

@end

NS_ASSUME_NONNULL_END
