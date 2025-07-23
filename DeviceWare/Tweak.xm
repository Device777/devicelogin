#import <UIKit/UIKit.h>
#import <substrate.h>

static void (*orig_applicationDidFinishLaunching)(id self, SEL _cmd, id application);

static void new_applicationDidFinishLaunching(id self, SEL _cmd, id application) {
    orig_applicationDidFinishLaunching(self, _cmd, application);

    dispatch_async(dispatch_get_main_queue(), ^{
        checkLicense();
    });
}

__attribute__((constructor)) static void tweak_init() {
    Class appDelegate = objc_getClass("UIApplicationDelegate");
    if (appDelegate) {
        MSHookMessageEx(appDelegate, @selector(applicationDidFinishLaunching:), (IMP)new_applicationDidFinishLaunching, (IMP *)&orig_applicationDidFinishLaunching);
    }
}

NSString* deviceUUID() {
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return uuid ?: @"unknown";
}

void checkLicense() {
    NSString *uuid = deviceUUID();
    NSString *apiKey = @"8858dd7d-8eaf-4e53-bd26-f3d2fc4939a7";
    NSString *urlStr = [NSString stringWithFormat:@"https://licensegate.vercel.app/api/license/validate?key=%@&device=%@", apiKey, uuid];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
        if (err || !data) {
            exit(0);
        }

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL valid = [json[@"valid"] boolValue];

        if (!valid) {
            exit(0);
        }

        dispatch_semaphore_signal(sema);
    }] resume];

    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC));
    dispatch_semaphore_wait(sema, timeout);
}
