#import "STACells.h"

@implementation STASwitchCell
-(void)didMoveToWindow {
    [super didMoveToWindow];
    self.layer.cornerRadius = 13;
    self.layer.masksToBounds = YES; 
    [self setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];  
    [self _setBackgroundInset:UIEdgeInsetsMake(0, 15, 0, 15)];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 15;
    frame.size.width -= 2 * 15;
    [super setFrame:frame];
}
@end