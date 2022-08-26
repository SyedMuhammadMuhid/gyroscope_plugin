#import "GyroscopePlugin.h"
#if __has_include(<gyroscope/gyroscope-Swift.h>)
#import <gyroscope/gyroscope-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "gyroscope-Swift.h"
#endif

@implementation GyroscopePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftGyroscopePlugin registerWithRegistrar:registrar];
}
@end
