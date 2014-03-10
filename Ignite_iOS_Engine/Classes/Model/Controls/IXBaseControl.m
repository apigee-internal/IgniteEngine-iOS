//
//  IXBaseControl.m
//  Ignite iOS Engine (IX)
//
//  Created by Robert Walsh on 10/3/13.
//  Copyright (c) 2013 Apigee, Inc. All rights reserved.
//

#import "IXBaseControl.h"

#import "IXAppManager.h"
#import "IXPropertyContainer.h"
#import "ColorUtils.h"
#import "IXLayoutEngine.h"
#import "IXControlLayoutInfo.h"
#import "IXLogger.h"

#import "UIImage+ResizeMagick.h"


//
// IXBaseControl Properties :
//      Note: See IXControlLayoutInfo.h for layout properties.
//
static NSString* const kIXAlpha = @"alpha";
static NSString* const kIXBorderWidth = @"border_width";
static NSString* const kIXBorderColor = @"border_color";
static NSString* const kIXBorderRadius = @"border_radius";
static NSString* const kIXBackgroundColor = @"background.color";
static NSString* const kIXBackgroundImage = @"background.image";
static NSString* const kIXBackgroundImageScale = @"background.image.scale";
static NSString* const kIXEnabled = @"enabled";
static NSString* const kIXEnableTap = @"enable_tap";
static NSString* const kIXEnableSwipe = @"enable_swipe";
static NSString* const kIXEnablePinch = @"enable_pinch";
static NSString* const kIXEnablePan = @"enable_pan";
static NSString* const kIXEnableShadow = @"enable_shadow";
static NSString* const kIXShadowBlur = @"shadow_blur";
static NSString* const kIXShadowAlpha = @"shadow_alpha";
static NSString* const kIXShadowColor = @"shadow_color";
static NSString* const kIXShadowOffsetRight = @"shadow_offset_right";
static NSString* const kIXShadowOffsetDown = @"shadow_offset_down";
static NSString* const kIXVisible = @"visible";

//
// IXBaseControl gesture events
//
static NSString* const kIXTouch = @"touch";
static NSString* const kIXTouchUp = @"touch_up";
static NSString* const kIXTouchCancelled = @"touch_cancelled";
static NSString* const kIXTap = @"tap";
static NSString* const kIXTapCount = @"tap_count";
static NSString* const kIXSwipe = @"swipe";
static NSString* const kIXSwipeDirection = @"swipe_direction";
static NSString* const kIXDown = @"down";
static NSString* const kIXUp = @"up";
static NSString* const kIXRight = @"right";
static NSString* const kIXLeft = @"left";
static NSString* const kIXPan = @"pan";
static NSString* const kIXPanReset = @"pan.reset";

//
// IXBaseControl pinch events & handlers
//
static NSString* const kIXPinchIn = @"pinch.in";
static NSString* const kIXPinchOut = @"pinch.out";
static NSString* const kIXPinchZoom = @"pinch.zoom"; //both (default), horizontal, or vertical
static NSString* const kIXPinchReset = @"pinch.reset";
static NSString* const kIXPinchMax = @"pinch.max";
static NSString* const kIXPinchMin = @"pinch.min";
static NSString* const kIXPinchElastic = @"pinch.elastic";
static NSString* const kIXPinchHorizontal = @"horizontal";
static NSString* const kIXPinchVertical = @"vertical";
static NSString* const kIXPinchBoth = @"both";

@interface IXBaseControl ()

@end

@implementation IXBaseControl

-(id)init
{
    self = [super init];
    if( self )
    {
        _contentView = nil;
        _layoutInfo = nil;
        _notifyParentOfLayoutUpdates = YES;
        
        [self buildView];
    }
    return self;
}

-(instancetype)copyWithZone:(NSZone *)zone
{
    IXBaseControl* baseControl = [super copyWithZone:zone];
    return baseControl;
}

-(void)setPropertyContainer:(IXPropertyContainer *)propertyContainer
{
    [super setPropertyContainer:propertyContainer];
    [[self layoutInfo] setPropertyContainer:propertyContainer];
}

//
// If you override and need to add subviews to the control you need to call super first then add the subviews to the controls contentView.
// If you don't need a view for the control simply override this and do not call super.
//
-(void)buildView
{
    _contentView = [[IXControlContentView alloc] initWithFrame:CGRectZero viewTouchDelegate:self];
    [_contentView setClipsToBounds:NO];
}

-(BOOL)isContentViewVisible
{
    BOOL isVisible = NO;
    if( [self contentView] )
    {
        if( ![[self contentView] isHidden] && [[self contentView] alpha] > 0.0f )
        {
            isVisible = YES;
        }
    }
    return isVisible;
}

-(CGSize)preferredSizeForSuggestedSize:(CGSize)size
{
    return CGSizeZero;
}

-(void)layoutControlContentsInRect:(CGRect)rect
{
    
}

-(void)layoutControl
{
    if( [self parentObject] && [self shouldNotifyParentOfLayoutUpdates] )
    {
        [((IXBaseControl*)[self parentObject]) layoutControl];
    }
    else
    {
        CGRect internalLayoutRect = [IXLayoutEngine getInternalLayoutRectForControl:self forOuterLayoutRect:[[self contentView] bounds]];
        [self layoutControlContentsInRect:internalLayoutRect];
    }
}

-(void)applySettings
{
    [super applySettings];
    
    if( [self contentView] != nil )
    {
        if( _layoutInfo == nil )
        {
            _layoutInfo = [[IXControlLayoutInfo alloc] initWithPropertyContainer:[self propertyContainer]];
        }
        else
        {
            [_layoutInfo refreshLayoutInfo];
        }
        
        [self applyContentViewSettings];
        [self applyGestureRecognizerSettings];
    }
    
    for( IXBaseControl* baseControl in [self childObjects] )
    {
        [baseControl applySettings];
    }
}

-(void)applyContentViewSettings
{
    NSString* backgroundImage = [self.propertyContainer getStringPropertyValue:kIXBackgroundImage defaultValue:nil];
    if (backgroundImage)
    {
        NSString* backgroundImageScale = [self.propertyContainer getStringPropertyValue:kIXBackgroundImageScale defaultValue:@"cover"];
        [self.propertyContainer getImageProperty:kIXBackgroundImage
                                     successBlock:^(UIImage *image) {
                                         
                                         NSString* backgroundImageResizeMask;
                                         CGSize size = self.contentView.bounds.size;
                                         if ([backgroundImageScale isEqualToString:@"cover"])
                                         {
                                             backgroundImageResizeMask = [NSString stringWithFormat:@"%.0fx%.0f^", size.width, size.height];
                                             image = [image resizedImageByMagick:backgroundImageResizeMask];
                                         }
                                         else if ([backgroundImageScale isEqualToString:@"stretch"])
                                         {
                                             backgroundImageResizeMask = [NSString stringWithFormat:@"%.0fx%.0f!", size.width, size.height];
                                             image = [image resizedImageByMagick:backgroundImageResizeMask];
                                         }
                                         else if ([backgroundImageScale isEqualToString:@"contain"])
                                         {
                                             backgroundImageResizeMask = [NSString stringWithFormat:@"%.0fx%.0f", size.width, size.height];
                                             image = [image resizedImageByMagick:backgroundImageResizeMask];
                                             
                                             UIGraphicsBeginImageContext(size);
                                             [[UIColor clearColor] setFill];
                                             [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
                                             CGRect rect = CGRectMake(((size.width - image.size.width) / 2), ((size.height - image.size.height) / 2), image.size.width, image.size.height);
                                             [image drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
                                             image = UIGraphicsGetImageFromCurrentImageContext();
                                             UIGraphicsEndImageContext();
                                         }
                                         else if ([backgroundImageScale isEqualToString:@"tile"])
                                         {
                                             backgroundImageResizeMask = [NSString stringWithFormat:@"%.0fx%.0f", size.width, size.height];
                                             image = [image resizedImageByMagick:backgroundImageResizeMask];
                                         }
                                         
                                         self.contentView.backgroundColor = [UIColor colorWithPatternImage:image];
                                         
                                     } failBlock:^(NSError *error) {
                                         DDLogDebug(@"Background image failed to load at %@", kIXBackgroundImage);
                                     }];
    }
    else
    {
        [[self contentView] setBackgroundColor:[[self propertyContainer] getColorPropertyValue:kIXBackgroundColor defaultValue:[UIColor clearColor]]];
    }
    
    [[self contentView] setEnabled:[[self propertyContainer] getBoolPropertyValue:kIXEnabled defaultValue:YES]];
    [[self contentView] setHidden:[[self layoutInfo] isHidden]];
    [[self contentView] setAlpha:[[self propertyContainer] getFloatPropertyValue:kIXAlpha defaultValue:1.0f]];
    
    float borderWidth = [[self propertyContainer] getFloatPropertyValue:kIXBorderWidth defaultValue:0.0f];
    UIColor* borderColor = [[self propertyContainer] getColorPropertyValue:kIXBorderColor defaultValue:[UIColor blackColor]];
    if( [[IXAppManager sharedAppManager] isLayoutDebuggingEnabled] )
    {
        if( borderWidth == 0.0f )
        {
            borderWidth = 1.0f;
            CGFloat hue = ( arc4random() % 256 / 256.0f );
            CGFloat saturation = ( arc4random() % 128 / 256.0f ) + 0.5f;
            CGFloat brightness = ( arc4random() % 128 / 256.0f ) + 0.5f;
            borderColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0f];
        }
    }
    [[[self contentView] layer] setBorderWidth:borderWidth];
    [[[self contentView] layer] setBorderColor:borderColor.CGColor];
    [[[self contentView] layer] setCornerRadius:[[self propertyContainer] getFloatPropertyValue:kIXBorderRadius defaultValue:0.0f]];
    
    BOOL enableShadow = [[self propertyContainer] getBoolPropertyValue:kIXEnableShadow defaultValue:NO];
    if( enableShadow )
    {
        [[[self contentView] layer] setShouldRasterize:YES];
        [[[self contentView] layer] setRasterizationScale:[[UIScreen mainScreen] scale]];
        [[[self contentView] layer] setShadowRadius:[[self propertyContainer] getFloatPropertyValue:kIXShadowBlur defaultValue:1.0f]];
        [[[self contentView] layer] setShadowOpacity:[[self propertyContainer] getFloatPropertyValue:kIXShadowAlpha defaultValue:1.0f]];
        
        UIColor* shadowColor = [[self propertyContainer] getColorPropertyValue:kIXShadowColor defaultValue:[UIColor blackColor]];
        [[[self contentView] layer] setShadowColor:shadowColor.CGColor];
        
        float shadowOffsetRight = [[self propertyContainer] getFloatPropertyValue:kIXShadowOffsetRight defaultValue:2.0f];
        float shadowOffsetDown = [[self propertyContainer] getFloatPropertyValue:kIXShadowOffsetDown defaultValue:2.0f];
        [[[self contentView] layer] setShadowOffset:CGSizeMake(shadowOffsetRight, shadowOffsetDown)];
    }
    else
    {
        [[[self contentView] layer] setShouldRasterize:NO];
        [[[self contentView] layer] setShadowOpacity:0.0f];
    }
}

-(void)applyGestureRecognizerSettings
{
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnableTap defaultValue:NO] )
    {
        [[self contentView] beginListeningForTapGestures];
    }
    else
    {
        [[self contentView] stopListeningForTapGestures];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnableSwipe defaultValue:NO] )
    {
        [[self contentView] beginListeningForSwipeGestures];
    }
    else
    {
        [[self contentView] stopListeningForSwipeGestures];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnablePinch defaultValue:NO] )
    {
        [[self contentView] beginListeningForPinchGestures];
    }
    else
    {
        [[self contentView] stopListeningForPinchGestures];
    }
    
    if( [[self propertyContainer] getBoolPropertyValue:kIXEnablePan defaultValue:NO] )
    {
        [[self contentView] beginListeningForPanGestures];
    }
    else
    {
        [[self contentView] stopListeningForPanGestures];
    }
}

-(void)controlViewTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [[event allTouches] anyObject];
    IXBaseControl* touchedControl = [self getTouchedControl:touch];
    
    [touchedControl processBeginTouch:YES];
}

-(void)controlViewTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

-(void)controlViewTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self processCancelTouch:YES];
}

-(void)controlViewTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //    UITouch* touch = [touches anyObject];
    //    BOOL shouldFireTouchActions = ( [touch view] == [self contentView] && [touch tapCount] >= 1 );
    
    [self processEndTouch:YES];
}

-(void)controlViewTapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSString* tapCount = [NSString stringWithFormat:@"%lu",(unsigned long)[tapGestureRecognizer numberOfTapsRequired]];
    [[self actionContainer] executeActionsForEventNamed:kIXTap propertyWithName:kIXTapCount mustHaveValue:tapCount];
}

-(void)controlViewSwipeGestureRecognized:(UISwipeGestureRecognizer *)swipeGestureRecognizer
{
    NSString* swipeDirection = nil;
    switch ([swipeGestureRecognizer direction]) {
        case UISwipeGestureRecognizerDirectionDown:{
            swipeDirection = kIXDown;
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft:{
            swipeDirection = kIXLeft;
            break;
        }
        case UISwipeGestureRecognizerDirectionRight:{
            swipeDirection = kIXRight;
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:{
            swipeDirection = kIXUp;
            break;
        }
        default:{
            break;
        }
    }
    if( swipeDirection )
    {
        [[self actionContainer] executeActionsForEventNamed:kIXSwipe propertyWithName:kIXSwipeDirection mustHaveValue:swipeDirection];
    }
}

-(void)controlViewPinchGestureRecognized:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    NSString* zoomDirection = [[self propertyContainer] getStringPropertyValue:kIXPinchZoom defaultValue:nil];
    
    if( zoomDirection != nil )
    {
        
        BOOL resetSize = [self.propertyContainer getBoolPropertyValue:kIXPinchReset defaultValue:YES];
        const CGFloat kMinScale = [self.propertyContainer getFloatPropertyValue:kIXPinchMin defaultValue:1.0];
        const CGFloat kMaxScale = [self.propertyContainer getFloatPropertyValue:kIXPinchMax defaultValue:2.0];
        const CGFloat kElastic = [self.propertyContainer getFloatPropertyValue:kIXPinchElastic defaultValue:0.5];
        
        CGFloat previousScale = 1;
        
        if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan) {
            // Reset the last scale, necessary if there are multiple objects with different scales
            previousScale = pinchGestureRecognizer.scale;
        }
        
        if(pinchGestureRecognizer.state == UIGestureRecognizerStateBegan ||
           pinchGestureRecognizer.state == UIGestureRecognizerStateChanged)
        {
            CGAffineTransform transform;
            CGFloat currentScale = [[pinchGestureRecognizer.view.layer valueForKeyPath:@"transform.scale"] floatValue];
            CGFloat newScale = 1 - (previousScale - pinchGestureRecognizer.scale);
            newScale = MIN(newScale, (kMaxScale + kElastic) / currentScale);
            newScale = MAX(newScale, (kMinScale - kElastic) / currentScale);
            if ([zoomDirection isEqualToString:kIXPinchVertical])
            {
                transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, 1, newScale);
            }
            else if ([zoomDirection isEqualToString:kIXPinchHorizontal])
            {
                transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, newScale, 1);
            }
            else if ([zoomDirection isEqualToString:kIXPinchBoth])
            {
                transform = CGAffineTransformScale(pinchGestureRecognizer.view.transform, newScale, newScale);
            }
            pinchGestureRecognizer.view.transform = transform;
            previousScale = pinchGestureRecognizer.scale;
            pinchGestureRecognizer.scale = 1;
        }
        
        if(pinchGestureRecognizer.state == UIGestureRecognizerStateEnded ||
           pinchGestureRecognizer.state == UIGestureRecognizerStateCancelled)
        {
            if (resetSize)
            {
                CGAffineTransform resetTransform;
                CGFloat currentScale = [[pinchGestureRecognizer.view.layer valueForKeyPath:@"transform.scale"] floatValue];
                CGFloat resetWidth = currentScale;
                CGFloat resetHeight = currentScale;
                if (currentScale < kMinScale)
                {
                    resetWidth = kMinScale;
                    resetHeight = kMinScale;
                    
                }
                else if (currentScale > kMaxScale)
                {
                    resetWidth = kMaxScale;
                    resetHeight = kMaxScale;
                }
                
                if ([zoomDirection isEqualToString:kIXPinchVertical])
                    resetHeight = 1;
                else if ([zoomDirection isEqualToString:kIXPinchHorizontal])
                    resetWidth = 1;
                
                resetTransform = CGAffineTransformMakeScale(resetHeight, resetWidth);
                
                if (currentScale > kMaxScale || currentScale < kMinScale)
                {
                    [UIView animateWithDuration:0.2
                                     animations:^{
                                         pinchGestureRecognizer.view.transform = resetTransform;
                                     }];
                     
                }
            }
            

        }
    }
    if(pinchGestureRecognizer.state == UIGestureRecognizerStateEnded)
    {
        //Pinch out
        if (pinchGestureRecognizer.scale > 1)
        {
            [[self actionContainer] executeActionsForEventNamed:kIXPinchOut];
        }
        //Pinch in
        else if (pinchGestureRecognizer.scale < 1)
        {
            [[self actionContainer] executeActionsForEventNamed:kIXPinchIn];
        }
    }
}

-(void)controlViewPanGestureRecognized:(UIPanGestureRecognizer *)panGestureRecognizer
{
    BOOL resetPosition = [self.propertyContainer getBoolPropertyValue:kIXPanReset defaultValue:YES];
    static CGPoint originalCenter;
    UIView *draggedView = panGestureRecognizer.view;
    CGPoint offset = [panGestureRecognizer translationInView:draggedView.superview];
    CGPoint center = draggedView.center;
    
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        originalCenter = draggedView.center;
    }
    
    draggedView.center = CGPointMake(center.x + offset.x, center.y + offset.y);
    // Reset translation to zero so on the next `panWasRecognized:` message, the
    // translation will just be the additional movement of the touch since now.
    
    if ((panGestureRecognizer.state == UIGestureRecognizerStateEnded ||
         panGestureRecognizer.state == UIGestureRecognizerStateCancelled)
        && resetPosition)
    {
        [UIView animateWithDuration:0.2
                         animations:^{
                             draggedView.center = originalCenter;
                         }];
    }
    
    [panGestureRecognizer setTranslation:CGPointZero inView:draggedView.superview];
}

-(IXBaseControl*)getTouchedControl:(UITouch*)touch
{
    if( touch == nil )
        return nil;
    
    IXBaseControl* returnControl = self;
    for( IXBaseControl* baseControl in [self childObjects] )
    {
        IXControlContentView* baseControlView = [baseControl contentView];
        if( baseControlView )
        {
            if( ![[baseControl contentView] isHidden] && [baseControlView alpha] > 0.0f )
            {
                if( CGRectContainsPoint([baseControlView bounds], [touch locationInView:baseControlView]) )
                {
                    returnControl = [baseControl getTouchedControl:touch];
                }
            }
        }
    }
    return returnControl;
}

-(void)processBeginTouch:(BOOL)fireTouchActions
{
    if( fireTouchActions )
    {
        if( [[self actionContainer] hasActionsWithEventNamePrefix:kIXTouch] )
        {
            [[self actionContainer] executeActionsForEventNamed:kIXTouch];
        }
        else if( [[self parentObject] isKindOfClass:[IXBaseControl class]] )
        {
            IXBaseControl* parentControl = (IXBaseControl*)[self parentObject];
            if( [parentControl contentView] )
            {
                [parentControl processBeginTouch:fireTouchActions];
            }
        }
    }
}

-(void)processCancelTouch:(BOOL)fireTouchActions
{
    if( fireTouchActions )
    {
        IXBaseControl* parentControl = (IXBaseControl*)[self parentObject];
        if( [parentControl contentView] )
        {
            [parentControl processCancelTouch:fireTouchActions];
        }
        [[self actionContainer] executeActionsForEventNamed:kIXTouchCancelled];
    }
}

-(void)processEndTouch:(BOOL)fireTouchActions
{
    if( fireTouchActions )
    {
        IXBaseControl* parentControl = (IXBaseControl*)[self parentObject];
        if( [parentControl contentView] )
        {
            [parentControl processEndTouch:fireTouchActions];
        }
        [[self actionContainer] executeActionsForEventNamed:kIXTouchUp];
    }
}

-(void)conserveMemory
{
    for( IXBaseControl* control in [self childObjects] )
    {
        [control conserveMemory];
    }
}

@end
