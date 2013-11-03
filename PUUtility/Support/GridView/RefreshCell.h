//
//  RefreshCell.h
//  Demo
//
//  Created by Devin Doty on 10/14/09October14.
//  Copyright 2009 enormego. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

typedef enum{
	RefreshPulling = 0,
	RefreshNormal,
	RefreshLoading,
} RefreshState;

typedef enum {
    RefreshTypeRefresh = 0,
    RefreshTypeLoadMore,
} RefreshType;

@protocol RefreshCellDelegate;
@interface RefreshCell : UIView {
	
	__weak id _delegate;
	RefreshState _state;
    RefreshType _type;
    
	UILabel *_lastUpdatedLabel;
	UILabel *_statusLabel;
	CALayer *_arrowImage;
	UIActivityIndicatorView *_activityView;
}

@property(nonatomic,weak) id <RefreshCellDelegate> delegate;
@property(nonatomic,assign) RefreshType type;
@property(nonatomic,assign) RefreshState state;

- (id)initWithFrame:(CGRect)frame
     arrowImageName:(NSString *)arrow
          textColor:(UIColor *)textColor
     indicatorStyle:(UIActivityIndicatorViewStyle)indicatorStyle
               type:(RefreshType)type;
- (id)initWithFrame:(CGRect)frame type:(RefreshType)type;

- (void)refreshLastUpdatedDate;
- (void)refreshScrollViewDidScroll:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView;
- (void)refreshScrollViewDidEndDragging:(UIScrollView *)scrollView animal:(BOOL)animal;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView succeed:(BOOL)succeed;
- (void)refreshScrollViewDataSourceDidFinishedLoading:(UIScrollView *)scrollView succeed:(BOOL)succeed animal:(BOOL)animal;
/*
 *  直接调用该类方法，将RefreshCell附加到UIScrollView上.
 */
+ (RefreshCell *)attachRefreshCellTo:(UIScrollView *)scrollview
                            delegate:(id<RefreshCellDelegate>)delegate
                      arrowImageName:(NSString *)arrow
                           textColor:(UIColor *)textColor
                      indicatorStyle:(UIActivityIndicatorViewStyle)indicatorStyle
                                type:(RefreshType)type;
/*
 *  RefreshCell 可以调用该方法触发加载数据.
 *  但是该cell的类型必须是RefreshTypeRefresh.
 */
- (void)reloadData;

/*
 * attach/detach需要成对出现。
 *
 * 如果不希望手动detach，请确保 !!!RefreshCell在ScrollView释放前进行释放!!!
 *
 */
- (void)attachToScrollview:(UIScrollView *)scrollview;
- (void)detach;
@end

@protocol RefreshCellDelegate
- (void)refreshCellDidTriggerLoading:(RefreshCell*)view;
- (BOOL)refreshCellDataSourceIsLoading:(RefreshCell*)view;

@optional
- (NSDate*)refreshCellDataSourceLastUpdated:(RefreshCell*)view;
@end
