#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

static UIWindow *loginWindow;

@interface LoginViewController : UIViewController <WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];

    WKWebViewConfiguration *config = [WKWebViewConfiguration new];
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:config];
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.webView];

    NSURL *url = [NSURL URLWithString:@"https://licensegate.io/panel/frontend/deviceware"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self closeApp];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = url.absoluteString;

    if ([urlString hasPrefix:@"https://licensegate.io/panel/frontend/deviceware"]) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
        [self closeApp];
    }
}

- (void)closeApp {
    dispatch_async(dispatch_get_main_queue(), ^{
        exit(0);
    });
}

@end

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;

    dispatch_async(dispatch_get_main_queue(), ^{
        loginWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        loginWindow.backgroundColor = [UIColor blackColor];
        loginWindow.windowLevel = UIWindowLevelAlert + 1;

        LoginViewController *vc = [LoginViewController new];
        loginWindow.rootViewController = vc;
        [loginWindow makeKeyAndVisible];
    });
}

%end
