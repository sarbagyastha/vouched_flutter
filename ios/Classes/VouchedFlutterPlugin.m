#import "VouchedFlutterPlugin.h"
#if __has_include(<vouched_flutter/vouched_flutter-Swift.h>)
#import <vouched_flutter/vouched_flutter-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "vouched_flutter-Swift.h"
#endif

@implementation VouchedFlutterPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVouchedFlutterPlugin registerWithRegistrar:registrar];
}
@end
