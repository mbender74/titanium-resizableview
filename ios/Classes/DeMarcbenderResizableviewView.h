#import "TiUIView.h"
#import "DeMarcbenderResizableviewViewProxy.h"

FOUNDATION_EXPORT double DeMarcbenderResizableviewViewVersionNumber;

FOUNDATION_EXPORT const unsigned char DeMarcbenderResizableviewViewVersionString[];


typedef struct DeMarcbenderResizableviewViewAnchorPoint {
    CGFloat adjustsX;
    CGFloat adjustsY;
    CGFloat adjustsH;
    CGFloat adjustsW;
} DeMarcbenderResizableviewViewAnchorPoint;


@interface SPGripViewBorderView : UIView {
    UIColor *handleViewColor;
    CGFloat kDeMarcbenderResizableviewViewInteractiveBorderSize;
}

@end

@class DeMarcbenderResizableviewView;

//@protocol DeMarcbenderResizableviewViewDelegate;
@protocol DeMarcbenderResizableviewViewDelegate <NSObject>
@optional

// Called when the resizable view receives touchesBegan: and activates the editing handles.
- (void)userResizableViewDidBeginEditing:(DeMarcbenderResizableviewView *)userResizableView;

// Called when the resizable view receives touchesEnded: or touchesCancelled:
- (void)userResizableViewDidEndEditing:(DeMarcbenderResizableviewView *)userResizableView;

@end


@interface DeMarcbenderResizableviewView: TiUIView <UIGestureRecognizerDelegate, DeMarcbenderResizableviewViewDelegate> {
    bool endEditing;
    CGPoint touchStart;
    CGFloat handleSize;
    TiViewProxy *contentViewProxy;
    // Used to determine which components of the bounds we'll be modifying, based upon where the user's touch started.
    DeMarcbenderResizableviewViewAnchorPoint anchorPoint;
    CGFloat kDeMarcbenderResizableviewViewDefaultMinWidth;
    CGFloat kDeMarcbenderResizableviewViewDefaultMinHeight;
    CGRect appFrame;
    DeMarcbenderResizableviewView *currentlyEditingView;
    DeMarcbenderResizableviewView *lastEditedView;
    float boundsWidth;
    float boundsHeight;
}

@property (nonatomic, weak) id <DeMarcbenderResizableviewViewDelegate> delegate;

// Will be retained as a subview.
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic) SPGripViewBorderView *borderView;

// Default is 48.0 for each.
@property (nonatomic) CGFloat minWidth;
@property (nonatomic) CGFloat minHeight;

// Defaults to YES. Disables the user from dragging the view outside the parent view's bounds.
@property (nonatomic) BOOL preventsPositionOutsideSuperview;

- (void)hideEditingHandles;
- (void)showEditingHandles;

@end

