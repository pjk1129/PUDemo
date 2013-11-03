//
//  Created by Lolay, Inc.
//  Copyright 2011 Lolay, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>

@class LolayGridViewCell;

@protocol LolayGridViewCellDelegate <NSObject>

- (void)didSelectGridCell:(LolayGridViewCell*)gridCellView;
- (void)deleteButtonSelectedForGridCell:(LolayGridViewCell*)gridCellView;
@end

@interface LolayGridViewCell : UIView

@property (nonatomic, readonly, strong) NSString *reuseIdentifier;
@property (nonatomic, assign) NSInteger           rowIndex;
@property (nonatomic, assign) NSInteger           columnIndex;
@property (nonatomic, assign) BOOL                highlighted;
@property (nonatomic, weak)  id<LolayGridViewCellDelegate> delegate;
@property (nonatomic, readonly, strong) NSString  *uuid;
@property (nonatomic) BOOL                        isHighlightable;
@property (nonatomic, strong) UIButton            *deleteButton;
@property (nonatomic,setter = setEditing:) BOOL    editing;

- (void)setupWithFrame:(CGRect)frame reuseIdentifier:(NSString*)reuseIdentifier;
- (id)initWithFrame:(CGRect)inRect reuseIdentifier:(NSString*)inReuseIdentifier;
- (id)initWithReuseIdentifier:(NSString*)inReuseIdentifier;

- (void)setRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex;

- (void)prepareForReuse;

@end