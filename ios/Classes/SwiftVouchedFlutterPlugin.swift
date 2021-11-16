import Flutter
import UIKit

public class SwiftVouchedFlutterPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let factory = DetectorViewFactory(messenger: registrar.messenger())
        registrar.register(factory, withId: "com.acmesoftware.vouched/detector")
    }
}
