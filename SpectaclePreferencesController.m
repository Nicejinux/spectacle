#import "SpectaclePreferencesController.h"
#import "SpectacleHotKeyManager.h"
#import "SpectacleHotKeyValidator.h"
#import "SpectacleSplitRateManager.h"
#import "SpectacleWindowPositionManager.h"
#import "SpectacleUtilities.h"
#import "SpectacleConstants.h"

@interface SpectaclePreferencesController () 

@property (nonatomic, weak) SpectacleHotKeyManager *hotKeyManager;
@property (nonatomic, weak) SpectacleSplitRateManager *splitManager;
@property (nonatomic) NSDictionary *hotKeyRecorders;

@end

#pragma mark -

@implementation SpectaclePreferencesController

- (id)init {
    if ((self = [super initWithWindowNibName: SpectaclePreferencesWindowNibName])) {
        _hotKeyManager = SpectacleHotKeyManager.sharedManager;
        _splitManager  = SpectacleSplitRateManager.sharedManager;
    }
    
    return self;
}

#pragma mark -

- (void)windowDidLoad {
    NSInteger loginItemEnabledState = NSOffState;
    BOOL isStatusItemEnabled = [NSUserDefaults.standardUserDefaults boolForKey: SpectacleStatusItemEnabledPreference];
    
    _hotKeyRecorders = [[NSDictionary alloc] initWithObjectsAndKeys:
        _moveToCenterHotKeyRecorder,          SpectacleWindowActionMoveToCenter,
        _moveToFullscreenHotKeyRecorder,      SpectacleWindowActionMoveToFullscreen,
        _moveToLeftHotKeyRecorder,            SpectacleWindowActionMoveToLeftHalf,
        _moveToRightHotKeyRecorder,           SpectacleWindowActionMoveToRightHalf,
        _moveToTopHotKeyRecorder,             SpectacleWindowActionMoveToTopHalf,
        _moveToBottomHotKeyRecorder,          SpectacleWindowActionMoveToBottomHalf,
        _moveToUpperLeftHotKeyRecorder,       SpectacleWindowActionMoveToUpperLeft,
        _moveToLowerLeftHotKeyRecorder,       SpectacleWindowActionMoveToLowerLeft,
        _moveToUpperRightHotKeyRecorder,      SpectacleWindowActionMoveToUpperRight,
        _moveToLowerRightHotKeyRecorder,      SpectacleWindowActionMoveToLowerRight,
        _moveToNextDisplayHotKeyRecorder,     SpectacleWindowActionMoveToNextDisplay,
        _moveToPreviousDisplayHotKeyRecorder, SpectacleWindowActionMoveToPreviousDisplay,
        _moveToNextThirdHotKeyRecorder,       SpectacleWindowActionMoveToNextThird,
        _moveToPreviousThirdHotKeyRecorder,   SpectacleWindowActionMoveToPreviousThird,
        _makeLargerHotKeyRecorder,            SpectacleWindowActionMakeLarger,
        _makeSmallerHotKeyRecorder,           SpectacleWindowActionMakeSmaller,
        _undoLastMoveHotKeyRecorder,          SpectacleWindowActionUndoLastMove,
        _redoLastMoveHotKeyRecorder,          SpectacleWindowActionRedoLastMove, nil];
    
    [self loadRegisteredHotKeys];
    
    if ([SpectacleUtilities isLoginItemEnabledForBundle: SpectacleUtilities.applicationBundle]) {
        loginItemEnabledState = NSOnState;
    }
    
    [_colRateSlider setTag:SpectacleColSliderTag];
    [_colRateSlider setTarget:self];
    [_colRateSlider setAction:@selector(sliderDidMove:)];

    [_rowRateSlider setTag:SpectacleRowSliderTag];
    [_rowRateSlider setTarget:self];
    [_rowRateSlider setAction:@selector(sliderDidMove:)];

    [self loadRegisteredSplitRates];
    
    _loginItemEnabled.state = loginItemEnabledState;
    
    [_statusItemEnabled selectItemWithTag: isStatusItemEnabled ? 0 : 1];
}

- (void)sliderDidMove:(id)sender {
    NSEvent *event = [[NSApplication sharedApplication] currentEvent];
    BOOL endingDrag = event.type == NSLeftMouseUp;

    NSSlider *slider = (NSSlider *)sender;
    NSInteger value = [slider integerValue];
    [self resizeSplitPreview:slider];
    
    if (endingDrag) {
        NSLog(@"slider value stopped changing");
        // save current value to NSUserDefaults
        if (slider.tag == SpectacleColSliderTag) {
            [_splitManager registerColSplitRate:value];
        } else {
            [_splitManager registerRowSplitRate:value];
        }
    }
}

- (void)resizeSplitPreview:(NSSlider *)slider {
    NSRect rect;
    NSInteger value = [slider integerValue];
    CGFloat velocity = (value - SpectacleDefaultSplitRate) / SpectaclePreviewRatio;

    if (slider.tag == SpectacleColSliderTag) {
        [_colRateTextField setIntegerValue:value];
        rect = _colRatePreview.frame;
        rect.size.width = SpectaclePreviewRatio + velocity;
        [_colRatePreview setFrame:rect];
    } else {
        [_rowRateTextField setIntegerValue:value];
        rect = _rowRatePreview.frame;
        rect.size.height = SpectaclePreviewRatio + velocity;
        rect.origin.y = SpectacleRowSliderOffset - velocity;
        [_rowRatePreview setFrame:rect];
    }
}

#pragma mark -

- (void)toggleWindow: (id)sender {
    if (self.window.isKeyWindow) {
        [self hideWindow: sender];
    } else {
        [self showWindow: sender];
    }
}

#pragma mark -

- (void)hideWindow: (id)sender {
    [self close];
}

#pragma mark -

- (void)hotKeyRecorder: (ZKHotKeyRecorder *)hotKeyRecorder didReceiveNewHotKey: (ZKHotKey *)hotKey {
    SpectacleWindowPositionManager *windowPositionManager = SpectacleWindowPositionManager.sharedManager;
    
    [hotKey setHotKeyAction: ^(ZKHotKey *hotKey) {
        [windowPositionManager moveFrontMostWindowWithAction: [windowPositionManager windowActionForHotKey: hotKey]];
    }];
    
    [_hotKeyManager registerHotKey: hotKey];
}

- (void)hotKeyRecorder: (ZKHotKeyRecorder *)hotKeyRecorder didClearExistingHotKey: (ZKHotKey *)hotKey {
    [_hotKeyManager unregisterHotKeyForName: hotKey.hotKeyName];
}

#pragma mark -

- (IBAction)toggleLoginItem: (id)sender {
    NSBundle *applicationBundle = SpectacleUtilities.applicationBundle;
    
    if (_loginItemEnabled.state == NSOnState) {
        [SpectacleUtilities enableLoginItemForBundle: applicationBundle];
    } else{
        [SpectacleUtilities disableLoginItemForBundle: applicationBundle];
    }
}

- (IBAction)toggleStatusItem: (id)sender {
    NSString *notificationName = SpectacleStatusItemEnabledNotification;
    BOOL isStatusItemEnabled = YES;
    __block BOOL statusItemStateChanged = YES;
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    
    if ([userDefaults boolForKey: SpectacleStatusItemEnabledPreference] == ([[sender selectedItem] tag] == 0)) {
        return;
    }
    
    if ([sender selectedItem].tag != 0) {
        notificationName = SpectacleStatusItemDisabledNotification;
        isStatusItemEnabled = NO;
        
        if (![userDefaults boolForKey: SpectacleBackgroundAlertSuppressedPreference]) {
            [SpectacleUtilities displayRunningInBackgroundAlertWithCallback: ^(BOOL isConfirmed, BOOL isSuppressed) {
                if (!isConfirmed) {
                    statusItemStateChanged = NO;
                    
                    [sender selectItemWithTag: 0];
                }
                
                [userDefaults setBool: isSuppressed forKey: SpectacleBackgroundAlertSuppressedPreference];
            }];
        }
    }
    
    if (statusItemStateChanged) {
        [NSNotificationCenter.defaultCenter postNotificationName: notificationName object: self];
        
        [userDefaults setBool: isStatusItemEnabled forKey: SpectacleStatusItemEnabledPreference];
    }
}

#pragma mark -

- (void)loadRegisteredSplitRates {
    // get saved split rates
    NSInteger colRate = [_splitManager registeredColSplitRate];
    NSInteger rowRate = [_splitManager registeredRowSplitRate];
    
    // set saved split rates to slider and preview
    [_colRateSlider setIntegerValue:colRate];
    [self resizeSplitPreview:_colRateSlider];
    
    [_rowRateSlider setIntegerValue:rowRate];
    [self resizeSplitPreview:_rowRateSlider];
    
    // set saved split rates to textfields
    [_colRateTextField setIntegerValue:colRate];
    [_rowRateTextField setIntegerValue:rowRate];
}

#pragma mark -

- (void)loadRegisteredHotKeys {
    SpectacleHotKeyValidator *hotKeyValidator = [SpectacleHotKeyValidator new];
    
    for (NSString *hotKeyName in _hotKeyRecorders.allKeys) {
        ZKHotKeyRecorder *hotKeyRecorder = _hotKeyRecorders[hotKeyName];
        ZKHotKey *hotKey = [_hotKeyManager registeredHotKeyForName: hotKeyName];
        
        hotKeyRecorder.hotKeyName = hotKeyName;
        
        if (hotKey) {
            hotKeyRecorder.hotKey = hotKey;
        }
        
        hotKeyRecorder.delegate = self;
        
        hotKeyRecorder.additionalHotKeyValidators = @[hotKeyValidator];
    }
    
    
    [self enableHotKeyRecorders: YES];
}

#pragma mark -

- (void)enableHotKeyRecorders: (BOOL)enabled {
    for (ZKHotKeyRecorder *hotKeyRecorder in _hotKeyRecorders.allValues) {
        if (!enabled) {
            hotKeyRecorder.hotKey = nil;
        }
        
        hotKeyRecorder.enabled = enabled;
    }
}

@end
