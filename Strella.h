@interface _UILegibilitySettings : NSObject
@property (nonatomic,retain) UIColor * primaryColor;
@property (nonatomic,retain) UIColor * secondaryColor;
@property (nonatomic,retain) UIColor * contentColor;
-(void)setContentColor:(UIColor *)arg1;
-(UIColor *)contentColor;
-(void)setPrimaryColor:(UIColor *)arg1;
-(UIColor *)primaryColor;
-(void)setSecondaryColor:(UIColor *)arg1;
-(UIColor *)secondaryColor;
@end

@interface SBUILegibilityLabel : UIView
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,copy) UIColor *textColor;
@property (nonatomic,copy) NSString *string;
@property (nonatomic,retain) _UILegibilitySettings *legibilitySettings;
-(void)_updateLegibilityView;
-(void)_updateLabelForLegibilitySettings;
@end

@interface SBFLockScreenDateView : UIView
-(id)_timeLabel;
-(void)setAlignmentPercent:(double)arg1;
-(void)setupTime;
-(void)setupDate;
-(void)setupEvents;
-(void)reloadEvents;
-(void)setupColors;
-(void)fadeOutElementsWithDuration:(float)duration withDelay:(float)delay;
-(void)fadeInElementsWithDuration:(float)duration withDelay:(float)delay;
@end

@interface SBFLockScreenDateSubtitleDateView : UIView
@end

@interface NCNotificationListView : UIView
@end

@interface CSCoverSheetViewController
-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3;
@end

@interface MPArtworkColorAnalyzer : NSObject
@property (nonatomic,readonly) long long algorithm;
@property (nonatomic,readonly) UIImage *image;
-(id)initWithImage:(id)arg1 algorithm:(long long)arg2;
-(void)analyzeWithCompletionHandler:(/*^block*/id)arg1;
-(id)_fallbackColorAnalysis;
@end

@interface MPArtworkColorAnalysis
@property (nonatomic,readonly) UIColor *backgroundColor;
@property (getter=isBackgroundColorLight,nonatomic,readonly) BOOL backgroundColorLight;
@property (nonatomic,readonly) UIColor *primaryTextColor;
@property (getter=isPrimaryTextColorLight,nonatomic,readonly) BOOL primaryTextColorLight;
@property (nonatomic,readonly) UIColor *secondaryTextColor;
@property (getter=isSecondaryTextColorLight,nonatomic,readonly) BOOL secondaryTextColorLight;
-(UIColor*)backgroundColor;
-(BOOL)isBackgroundColorLight;
-(UIColor*)primaryTextColor;
-(BOOL)isPrimaryTextColorLight;
-(UIColor*)secondaryTextColor;
-(BOOL)isSecondaryTextColorLight;
@end


@interface UIView (Strella)
@property (nonatomic, retain) NSMutableArray<NSLayoutConstraint*> *_internalConstraints;
@end