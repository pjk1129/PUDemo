//
//  Created by Lolay, Inc.
//  Copyright 2011 Lolay, Inc. All rights reserved.
//
#import "LolayGridView.h"
#import "LolayGridViewCell.h"

#define kHeaderViewBottomMargin   0    //headerView下边界值
#define kFooterViewTopMargin      0    //footerView上边界值


@interface LolayGridView ()

@property (nonatomic, strong) NSMutableSet* reusableGridCells; // LolayGridViewCell*
@property (nonatomic, strong) NSLock* reloadLock;
@property (nonatomic, strong) NSLock* resetLock;
@property (nonatomic, strong) NSLock* handleCellsLock;
@property (nonatomic) BOOL loadedOnce;
@property (nonatomic) NSInteger numberOfRows;
@property (nonatomic) NSInteger numberOfColumns;
@property (nonatomic) CGFloat heightForRows;
@property (nonatomic) CGFloat widthForColumns;
@property (nonatomic) BOOL deleting;

@property (nonatomic, strong) UIView             *headerIndicatorView;
@property (nonatomic, strong) UIView             *footerIndicatorView;
@property (nonatomic, strong) UIView             *headerView;
@property (nonatomic, strong) UIView             *footerView;

- (void) handleContentSize;
- (void)reuseCell:(LolayGridViewCell*)cell;

@end

@implementation LolayGridView

@synthesize inUseGridCells = inUseGridCells_;
@synthesize reusableGridCells = reusableGridCells_;
@synthesize reloadLock = reloadLock_;
@synthesize resetLock = resetLock_;
@synthesize handleCellsLock = handleCellsLock_;
@synthesize loadedOnce = loadedOnce_;
@synthesize numberOfRows = numberOfRows_;
@synthesize numberOfColumns = numberOfColumns_;
@synthesize heightForRows = heightForRows_;
@synthesize widthForColumns = widthForColumns_;
@synthesize dataSource = dataSource_;
@synthesize dataDelegate = dataDelegate_;
@synthesize editing = editing_;
@synthesize deleting = deleting_;
@synthesize headerIndicatorView = headerIndicatorView_;
@synthesize footerIndicatorView = footerIndicatorView_;
@synthesize headerView = headerView_;
@synthesize footerView = footerView_;
@synthesize headerIndicatorViewEnabled = headerIndicatorViewEnabled_;
@synthesize footerIndicatorViewEnabled = footerIndicatorViewEnabled_;
@synthesize topBounceEnabled = topBounceEnabled_;


#pragma mark - View Lifecycle
- (void)setup {
	self.inUseGridCells = [NSMutableSet set];
	self.reusableGridCells = [NSMutableSet set];
	self.reloadLock = [NSLock new];
	self.reloadLock.name = @"LolayGridView.reloadLock";
    self.resetLock = [NSLock new];
    self.resetLock.name = @"LolayGridView.resetLock";
	self.handleCellsLock = [NSLock new];
	self.handleCellsLock.name = @"LolayGridView.handleCellsLock";
	self.loadedOnce = NO;
	self.numberOfRows = 0;
	self.numberOfColumns = 0;
	self.heightForRows = 0.0;
	self.widthForColumns = 0.0;
    self.delegate = self;
    
    self.editing = NO;
    self.deleting = NO;
    
    self.headerIndicatorViewEnabled = YES;
    self.footerIndicatorViewEnabled = YES;
    
    self.topBounceEnabled = YES;
}

- (id)initWithCoder:(NSCoder*)decoder {
	self = [super initWithCoder:decoder];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (id)initWithFrame:(CGRect)inRect {
	self = [super initWithFrame:inRect];
	
	if (self) {
		[self setup];
	}
	
	return self;
}

- (void)dealloc {
	self.dataSource = nil;
	self.dataDelegate = nil;
    
	self.headerIndicatorView = nil;
    self.footerIndicatorView = nil;
    self.headerView = nil;
    self.footerView = nil;
    
}

- (void)didReceiveMemoryWarning {
	[self.reusableGridCells removeAllObjects];
}

#pragma mark - LolayGridViewDataSource Calls
- (NSInteger)dataSourceNumberOfRows {
	if ([self.dataSource respondsToSelector:@selector(numberOfRowsInGridView:)]) {
		return [self.dataSource numberOfRowsInGridView:self];
	} else {
		return 0;
	}
}

- (NSInteger)dataSourceNumberOfColumns {
	if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInGridView:)]) {
		return [self.dataSource numberOfColumnsInGridView:self];
	} else {
		return 0;
	}
}

- (LolayGridViewCell*)dataSourceCellForRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex {
	if ([self.dataSource respondsToSelector:@selector(gridView:cellForRow:atColumn:)]) {
		LolayGridViewCell* cell = [self.dataSource gridView:self cellForRow:gridRowIndex atColumn:gridColumnIndex];
		cell.delegate = self;
		[cell setRow:gridRowIndex atColumn:gridColumnIndex];
		return cell;
	} else {
		return nil;
	}
}

- (void)dataSourceDidReuseCell:(LolayGridViewCell*)gridCell {
	if ([self.dataSource respondsToSelector:@selector(gridView:didReuseCell:)]) {
		[self.dataSource gridView:self didReuseCell:gridCell];
	}
}

#pragma mark - LolayGridViewDelegate Calls
- (CGFloat)delegateHeightForRows {
	if ([self.dataDelegate respondsToSelector:@selector(heightForGridViewRows:)]) {
		return [self.dataDelegate heightForGridViewRows:self];
	} else {
		return 0.0;
	}
}

- (CGFloat)delegateWidthForColumns {
	if ([self.dataDelegate respondsToSelector:@selector(widthForGridViewColumns:)]) {
		return [self.dataDelegate widthForGridViewColumns:self];
	} else {
		return 0.0;
	}
}

- (CGFloat)delegateInsetForRow:(NSInteger)gridRowIndex {
	if ([self.dataDelegate respondsToSelector:@selector(gridView:insetForRow:)]) {
		return [self.dataDelegate gridView:self insetForRow:gridRowIndex];
	} else {
		return 0.0;
	}
}

- (CGFloat)delegateInsetForColumn:(NSInteger)gridColumnIndex {
	if ([self.dataDelegate respondsToSelector:@selector(gridView:insetForColumn:)]) {
		return [self.dataDelegate gridView:self insetForColumn:gridColumnIndex];
	} else {
		return 0.0;
	}
}

- (UIView *)delegateHeaderIndicatorView {
    if ([self.dataDelegate respondsToSelector:@selector(headerIndicatorViewForGridView:)]) {
        return [self.dataDelegate headerIndicatorViewForGridView:self];
    } else {
        return nil;
    }
}

- (UIView *)delegateFooterIndicatorView {
    if ([self.dataDelegate respondsToSelector:@selector(footerIndicatorViewForGridView:)]) {
        return [self.dataDelegate footerIndicatorViewForGridView:self];
    } else {
        return nil;
    }
}

- (UIView *)delegateHeaderView {
    if ([self.dataDelegate respondsToSelector:@selector(headerViewForGridView:)]) {
        return [self.dataDelegate headerViewForGridView:self];
    } else {
        return nil;
    }
}

- (UIView *)delegateFooterView {
    if ([self.dataDelegate respondsToSelector:@selector(footerViewForGridView:)]) {
        return [self.dataDelegate footerViewForGridView:self];
    } else {
        return nil;
    }
}

#pragma mark - LolayGridView Methods
/*
 Find the first reusable grid cell with the same reuse identifier.
 */
- (LolayGridViewCell*)dequeueReusableGridCellWithIdentifier:(NSString*)identifier {
	LolayGridViewCell* foundCell = nil;
	
	for (LolayGridViewCell* cell in self.reusableGridCells) {
		if ([cell.reuseIdentifier isEqualToString:identifier]) {
			foundCell = cell;
			[self.reusableGridCells removeObject:cell];
			break;
		}
	}
	
	return foundCell;
}

- (LolayGridViewCell*)cellForRow:(NSInteger) gridRowIndex atColumn:(NSInteger)gridColumnIndex {
	LolayGridViewCell* foundCell = nil;
	
	for (LolayGridViewCell* cell in self.inUseGridCells) {
		if (cell.rowIndex == gridRowIndex && cell.columnIndex == gridColumnIndex) {
			foundCell = cell;
			break;
		}
	}
	
	return foundCell;
}

- (void)scrollToRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIndex animated:(BOOL)animated {
    CGRect lastVisibleRect;
    lastVisibleRect.size.height = self.heightForRows;
    lastVisibleRect.origin.y = (self.heightForRows * gridRowIndex) + (self.headerView?(self.headerView.frame.size.height+kHeaderViewBottomMargin):0);
    lastVisibleRect.size.width = self.widthForColumns;
    lastVisibleRect.origin.x = (self.widthForColumns * gridColumnIndex);
    [self scrollRectToVisible:lastVisibleRect animated:animated];
}

- (void)deleteCellAtRow:(NSInteger)gridRowIndex atColumn:(NSInteger)gridColumnIdex animated:(BOOL)animated {
    LolayGridViewCell *deletedCell = [self cellForRow:gridRowIndex atColumn:gridColumnIdex];
    if (!deletedCell) {
        return;
    }
    
    self.deleting = YES;
    
    
    if ([self.dataDelegate respondsToSelector:@selector(gridView:willDeleteCellAtRow:atColumn:)]) {
        [self.dataDelegate gridView:self willDeleteCellAtRow:deletedCell.rowIndex atColumn:deletedCell.columnIndex];
    }
    
    for (LolayGridViewCell *cell in self.inUseGridCells) {
        NSInteger rowIndex = cell.rowIndex;
        NSInteger columnIndex = cell.columnIndex;
        
        if (rowIndex == deletedCell.rowIndex) {
            if (columnIndex > deletedCell.columnIndex) {
                cell.columnIndex--;
            }
        } else if (rowIndex > deletedCell.rowIndex) {
            if (columnIndex == 0) {
                cell.rowIndex--;
                cell.columnIndex = self.numberOfColumns-1;
            } else {
                cell.columnIndex--;
            }
        }
    }
    
    [deletedCell removeFromSuperview];
    [self.inUseGridCells removeObject:deletedCell];
    [self reuseCell:deletedCell];
    [self.reusableGridCells addObject:deletedCell];
    
    if ([self.dataDelegate respondsToSelector:@selector(gridView:didDeleteCellAtRow:atColumn:)]) {
        [self.dataDelegate gridView:self didDeleteCellAtRow:deletedCell.rowIndex atColumn:deletedCell.columnIndex];
    }
    
}

- (void)handleContentSize {

	NSInteger numRows = self.numberOfRows;
	NSInteger numColumns = self.numberOfColumns;
	
//	if (numRows == 0 || numColumns == 0) {
//		self.contentSize = CGSizeZero;
//		return;
//	}
	
	CGFloat maxRowInset = 0.0;
	CGFloat contentHeight = 0.0;
	CGFloat rowHeight = self.heightForRows;
	for (NSInteger i = 0; i < numRows; i++) {
		maxRowInset = MAX(maxRowInset, [self delegateInsetForRow:i]);
		contentHeight += rowHeight;
	}
	
	CGFloat maxColumnInset = 0.0;
	CGFloat contentWidth = 0.0;
	CGFloat columnWidth = self.widthForColumns;
	for (NSInteger i = 0; i < numColumns; i++) {
		maxColumnInset = MAX(maxColumnInset, [self delegateInsetForColumn:i]);
		contentWidth += columnWidth;
	}
	
	contentWidth += maxRowInset;
	contentHeight += maxColumnInset;
    
    if (self.headerIndicatorView) {
        self.headerIndicatorView.frame = CGRectMake((self.frame.size.width-self.headerIndicatorView.frame.size.width)/2, 
                                                    -self.headerIndicatorView.frame.size.height, 
                                                    self.headerIndicatorView.frame.size.width, 
                                                    self.headerIndicatorView.frame.size.height);
    }
    
    if (self.headerView) {
        self.headerView.frame = CGRectMake((self.frame.size.width-self.headerView.frame.size.width)/2, 
                                            0, 
                                            self.headerView.frame.size.width, 
                                            self.headerView.frame.size.height);
        contentHeight += self.headerView.frame.size.height + kHeaderViewBottomMargin;
    }
    
    if (self.footerView) {
        self.footerView.frame = CGRectMake((self.frame.size.width-self.footerView.frame.size.width)/2, 
                                           contentHeight+kFooterViewTopMargin, 
                                           self.footerView.frame.size.width, 
                                           self.footerView.frame.size.height);
        contentHeight += self.footerView.frame.size.height + kFooterViewTopMargin;
    }
    
	if (self.headerIndicatorView && contentHeight <=self.bounds.size.height) {
        contentHeight = self.bounds.size.height+1;
    }
	self.contentSize = CGSizeMake(contentWidth, contentHeight);
    self.contentInset = UIEdgeInsetsZero;
    
    if (self.footerIndicatorView) {
        self.footerIndicatorView.frame = CGRectMake((self.frame.size.width-self.footerIndicatorView.frame.size.width)/2, 
                                           contentHeight, 
                                           self.footerIndicatorView.frame.size.width, 
                                           self.footerIndicatorView.frame.size.height);
    }
    
}

- (CGRect)loadedContentRect {
	CGFloat OffSetX = self.contentOffset.x;
	CGFloat OffSetY = self.contentOffset.y;
	CGFloat width = self.bounds.size.width;
	CGFloat height = self.bounds.size.height;
	
	CGFloat deltaX = 0.2 * width;
	CGFloat deltaY = 0.2 * height;
	
	return CGRectMake(OffSetX - deltaX, OffSetY - deltaY, width + 2 * deltaX, height + 2 * deltaY);
}

- (void)reuseCell:(LolayGridViewCell*)cell {
	
	[cell removeFromSuperview];
	[cell prepareForReuse];
	[self dataSourceDidReuseCell:cell];
	
}


- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {

    if ([finished boolValue]) {
        
        self.numberOfRows = [self dataSourceNumberOfRows];
        self.numberOfColumns = [self dataSourceNumberOfColumns];
        self.heightForRows = [self delegateHeightForRows];
        self.widthForColumns = [self delegateWidthForColumns];
    
        self.deleting = NO;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        
        [self handleContentSize];
        
        [UIView commitAnimations];
    }
}

- (void)handleCells {
	
	NSInteger rows = self.numberOfRows;
	NSInteger columns = self.numberOfColumns;
	
	if (rows == 0 || columns == 0) {
		return;
	}
	
	if ([self.handleCellsLock tryLock]) {
		CGRect loadedRect = [self loadedContentRect];
		
		// Reclaim some cells
		NSMutableSet* reuseSet = [NSMutableSet setWithCapacity:self.inUseGridCells.count / 2];
		for (LolayGridViewCell* cell in self.inUseGridCells) {
			if (! CGRectIntersectsRect(loadedRect, cell.frame)) {
				[self reuseCell:cell];
				[reuseSet addObject:cell];
			}
		}
		[self.inUseGridCells minusSet:reuseSet];
		[self.reusableGridCells unionSet:reuseSet];
		
		// Load some missing cells
		CGFloat rowHeight = self.heightForRows;
		CGFloat columnWidth = self.widthForColumns;
		
		
		NSInteger minColumn = ceil(loadedRect.origin.x / columnWidth) - 1;
		NSInteger maxColumn = ceil((loadedRect.origin.x + loadedRect.size.width) / columnWidth) - 1;
		NSInteger minRow = ceil((loadedRect.origin.y 
                                 - (self.headerView?(self.headerView.frame.size.height+kHeaderViewBottomMargin):0)) / rowHeight) - 1;
		NSInteger maxRow = ceil((loadedRect.origin.y 
                                 - (self.headerView?(self.headerView.frame.size.height+kHeaderViewBottomMargin):0) 
                                 + loadedRect.size.height) / rowHeight) - 1;
		
		if (minRow < 0) {
			minRow = 0;
		}
		if (minRow >= rows) {
			minRow = rows - 1;
		}
		if (maxRow < 0) {
			maxRow = 0;
		}
		if (maxRow >= rows) {
			maxRow = rows - 1;
		}
		if (minColumn < 0) {
			minColumn = 0;
		}
		if (minColumn >= columns) {
			minColumn = columns - 1;
		}
		if (maxColumn < 0) {
			maxColumn = 0;
		}
		if (maxColumn >= columns) {
			maxColumn = columns - 1;
		}
		
		
		for (NSInteger row = minRow; row <= maxRow; row++) {
			CGFloat insetForRow = [self delegateInsetForRow:row];
			NSInteger columnOffset = round(insetForRow / columnWidth);
			
			for (NSInteger column = minColumn; column <= maxColumn; column++) {
				CGFloat insetForColumn = [self delegateInsetForColumn:row];
				NSInteger rowOffset = round(insetForColumn / rowHeight);
				
				NSInteger offsetRow = row - rowOffset;
				if (offsetRow < 0) {
					offsetRow = 0;
				}
				if (offsetRow >= rows) {
					offsetRow = rows - 1;
				}
				
				NSInteger offsetColumn = column - columnOffset;
				if (offsetColumn < 0) {
					offsetColumn = 0;
				}
				if (offsetColumn >= columns) {
					offsetColumn = columns - 1;
				}
                
				if (![self cellForRow:offsetRow atColumn:offsetColumn]) {
					LolayGridViewCell* cell = [self dataSourceCellForRow:offsetRow atColumn:offsetColumn];
					if (cell) {
                        CGFloat y = insetForColumn + offsetRow * rowHeight + (rowHeight-cell.frame.size.height)/2;
                        if (self.headerView) {
                            y += (self.headerView.frame.size.height + kHeaderViewBottomMargin);
                        }
                        
						cell.frame = CGRectMake(roundf(insetForRow + offsetColumn * columnWidth + (columnWidth-cell.frame.size.width)/2), 
                                                roundf(y), 
                                                cell.frame.size.width, cell.frame.size.height);
                        cell.editing = self.editing;
                        
						[self addSubview:cell];
						[self.inUseGridCells addObject:cell];
					}
				}
			}
		}
        
        if (self.deleting) {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
            
            for (NSInteger row = minRow; row <= maxRow; row++) {
                CGFloat insetForRow = [self delegateInsetForRow:row];
                NSInteger columnOffset = round(insetForRow / columnWidth);
                
                for (NSInteger column = minColumn; column <= maxColumn; column++) {
                    CGFloat insetForColumn = [self delegateInsetForColumn:row];
                    NSInteger rowOffset = round(insetForColumn / rowHeight);
                    
                    NSInteger offsetRow = row - rowOffset;
                    if (offsetRow < 0) {
                        offsetRow = 0;
                    }
                    if (offsetRow >= rows) {
                        offsetRow = rows - 1;
                    }
                    
                    NSInteger offsetColumn = column - columnOffset;
                    if (offsetColumn < 0) {
                        offsetColumn = 0;
                    }
                    if (offsetColumn >= columns) {
                        offsetColumn = columns - 1;
                    }
                    
                    LolayGridViewCell* cell = [self cellForRow:offsetRow atColumn:offsetColumn];
                    
                    if (cell) {
                        CGFloat y = insetForColumn + offsetRow * rowHeight + (rowHeight-cell.frame.size.height)/2;
                        if (self.headerView) {
                            y += (self.headerView.frame.size.height + kHeaderViewBottomMargin);
                        }
                        
                        cell.frame = CGRectMake(roundf(insetForRow + offsetColumn * columnWidth + (columnWidth-cell.frame.size.width)/2),
                                                roundf(y), 
                                                cell.frame.size.width, cell.frame.size.height);
                    }
                }
            }
            
            [UIView commitAnimations];
        }
        
		[self.handleCellsLock unlock];
	}
}

- (void)reloadData {
	self.loadedOnce = YES;
	[self.reloadLock lock];
	
	self.numberOfRows = [self dataSourceNumberOfRows];
	self.numberOfColumns = [self dataSourceNumberOfColumns];
	self.heightForRows = [self delegateHeightForRows];
	self.widthForColumns = [self delegateWidthForColumns];
    
    self.headerIndicatorView = [self delegateHeaderIndicatorView];
    self.footerIndicatorView = [self delegateFooterIndicatorView];
    self.headerView = [self delegateHeaderView];
    self.footerView = [self delegateFooterView];
    
    if([self.inUseGridCells count] > 0){
        for(LolayGridViewCell* cell in self.inUseGridCells){
            [self reuseCell:cell];
        }
        [self.reusableGridCells unionSet:self.inUseGridCells];
        self.inUseGridCells = [NSMutableSet set];
    }
	
	[self handleContentSize];
	[self handleCells];
	
	[self.reloadLock unlock];
}

- (void)resetGridView {
    
    [self.resetLock lock];
    
	self.numberOfRows = [self dataSourceNumberOfRows];
	self.numberOfColumns = [self dataSourceNumberOfColumns];
	self.heightForRows = [self delegateHeightForRows];
	self.widthForColumns = [self delegateWidthForColumns];
	
	[self handleContentSize];
	[self handleCells];
	
	[self.resetLock unlock];
}

- (void)checkScrolledToEdge {
	if ([self.dataDelegate respondsToSelector:@selector(gridView:didScrollToEdge:)]) {
		LolayGridViewEdge edges = LolayGridViewEdgeNone;
		
		if (self.contentOffset.x <= 0) {
			edges |= LolayGridViewEdgeLeft;
		} else if (self.contentOffset.x >= self.contentSize.width - self.frame.size.width) {
			edges |= LolayGridViewEdgeRight;
		}
		if (self.contentOffset.y <= 0) {
			edges |= LolayGridViewEdgeTop;
		} else if (self.contentOffset.y >= self.contentSize.height - self.frame.size.height) {
			edges |= LolayGridViewEdgeBottom;
		}
		
        if (edges != LolayGridViewEdgeNone) {
            [self.dataDelegate gridView:self didScrollToEdge:edges];
        }
	}
}

- (void)clearAllCells {
    self.numberOfRows = 0;
	self.numberOfColumns = 0;
    self.inUseGridCells = nil;
    self.reusableGridCells = nil;
    self.inUseGridCells = [NSMutableSet set];
	self.reusableGridCells = [NSMutableSet set];
    self.loadedOnce = NO;
    for (UIView* view in self.subviews) {
        [view removeFromSuperview];
    }
}


- (LolayGridViewCell*)cellForTag:(NSInteger)tag {
    LolayGridViewCell* foundCell = nil;
    for (LolayGridViewCell* cell in self.inUseGridCells) {
        if (cell.tag == tag) {
            foundCell = cell;
            break;
        }
    }
    
    for (LolayGridViewCell* cell in self.reusableGridCells) {
        if (cell.tag == tag) {
            foundCell = cell;
            break;
        }
    }
    
    return foundCell;
}

#pragma mark - LolayGridViewCellDelegate Methods
- (void)didSelectGridCell:(LolayGridViewCell*)gridCellView {
    gridCellView.highlighted = NO;
	if ([self.dataDelegate respondsToSelector:@selector(gridView:didSelectCellAtRow:atColumn:)]) {
		[self.dataDelegate gridView:self didSelectCellAtRow:gridCellView.rowIndex atColumn:gridCellView.columnIndex];
	}
}

- (void)deleteButtonSelectedForGridCell:(LolayGridViewCell *)gridCellView {
    if (self.deleting) {
        return;
    }
    [self deleteCellAtRow:gridCellView.rowIndex atColumn:gridCellView.columnIndex animated:YES];
}

#pragma mark - UIView Methods

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if (! self.loadedOnce) {
		[self reloadData];
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];

    [self handleCells];
}

#pragma mark - setter Methods
- (void)setEditing:(BOOL)editing {
    if (editing_ != editing) {
        editing_ = editing;
        
        for (LolayGridViewCell* cell in self.inUseGridCells) {
            cell.editing = editing_;
        }
    }
}

- (void)setHeaderIndicatorViewEnabled:(BOOL)enabled {
    if (self.headerIndicatorView) {
        self.headerIndicatorView.hidden = !enabled;
    }
    
    headerIndicatorViewEnabled_ = enabled;
}

- (void)setFooterIndicatorViewEnabled:(BOOL)enabled {
    if (self.footerIndicatorView) {
        self.footerIndicatorView.hidden = !enabled;
    }
    
    footerIndicatorViewEnabled_ = enabled;
}

//added by zhanghua, 2011.12.01, IKIOSTBMTV-134:gridView上边界固定
- (void)setTopBounceEnabled:(BOOL)topBounceEnabled {
    topBounceEnabled_ = topBounceEnabled;
    self.bounces = topBounceEnabled;

}
//end IKIOSTBMTV-134

- (void)setHeaderIndicatorView:(UIView *)headerIndicatorView {
    if (headerIndicatorView_ != headerIndicatorView) {
        [headerIndicatorView_ removeFromSuperview];
        
        headerIndicatorView_ = headerIndicatorView;
        if (headerIndicatorView_) {
            [self addSubview:headerIndicatorView_];
        }
    }
}

- (void)setFooterIndicatorView:(UIView *)footerIndicatorView {
    if (footerIndicatorView_ != footerIndicatorView) {
        [footerIndicatorView_ removeFromSuperview];
        
        footerIndicatorView_ = footerIndicatorView;
        if (footerIndicatorView_) {
            [self addSubview:footerIndicatorView];
        }
    }
}

- (void)setHeaderView:(UIView *)headerView {
    if (headerView_ != headerView) {
        [headerView_ removeFromSuperview];
        
        headerView_ = headerView;
        if (headerView_) {
            [self addSubview:headerView_];
        }
    }
    else
    {//Modify by zt 2013-8-8
        if(headerView)
        {
            [self addSubview:headerView];
        }
    }
}

- (void)setFooterView:(UIView *)footerView {
    if (footerView_ != footerView) {
        [footerView_ removeFromSuperview];
        
        footerView_ = footerView;
        if (footerView_) {
            [self addSubview:footerView_];
        }
    }
    else
    {//Modify by zt 2013-8-8
        if(footerView)
        {
            [self addSubview:footerView];
        }
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    [self checkScrolledToEdge];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //added by zhanghua, 2011.12.01, IKIOSTBMTV-134:gridView上边界固定
    if (!topBounceEnabled_) {
        if (scrollView.contentOffset.y <= 0) {
            scrollView.bounces = NO;
            
        } else {
            scrollView.bounces = YES;
        }
    }
    //end IKIOSTBMTV-134

}

@end