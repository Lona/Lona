//
// You create an application Preferences window using code like this:
//     _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers
//                                                                                              title:title]
//
// To open the Preferences window:
//     [_preferencesWindowController showWindow:sender]
//

#import "MASPreferencesViewController.h"

extern NSString *const kMASPreferencesWindowControllerDidChangeViewNotification;

__attribute__((__visibility__("default")))
#if MAC_OS_X_VERSION_MAX_ALLOWED > MAC_OS_X_VERSION_10_5
@interface MASPreferencesWindowController : NSWindowController <NSToolbarDelegate, NSWindowDelegate>
#else
@interface MASPreferencesWindowController : NSWindowController
#endif
{
@private
    NSMutableArray *_viewControllers;
    NSMutableDictionary *_minimumViewRects;
    NSString *_title;
    NSViewController <MASPreferencesViewController> *_selectedViewController;
    NSToolbar * __unsafe_unretained _toolbar;
}

@property (nonatomic, readonly) NSMutableArray *viewControllers;
@property (nonatomic, readonly) NSUInteger indexOfSelectedController;
@property (nonatomic, readonly, retain) NSViewController <MASPreferencesViewController> *selectedViewController;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, assign) IBOutlet NSToolbar *toolbar;

- (id)initWithViewControllers:(NSArray *)viewControllers;
- (id)initWithViewControllers:(NSArray *)viewControllers title:(NSString *)title;
- (void)addViewController:(NSViewController <MASPreferencesViewController> *) viewController;

- (void)selectControllerAtIndex:(NSUInteger)controllerIndex;
- (void)selectControllerWithIdentifier:(NSString *)identifier;

- (IBAction)goNextTab:(id)sender;
- (IBAction)goPreviousTab:(id)sender;

@end
