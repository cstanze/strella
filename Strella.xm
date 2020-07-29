#import "Strella.h"
#import "Weather/Weather.h"
#import "StrellaCommon.h"
#import <Cephei/HBPreferences.h>
#import <EventKit/EventKit.h>

extern "C" CFArrayRef CPBitmapCreateImagesFromData(CFDataRef cpbitmap, void*, int, void*);

		/* Colors */
	static UIColor *timeColor = [UIColor whiteColor];
	static UIColor *dateColor = [UIColor colorWithRed:0.861 green:0.750 blue:1.0 alpha:1.0];
	static UIColor *upNextTitleColor = [UIColor whiteColor];
	static UIColor *eventDataColor = [UIColor colorWithRed:0.861 green:0.750 blue:1.0 alpha:1.0];
	    /* Up Next */
	static StrellaStackView *upNextContainer;
	static BOOL shouldShowUpNext = YES;
	static NSMutableArray *allowedCalendars;
		/* Keep track of this */
	static SBFLockScreenDateView *lockScreenDateView;
	static BOOL enabled;

%hook CSCoverSheetViewController
-(void)_transitionChargingViewToVisible:(BOOL)arg1 showBattery:(BOOL)arg2 animated:(BOOL)arg3 {
  if(arg2) {
    [lockScreenDateView fadeOutElementsWithDuration:1.5 withDelay:0];
    %orig;
    [lockScreenDateView fadeInElementsWithDuration:1.25 withDelay:2.5];
  } else {
    %orig;
  }
}
%end

%hook SBFLockScreenDateView
-(id)initWithFrame:(CGRect)arg1 {
	return lockScreenDateView = %orig;
}

-(void)setAlignmentPercent:(double)arg1 {
	%orig(-1);
}

-(void)didMoveToSuperview {
    %orig;

	[allowedCalendars addObject:@"Work"];
	[self setupColors];
	[self setupTime];
	[self setupDate];
	// [self setupEvents];
	[[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(reloadEvents) 
        name:EKEventStoreChangedNotification
        object:nil];
}

-(void)didMoveToWindow {
	%orig;
	[self setupColors];
}

-(void)layoutSubviews {
	%orig;
	[self setupTime];
	[self setupDate];
}

%new
-(void)setupTime {
	SBUILegibilityLabel *timeLabel = [self _timeLabel];
	timeLabel.tag = 7284;
	timeLabel.font = [UIFont systemFontOfSize:55 weight:UIFontWeightRegular];
	[timeLabel.legibilitySettings setPrimaryColor:timeColor];
	[timeLabel _updateLegibilityView];
}

%new
-(void)setupDate {
	SBFLockScreenDateSubtitleDateView *sdv = [self valueForKey:@"_dateSubtitleView"];
	sdv.tag = 7285;
	// 4.46875
	SBUILegibilityLabel *dateLabel = sdv.subviews[0];
	dateLabel.font = [UIFont systemFontOfSize:24 weight:UIFontWeightSemibold];
	[dateLabel.legibilitySettings setPrimaryColor:dateColor];
	[dateLabel _updateLegibilityView];
}

%new
-(void)setupEvents {
	if(upNextContainer != nil) return;
	upNextContainer = [[StrellaStackView alloc] init];
	upNextContainer.axis = UILayoutConstraintAxisVertical;
	upNextContainer.spacing = 15;
	upNextContainer.tag = 7283;
	[self addSubview:upNextContainer];

	StrellaLabel *upNextTitle = [[StrellaLabel alloc] init];
	upNextTitle.text = @"Up Next";
	upNextTitle.alpha = shouldShowUpNext ? 1 : 0;
	upNextTitle.tag = 7282;
	upNextTitle.font = [UIFont systemFontOfSize:22 weight:UIFontWeightSemibold];
	upNextTitle.textColor = upNextTitleColor;

	StrellaStackView *eventsContainer = [[StrellaStackView alloc] init];
	eventsContainer.axis = UILayoutConstraintAxisVertical;

	// Query and setup events
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	NSArray *allCalendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
	NSMutableArray *localCalendars;
 
    for (int i=0; i<allCalendars.count; i++) {
        EKCalendar *currentCalendar = [allCalendars objectAtIndex:i];
        if ([allowedCalendars containsObject:currentCalendar.title]) {
			[localCalendars addObject:currentCalendar];
        }
    }
	StrellaStackView *eventStack = [[StrellaStackView alloc] init];
	eventStack.axis = UILayoutConstraintAxisHorizontal;

	// Create a predicate value with start date now and end date a week after the current date.
	int weekSeconds = 7 * (60 * 60 * 24);
	NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:[NSDate dateWithTimeIntervalSinceNow:weekSeconds] calendars:localCalendars];	
	// Get an array with all events.
	NSArray *eventsArray = [eventStore eventsMatchingPredicate:predicate];
	// Sort the array based on the start date.
	eventsArray = [eventsArray sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
	UILabel *eventTitle = [[UILabel alloc] init];
	UILabel *eventTime = [[UILabel alloc] init];
	[eventTitle setNumberOfLines:0];
	eventTime.tag = 7281;
	eventTitle.tag = 7280;
	eventTime.textColor = eventDataColor;
	eventTitle.textColor = eventDataColor;
	if(eventsArray.count > 0) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm"];
		NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
		[fullDateFormatter setDateFormat:@"EEEE, h:mm"];
		eventTitle.text = [eventsArray[0] title];
		eventTitle.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
		BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:[eventsArray[0] startDate]];
		eventTime.text = isToday ? [NSString stringWithFormat:@"Today, %@", [dateFormatter stringFromDate:[eventsArray[0] startDate]]] : [fullDateFormatter stringFromDate:[eventsArray[0] startDate]];
	} else {
		upNextTitle.alpha = 0;
	}

	// Fix up the autoresizing masks
	[upNextContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
	[eventsContainer setTranslatesAutoresizingMaskIntoConstraints:NO];
	[eventStack setTranslatesAutoresizingMaskIntoConstraints:NO];
	[eventTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
	[eventTime setTranslatesAutoresizingMaskIntoConstraints:NO];

	// Add the arranged subviews.
	[upNextContainer addArrangedSubview:upNextTitle];
	[upNextContainer addArrangedSubview:eventsContainer];
	[eventsContainer addArrangedSubview:eventStack];
	[eventStack addArrangedSubview:eventTitle];
	[eventStack addArrangedSubview:eventTime];
	[self addSubview:upNextContainer];

	// Add those darn constraints
	[upNextContainer.widthAnchor constraintEqualToConstant:[[UIScreen mainScreen] bounds].size.width / 1.1].active = YES;
	[upNextTitle.topAnchor constraintEqualToAnchor:upNextContainer.topAnchor constant:0].active = YES;
	[upNextTitle.leadingAnchor constraintEqualToAnchor:upNextContainer.leadingAnchor constant:0].active = YES;
	[upNextTitle.bottomAnchor constraintEqualToAnchor:upNextContainer.topAnchor constant:upNextTitle.font.lineHeight].active = YES;
	[upNextTitle.trailingAnchor constraintEqualToAnchor:upNextContainer.trailingAnchor constant:10].active = YES;
	[eventsContainer.topAnchor constraintEqualToAnchor:upNextTitle.bottomAnchor constant:0].active = YES;
	[eventsContainer.bottomAnchor constraintEqualToAnchor:upNextContainer.bottomAnchor constant:0].active = YES;
	[eventsContainer.leadingAnchor constraintEqualToAnchor:upNextContainer.leadingAnchor constant:0].active = YES;
	[eventsContainer.trailingAnchor constraintEqualToAnchor:upNextContainer.trailingAnchor constant:0].active = YES;
	[upNextContainer.topAnchor constraintEqualToAnchor:((UIView*)[self valueForKey:@"_dateSubtitleView"]).bottomAnchor constant:upNextContainer.frame.size.height].active = YES;
	[[self viewWithTag:7284].bottomAnchor constraintEqualToAnchor:upNextContainer.topAnchor constant:0].active = YES;
}

%new
-(void)reloadEvents {
	if(!shouldShowUpNext)
		return;

	// Query and setup events
	EKEventStore *eventStore = [[EKEventStore alloc] init];
	NSArray *allCalendars = [eventStore calendarsForEntityType:EKEntityTypeEvent];
	NSMutableArray *localCalendars;
 
    for (int i=0; i<allCalendars.count; i++) {
        EKCalendar *currentCalendar = [allCalendars objectAtIndex:i];
        if ([allowedCalendars containsObject:currentCalendar.title]) {
			[localCalendars addObject:currentCalendar];
        }
    }

	// Create a predicate value with start date now and end date a week after the current date.
	int weekSeconds = 7 * (60 * 60 * 24);
	NSPredicate *predicate = [eventStore predicateForEventsWithStartDate:[NSDate dateWithTimeIntervalSinceNow:0] endDate:[NSDate dateWithTimeIntervalSinceNow:weekSeconds] calendars:localCalendars];	
	
	// Get an array with all events.
	NSArray *eventsArray = [eventStore eventsMatchingPredicate:predicate];
	
	// Sort the array based on the start date.
	eventsArray = [eventsArray sortedArrayUsingSelector:@selector(compareStartDateWithEvent:)];
	((UILabel*)[self viewWithTag:7281]).textColor = eventDataColor;
	((UILabel*)[self viewWithTag:7280]).textColor = eventDataColor;
	((StrellaLabel*)[self viewWithTag:7282]).textColor = upNextTitleColor;

	if(eventsArray.count > 0) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"h:mm"];
		NSDateFormatter *fullDateFormatter = [[NSDateFormatter alloc] init];
		[fullDateFormatter setDateFormat:@"EEEE, h:mm"];
		((UILabel*)[self viewWithTag:7280]).text = [eventsArray[0] title];
		((UILabel*)[self viewWithTag:7280]).font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
		BOOL isToday = [[NSCalendar currentCalendar] isDateInToday:[eventsArray[0] startDate]];
		((UILabel*)[self viewWithTag:7281]).text = isToday ? [NSString stringWithFormat:@"Today, %@", [dateFormatter stringFromDate:[eventsArray[0] startDate]]] : [fullDateFormatter stringFromDate:[eventsArray[0] startDate]];
	} else {
		((StrellaLabel*)[self viewWithTag:7282]).alpha = 0;
	}
}

%new
-(void)setupColors {
	NSData *lockData = [NSData dataWithContentsOfFile:@"/User/Library/SpringBoard/OriginalLockBackground.cpbitmap"];
  	CFArrayRef lockArrayRef = CPBitmapCreateImagesFromData((__bridge CFDataRef)lockData, NULL, 1, NULL);
  	NSArray *lockArray = (__bridge NSArray*)lockArrayRef;
  	UIImage *lockWallpaper = [[UIImage alloc] initWithCGImage:(__bridge CGImageRef)(lockArray[0])];
  	CFRelease(lockArrayRef);
	MPArtworkColorAnalyzer *mca = [[MPArtworkColorAnalyzer alloc] initWithImage:lockWallpaper algorithm:0];
	[mca analyzeWithCompletionHandler:^(MPArtworkColorAnalyzer *mcd, MPArtworkColorAnalysis *mcx) {
		dateColor = mcx.primaryTextColor;
		eventDataColor = mcx.primaryTextColor;
	}];
}

%new
-(void)fadeOutElementsWithDuration:(float)duration withDelay:(float)delay {
	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
		((UIView*)[self viewWithTag:7283]).alpha = 0;
	} completion:nil];
}

%new
-(void)fadeInElementsWithDuration:(float)duration withDelay:(float)delay {
	[UIView animateWithDuration:duration delay:delay options:UIViewAnimationOptionCurveEaseOut animations:^{
		((UIView*)[self viewWithTag:7283]).alpha = 1;
	} completion:nil];
}

%end

%hook NCNotificationListView
-(void)layoutSubviews {
	if(CGRectEqualToRect(self.frame, [[UIScreen mainScreen] bounds]))
		self.frame = CGRectMoveY(45.f, self.frame);
	%orig;
}
%end

void loadPrefs() {
	HBPreferences *prefs = [[HBPreferences alloc] initWithIdentifier:@"com.constanze.strellaprefs"];
	[prefs registerBool:&enabled default:YES forKey:@"isEnabled"];
}

%ctor {
	loadPrefs();
	if(enabled)
		%init();
}