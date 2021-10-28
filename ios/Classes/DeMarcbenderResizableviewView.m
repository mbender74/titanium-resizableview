#import "DeMarcbenderResizableviewView.h"
#import <TitaniumKit/TiBase.h>
#import <TitaniumKit/TiProxy.h>
#import <TitaniumKit/TiUtils.h>
#import <TitaniumKit/TiViewProxy.h>
#import "TiPoint.h"

/* Let's inset everything that's drawn (the handles and the content view)
 so that users can trigger a resize from a few pixels outside of
 what they actually see as the bounding box. */
#define kDeMarcbenderResizableviewViewGlobalInset 5.0

CGFloat kDeMarcbenderResizableviewViewDefaultMinWidth = 48.0;
CGFloat kDeMarcbenderResizableviewViewDefaultMinHeight = 48.0;
CGFloat kDeMarcbenderResizableviewViewInteractiveBorderSize = 10.0;

static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewNoResizeAnchorPoint = { 0.0, 0.0, 0.0, 0.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewUpperLeftAnchorPoint = { 1.0, 1.0, -1.0, 1.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewMiddleLeftAnchorPoint = { 1.0, 0.0, 0.0, 1.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewLowerLeftAnchorPoint = { 1.0, 0.0, 1.0, 1.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewUpperMiddleAnchorPoint = { 0.0, 1.0, -1.0, 0.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewUpperRightAnchorPoint = { 0.0, 1.0, -1.0, -1.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewMiddleRightAnchorPoint = { 0.0, 0.0, 0.0, -1.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewLowerRightAnchorPoint = { 0.0, 0.0, 1.0, -1.0 };
static DeMarcbenderResizableviewViewAnchorPoint DeMarcbenderResizableviewViewLowerMiddleAnchorPoint = { 0.0, 0.0, 1.0, 0.0 };


@implementation SPGripViewBorderView

- (id)initWithFrame:(CGRect)frame withHandleColor:(UIColor*)color {
    handleViewColor = color;

    if ((self = [super initWithFrame:frame])) {
        // Clear background to ensure the content view shows through.
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // (1) Draw the bounding box.
    CGContextSetLineWidth(context, 1.0);
    CGContextSetStrokeColorWithColor(context, handleViewColor.CGColor);
    CGContextAddRect(context, CGRectInset(self.bounds, kDeMarcbenderResizableviewViewInteractiveBorderSize/2, kDeMarcbenderResizableviewViewInteractiveBorderSize/2));
    CGContextStrokePath(context);
    
    // (2) Calculate the bounding boxes for each of the anchor points.
    CGRect upperLeft = CGRectMake(0.0, 0.0, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect upperRight = CGRectMake(self.bounds.size.width - kDeMarcbenderResizableviewViewInteractiveBorderSize, 0.0, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect lowerRight = CGRectMake(self.bounds.size.width - kDeMarcbenderResizableviewViewInteractiveBorderSize, self.bounds.size.height - kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect lowerLeft = CGRectMake(0.0, self.bounds.size.height - kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect upperMiddle = CGRectMake((self.bounds.size.width - kDeMarcbenderResizableviewViewInteractiveBorderSize)/2, 0.0, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect lowerMiddle = CGRectMake((self.bounds.size.width - kDeMarcbenderResizableviewViewInteractiveBorderSize)/2, self.bounds.size.height - kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect middleLeft = CGRectMake(0.0, (self.bounds.size.height - kDeMarcbenderResizableviewViewInteractiveBorderSize)/2, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    CGRect middleRight = CGRectMake(self.bounds.size.width - kDeMarcbenderResizableviewViewInteractiveBorderSize, (self.bounds.size.height - kDeMarcbenderResizableviewViewInteractiveBorderSize)/2, kDeMarcbenderResizableviewViewInteractiveBorderSize, kDeMarcbenderResizableviewViewInteractiveBorderSize);
    
    CGFloat red, green, blue, alpha;
    
    [handleViewColor getRed: &red green: &green blue: &blue alpha: &alpha];
    
    // (3) Create the gradient to paint the anchor points.
    CGFloat colors [] = {
        red - 0.4, green - 0.8, blue, 1.0,
        red, green, blue, 1.0
    };
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colors, NULL, 2);
    CGColorSpaceRelease(baseSpace);
    baseSpace = NULL;
    
    // (4) Set up the stroke for drawing the border of each of the anchor points.
    CGContextSetLineWidth(context, 1);
    CGContextSetShadow(context, CGSizeMake(0.5, 0.5), 1);
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    
    // (5) Fill each anchor point using the gradient, then stroke the border.
    CGRect allPoints[8] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight };
    for (NSInteger i = 0; i < 8; i++) {
        CGRect currPoint = allPoints[i];
        CGContextSaveGState(context);
        CGContextAddEllipseInRect(context, currPoint);
        CGContextClip(context);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMinY(currPoint));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(currPoint), CGRectGetMaxY(currPoint));
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        CGContextStrokeEllipseInRect(context, CGRectInset(currPoint, 1, 1));
    }
    CGGradientRelease(gradient);
    gradient = NULL;
    CGContextRestoreGState(context);
}

@end

@implementation DeMarcbenderResizableviewView

@synthesize borderView, contentView, minWidth, minHeight, preventsPositionOutsideSuperview, delegate;


- (void)initializeState
{
    
    CGRect gripFrame = self.frame;

    [self setupDefaultAttributes];
    
    self.delegate = self;
    [self showEditingHandles];
    currentlyEditingView = self;
    lastEditedView = self;
    
    TiViewProxy *parentProxy = [(TiViewProxy *)self.proxy parent];

    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideEditingHandlesView:)];
    [gestureRecognizer setDelegate:self];

    [parentProxy.view addGestureRecognizer:gestureRecognizer];

    [super initializeState];
}

//- (void)setHandleSize_:(id)value
//{
//    kDeMarcbenderResizableviewViewInteractiveBorderSize = [TiUtils floatValue:value];
//}
//
//- (void)setMinHeight_:(id)value
//{
//    self.minHeight = [TiUtils floatValue:value];
//}
//
//- (void)setMinWidth_:(id)value
//{
//    self.minWidth = [TiUtils floatValue:value];
//}
//
//
//- (void)setHandleColor_:(id)value
//{
//    handleColor = [[TiUtils colorValue:value] _color];
//    if (borderView != nil){
//        borderView.handleColor = handleColor;
//    }
//}


- (void)setContentView_:(id)value
{
  ENSURE_SINGLE_ARG(value, TiViewProxy);
  contentViewProxy = (TiViewProxy *)value;
  self.contentView = contentViewProxy.view;
  [contentViewProxy windowDidOpen];

    NSArray *children = [contentViewProxy children];
    for (TiViewProxy *proxy in children) {
        [proxy windowWillOpen];
        [proxy reposition];
        [proxy layoutChildrenIfNeeded];
    }
}




- (void)hideEditingHandlesView:(UITapGestureRecognizer *)recognizer
{
    [self hideEditingHandles];
}



- (void)setupDefaultAttributes {
    UIColor *handleColor;

    if ([self.proxy valueForKey:@"handleColor"]){
        handleColor = [[TiUtils colorValue:[self.proxy valueForKey:@"handleColor"]] _color];
      //  NSLog(@"[ERROR] handleColor ");
    }
    else {
      //  NSLog(@"[ERROR] NO handleColor ");

        handleColor = [UIColor blueColor];
    }
    if ([self.proxy valueForKey:@"handleSize"]){
      //  NSLog(@"[ERROR] handleSize ");

        kDeMarcbenderResizableviewViewInteractiveBorderSize = [TiUtils floatValue:[self.proxy valueForKey:@"handleSize"]];
    }
   
    
    self.borderView = [[SPGripViewBorderView alloc] initWithFrame:CGRectInset(self.bounds, kDeMarcbenderResizableviewViewGlobalInset, kDeMarcbenderResizableviewViewGlobalInset) withHandleColor:handleColor];
    [self.borderView setHidden:YES];
    [self addSubview:self.borderView];
   // [borderView bringSubviewToFront:contentView];
    
    if ([self.proxy valueForUndefinedKey:@"minimumHeight"]){

        self.minHeight = [TiUtils floatValue:[self.proxy valueForKey:@"minimumHeight"]] + kDeMarcbenderResizableviewViewInteractiveBorderSize;
       // NSLog(@"[ERROR] minimumHeight %f ",self.minHeight);

    }
    else {
        self.minHeight = kDeMarcbenderResizableviewViewDefaultMinHeight + kDeMarcbenderResizableviewViewInteractiveBorderSize;
       // NSLog(@"[ERROR] NO minimumHeight %f ",self.minHeight);

    }
    
    if ([self.proxy valueForUndefinedKey:@"minimumWidth"]){
        self.minWidth = [TiUtils floatValue:[self.proxy valueForKey:@"minimumWidth"]] + kDeMarcbenderResizableviewViewInteractiveBorderSize;
    }
    else {
        self.minWidth = kDeMarcbenderResizableviewViewDefaultMinWidth + kDeMarcbenderResizableviewViewInteractiveBorderSize;
    }
    
    self.preventsPositionOutsideSuperview = YES;
}

- (void)setContentView:(UIView *)newContentView {
    //LayoutConstraint *oldLayout = [contentViewProxy layoutProperties];
    [contentView removeFromSuperview];
    contentView = newContentView;
       
    contentView.frame = CGRectInset(self.bounds, kDeMarcbenderResizableviewViewGlobalInset + kDeMarcbenderResizableviewViewInteractiveBorderSize/2, kDeMarcbenderResizableviewViewGlobalInset + kDeMarcbenderResizableviewViewInteractiveBorderSize/2);
    [self addSubview:contentView];
    // Ensure the border view is always on top by removing it and adding it to the end of the subview list.
    [self.borderView removeFromSuperview];
    [self addSubview:self.borderView];
    [self bringSubviewToFront:self.borderView];
    [self.borderView setHidden:YES];
    if ([self.proxy valueForUndefinedKey:@"handleEnabled"]){
        if ([TiUtils boolValue:[self.proxy valueForKey:@"handleEnabled"]]==YES){
            [self.borderView setHidden:NO];
            lastEditedView = self;
            currentlyEditingView = self;
            [self.proxy replaceValue:lastEditedView forKey:@"lastResizableView" notification:YES];
        }
    }
}

- (void)setFrame:(CGRect)newFrame {
    [super setFrame:newFrame];
    contentView.frame = CGRectInset(self.bounds, kDeMarcbenderResizableviewViewGlobalInset + kDeMarcbenderResizableviewViewInteractiveBorderSize/2, kDeMarcbenderResizableviewViewGlobalInset + kDeMarcbenderResizableviewViewInteractiveBorderSize/2);
    self.borderView.frame = CGRectInset(self.bounds, kDeMarcbenderResizableviewViewGlobalInset, kDeMarcbenderResizableviewViewGlobalInset);
    [self.borderView setNeedsDisplay];
    [self bringSubviewToFront:self.borderView];
}


- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    NSArray *children = [contentViewProxy children];
    for (TiViewProxy *proxy in children) {
        [proxy reposition];
        [proxy layoutChildrenIfNeeded];
    }
}



static CGFloat SPDistanceBetweenTwoPoints(CGPoint point1, CGPoint point2) {
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx*dx + dy*dy);
};

typedef struct CGPointDeMarcbenderResizableviewViewAnchorPointPair {
    CGPoint point;
    DeMarcbenderResizableviewViewAnchorPoint anchorPoint;
} CGPointDeMarcbenderResizableviewViewAnchorPointPair;

- (DeMarcbenderResizableviewViewAnchorPoint)anchorPointForTouchLocation:(CGPoint)touchPoint {
    // (1) Calculate the positions of each of the anchor points.
    CGPointDeMarcbenderResizableviewViewAnchorPointPair upperLeft = { CGPointMake(0.0, 0.0), DeMarcbenderResizableviewViewUpperLeftAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair upperMiddle = { CGPointMake(self.bounds.size.width/2, 0.0), DeMarcbenderResizableviewViewUpperMiddleAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair upperRight = { CGPointMake(self.bounds.size.width, 0.0), DeMarcbenderResizableviewViewUpperRightAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair middleRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height/2), DeMarcbenderResizableviewViewMiddleRightAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair lowerRight = { CGPointMake(self.bounds.size.width, self.bounds.size.height), DeMarcbenderResizableviewViewLowerRightAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair lowerMiddle = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height), DeMarcbenderResizableviewViewLowerMiddleAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair lowerLeft = { CGPointMake(0, self.bounds.size.height), DeMarcbenderResizableviewViewLowerLeftAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair middleLeft = { CGPointMake(0, self.bounds.size.height/2), DeMarcbenderResizableviewViewMiddleLeftAnchorPoint };
    CGPointDeMarcbenderResizableviewViewAnchorPointPair centerPoint = { CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2), DeMarcbenderResizableviewViewNoResizeAnchorPoint };
    
    // (2) Iterate over each of the anchor points and find the one closest to the user's touch.
    CGPointDeMarcbenderResizableviewViewAnchorPointPair allPoints[9] = { upperLeft, upperRight, lowerRight, lowerLeft, upperMiddle, lowerMiddle, middleLeft, middleRight, centerPoint };
    CGFloat smallestDistance = MAXFLOAT; CGPointDeMarcbenderResizableviewViewAnchorPointPair closestPoint = centerPoint;
    for (NSInteger i = 0; i < 9; i++) {
        CGFloat distance = SPDistanceBetweenTwoPoints(touchPoint, allPoints[i].point);
        if (distance < smallestDistance) {
            closestPoint = allPoints[i];
            smallestDistance = distance;
        }
    }
    return closestPoint.anchorPoint;
}

- (BOOL)isResizing {
    return (anchorPoint.adjustsH || anchorPoint.adjustsW || anchorPoint.adjustsX || anchorPoint.adjustsY);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've begun our editing session.
        
    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidBeginEditing:)]) {
        [self.delegate userResizableViewDidBeginEditing:self];
    }

    [self.borderView setHidden:NO];
    UITouch *touch = [touches anyObject];
    anchorPoint = [self anchorPointForTouchLocation:[touch locationInView:self]];
    
    // When resizing, all calculations are done in the superview's coordinate space.
    touchStart = [touch locationInView:self.superview];
    if (![self isResizing]) {
        // When translating, all calculations are done in the view's coordinate space.
        touchStart = [touch locationInView:self];
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.

    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    // Notify the delegate we've ended our editing session.

    if (self.delegate && [self.delegate respondsToSelector:@selector(userResizableViewDidEndEditing:)]) {
        [self.delegate userResizableViewDidEndEditing:self];
    }
}

- (void)showEditingHandles {
    [self.borderView setHidden:NO];
}

- (void)hideEditingHandles {
    [self.borderView setHidden:YES];
}

- (void)resizeUsingTouchLocation:(CGPoint)touchPoint {
    // (1) Update the touch point if we're outside the superview.
    if (self.preventsPositionOutsideSuperview) {
        CGFloat border = kDeMarcbenderResizableviewViewGlobalInset + kDeMarcbenderResizableviewViewInteractiveBorderSize/2;
        if (touchPoint.x < border) {
            touchPoint.x = border;
        }
        if (touchPoint.x > self.superview.bounds.size.width - border) {
            touchPoint.x = self.superview.bounds.size.width - border;
        }
        if (touchPoint.y < border) {
            touchPoint.y = border;
        }
        if (touchPoint.y > self.superview.bounds.size.height - border) {
            touchPoint.y = self.superview.bounds.size.height - border;
        }
    }
    
    // (2) Calculate the deltas using the current anchor point.
    CGFloat deltaW = anchorPoint.adjustsW * (touchStart.x - touchPoint.x);
    CGFloat deltaX = anchorPoint.adjustsX * (-1.0 * deltaW);
    CGFloat deltaH = anchorPoint.adjustsH * (touchPoint.y - touchStart.y);
    CGFloat deltaY = anchorPoint.adjustsY * (-1.0 * deltaH);
    
    // (3) Calculate the new frame.
    CGFloat newX = self.frame.origin.x + deltaX;
    CGFloat newY = self.frame.origin.y + deltaY;
    CGFloat newWidth = self.frame.size.width + deltaW;
    CGFloat newHeight = self.frame.size.height + deltaH;
    
    // (4) If the new frame is too small, cancel the changes.
    if (newWidth < self.minWidth) {
        newWidth = self.frame.size.width;
        newX = self.frame.origin.x;
    }
    if (newHeight < self.minHeight) {
        newHeight = self.frame.size.height;
        newY = self.frame.origin.y;
    }
    
    // (5) Ensure the resize won't cause the view to move offscreen.
    if (self.preventsPositionOutsideSuperview) {
        if (newX < self.superview.bounds.origin.x) {
            // Calculate how much to grow the width by such that the new X coordintae will align with the superview.
            deltaW = self.frame.origin.x - self.superview.bounds.origin.x;
            newWidth = self.frame.size.width + deltaW;
            newX = self.superview.bounds.origin.x;
        }
        if (newX + newWidth > self.superview.bounds.origin.x + self.superview.bounds.size.width) {
            newWidth = self.superview.bounds.size.width - newX;
        }
        if (newY < self.superview.bounds.origin.y) {
            // Calculate how much to grow the height by such that the new Y coordintae will align with the superview.
            deltaH = self.frame.origin.y - self.superview.bounds.origin.y;
            newHeight = self.frame.size.height + deltaH;
            newY = self.superview.bounds.origin.y;
        }
        if (newY + newHeight > self.superview.bounds.origin.y + self.superview.bounds.size.height) {
            newHeight = self.superview.bounds.size.height - newY;
        }
    }
    
    self.frame = CGRectMake(newX, newY, newWidth, newHeight);
    touchStart = touchPoint;
}

- (void)translateUsingTouchLocation:(CGPoint)touchPoint {
    CGPoint newCenter = CGPointMake(self.center.x + touchPoint.x - touchStart.x, self.center.y + touchPoint.y - touchStart.y);
    if (self.preventsPositionOutsideSuperview) {
        // Ensure the translation won't cause the view to move offscreen.
        CGFloat midPointX = CGRectGetMidX(self.bounds);
        if (newCenter.x > self.superview.bounds.size.width - midPointX) {
            newCenter.x = self.superview.bounds.size.width - midPointX;
        }
        if (newCenter.x < midPointX) {
            newCenter.x = midPointX;
        }
        CGFloat midPointY = CGRectGetMidY(self.bounds);
        if (newCenter.y > self.superview.bounds.size.height - midPointY) {
            newCenter.y = self.superview.bounds.size.height - midPointY;
        }
        if (newCenter.y < midPointY) {
            newCenter.y = midPointY;
        }
    }

    self.center = newCenter;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if ([self isResizing]) {
        [self resizeUsingTouchLocation:[[touches anyObject] locationInView:self.superview]];
    } else {
        [self translateUsingTouchLocation:[[touches anyObject] locationInView:self]];
    }
}


- (void)userResizableViewDidBeginEditing:(DeMarcbenderResizableviewView *)userResizableView {
    if ([self.proxy valueForUndefinedKey:@"lastResizableView"]){
       // NSLog(@"[ERROR] userResizableViewDidBeginEditing ");

        lastEditedView = [self.proxy valueForKey:@"lastResizableView"];
        [lastEditedView hideEditingHandles];
    }
   // NSLog(@"[ERROR] after userResizableViewDidBeginEditing ");

    [self.proxy replaceValue:userResizableView forKey:@"currentResizableView" notification:YES];
    currentlyEditingView = userResizableView;
}

- (void)userResizableViewDidEndEditing:(DeMarcbenderResizableviewView *)userResizableView {
    lastEditedView = userResizableView;
   // NSLog(@"[ERROR]  userResizableViewDidEndEditing ");

    [self.proxy replaceValue:lastEditedView forKey:@"lastResizableView" notification:YES];
}
//
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self hitTest:[touch locationInView:self] withEvent:nil]) {
        if ([self.proxy _hasListeners:@"selected"]) {
            [self.proxy fireEvent:@"selected" withObject:nil];
        }
        [self.proxy replaceValue:self forKey:@"currentResizableView" notification:YES];

        TiViewProxy *parentProxy = [(TiViewProxy *)self.proxy parent];
        [parentProxy.view bringSubviewToFront:self];

        return NO;
    }
    if ([self.proxy _hasListeners:@"unselected"]) {
        [self.proxy fireEvent:@"unselected" withObject:nil];
    }
    if ([self.proxy valueForUndefinedKey:@"lastResizableView"]){
       // NSLog(@"[ERROR] unselected ");

        lastEditedView = [self.proxy valueForKey:@"lastResizableView"];
        [lastEditedView hideEditingHandles];
    }

    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
@end
