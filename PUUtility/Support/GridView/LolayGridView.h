//
//  Created by Lolay, Inc.
//  Copyright 2011 Lolay, Inc. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "LolayGridViewCell.h"

@class LolayGridView;

@protocol LolayGridViewDataSource <NSObject>

- (NSInteger)numberOfRowsInGridView:(LolayGridView*)gridView;
- (NSInteger)numberOfColumnsInGridView:(LolayGridView*)gridView;
- (LolayGridViewCell*)gridView:(LolayGridView*)gridView cellForRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex;

@optional
- (void)gridView:(LolayGridView*)gridView didReuseCell:(LolayGridViewCell*)gridCell;
@end

typedef enum {
	LolayGridViewEdgeNone   = 0,
	LolayGridViewEdgeTop    = 1,
	LolayGridViewEdgeBottom = 1 << 1,
	LolayGridViewEdgeLeft   = 1 << 2,
	LolayGridViewEdgeRight  = 1 << 3
} LolayGridViewEdge;


@protocol LolayGridViewDelegate <UIScrollViewDelegate>

- (CGFloat)heightForGridViewRows:(LolayGridView*)gridView;
- (CGFloat)widthForGridViewColumns:(LolayGridView*)gridView;

@optional

- (CGFloat)gridView:(LolayGridView*)gridView insetForRow:(NSInteger)gridRowIndex;
- (CGFloat)gridView:(LolayGridView*)gridView insetForColumn:(NSInteger)gridColumnIndex;

- (void)gridView:(LolayGridView*)gridView didScrollToEdge:(LolayGridViewEdge)edge;

- (void)gridView:(LolayGridView*)gridView didSelectCellAtRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex;

- (void)gridView:(LolayGridView*)gridView willDeleteCellAtRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex;
- (void)gridView:(LolayGridView*)gridView didDeleteCellAtRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex;

- (UIView *)headerIndicatorViewForGridView:(LolayGridView *)gridView;
- (UIView *)footerIndicatorViewForGridView:(LolayGridView *)gridView;
- (UIView *)headerViewForGridView:(LolayGridView *)gridView;
- (UIView *)footerViewForGridView:(LolayGridView *)gridView;
@end



@interface LolayGridView : UIScrollView <LolayGridViewCellDelegate,UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet id<LolayGridViewDataSource> dataSource;
@property (nonatomic, weak) IBOutlet id<LolayGridViewDelegate>   dataDelegate;
@property (nonatomic, readonly) NSInteger        numberOfRows;
@property (nonatomic, readonly) NSInteger        numberOfColumns;
@property (nonatomic, setter = setEditing:) BOOL editing;
@property (nonatomic, setter = setHeaderIndicatorViewEnabled:) BOOL headerIndicatorViewEnabled;
@property (nonatomic, setter = setFooterIndicatorViewEnabled:) BOOL footerIndicatorViewEnabled;
@property (nonatomic, setter = setTopBounceEnabled:) BOOL topBounceEnabled;
@property (nonatomic, strong) NSMutableSet* inUseGridCells; // LolayGridViewCell*


- (LolayGridViewCell*)dequeueReusableGridCellWithIdentifier:(NSString*)identifier;

- (LolayGridViewCell*)cellForRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex;

- (void)scrollToRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex animated:(BOOL)animated;

- (void)deleteCellAtRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIdex animated:(BOOL)animated;

- (void)didSelectGridCell:(LolayGridViewCell*)gridCellView;
/*
 * 清空数据， 重新加载
 */
- (void)reloadData;
/*
 * 保留原有数据，根据数据源，重新计算gridView.contentSize
 */
- (void)resetGridView;
- (void)didReceiveMemoryWarning;

- (void)clearAllCells;

- (LolayGridViewCell*)cellForTag:(NSInteger)tag;

@end
