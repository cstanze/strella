#import <UIKit/UIKit.h>

CGRect CGRectMoveX(float x, CGRect frame) {
    return CGRectMake(frame.origin.x + x, frame.origin.y, frame.size.width, frame.size.height);
}

CGRect CGRectMoveY(float y, CGRect frame) {
    return CGRectMake(frame.origin.x, frame.origin.y + y, frame.size.width, frame.size.height);
}

// Interfaces
@interface StrellaLabel : UILabel
@end

@interface StrellaStackView : UIStackView
@end

@interface StrellaView : UIView
@end

// Implementations
@implementation StrellaLabel
@end

@implementation StrellaStackView
@end

@implementation StrellaView
@end