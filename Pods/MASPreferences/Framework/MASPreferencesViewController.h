//
// Any controller providing preference pane view must support this protocol
//

#import <Cocoa/Cocoa.h>

@protocol MASPreferencesViewController <NSObject>

@optional

- (void)viewWillAppear;
- (void)viewDidDisappear;
- (NSView *)initialKeyView;

@property (nonatomic, readonly) BOOL hasResizableWidth;
@property (nonatomic, readonly) BOOL hasResizableHeight;

@required

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSImage *toolbarItemImage;
@property (nonatomic, readonly) NSString *toolbarItemLabel;

@end
