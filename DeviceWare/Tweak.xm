#import <UIKit/UIKit.h>
#import <sys/sysctl.h>

// Função para obter o UUID do dispositivo
NSString* deviceUUID() {
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return uuid ?: @"unknown";
}

// Função para validar a key com o LicenseGate
void checkLicense() {
    NSString *uuid = deviceUUID();
    NSString *apiKey = @"8858dd7d-8eaf-4e53-bd26-f3d2fc4939a7";
    NSString *urlStr = [NSString stringWithFormat:@"https://licensegate.vercel.app/api/license/validate?key=%@&device=%@", apiKey, uuid];

    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    dispatch_semaphore_t sema = dispatch_semaphore_create(0);

    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *res, NSError *err) {
        if (err || !data) {
            exit(0); // Erro de conexão
        }

        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        BOOL valid = [json[@"valid"] boolValue];

        if (!valid) {
            exit(0); // Key inválida
        }

        dispatch_semaphore_signal(sema);
    }] resume];

    dispatch_time_t timeout = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC));
    dispatch_semaphore_wait(sema, timeout); // Timeout 30s
}

%hook SpringBoard

- (void)applicationDidFinishLaunching:(id)application {
    %orig;
    dispatch_async(dispatch_get_main_queue(), ^{
        checkLicense();
    });
}

%end
