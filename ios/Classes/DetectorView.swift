import Flutter
import UIKit
import VouchedCore

class DetectorView: NSObject, FlutterPlatformView, FlutterStreamHandler {
  private var previewView: UIView
  private var cameraHelper: VouchedCameraHelper?
  private var eventSink: FlutterEventSink? = nil
  private var session: VouchedSession
  private var channel: FlutterMethodChannel

  init(
    frame: CGRect,
    viewIdentifier viewId: Int64,
    arguments args: [String: Any],
    binaryMessenger messenger: FlutterBinaryMessenger
  ) {
    let screenSize: CGSize = UIScreen.main.bounds.size
    previewView = UIView(
      frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
    )
    channel = FlutterMethodChannel(name: "com.acmesoftware.vouched", binaryMessenger: messenger)
    session = VouchedSession(
      apiKey: args["api_key"] as? String,
      sessionParameters: VouchedSessionParameters()
    )

    super.init()
    FlutterEventChannel(name: "com.acmesoftware.vouched/event", binaryMessenger: messenger)
      .setStreamHandler(self)
  }

  private func configureHelper() {
    channel.setMethodCallHandler { (call: FlutterMethodCall, result: FlutterResult) -> Void in
      switch call.method {
      case "pauseCamera": self.pauseCamera()
      case "resumeCamera": self.resumeCamera()
      default: result(FlutterMethodNotImplemented)
      }
    }

    cameraHelper = VouchedCameraHelper(with: CardDetect.self, in: previewView)?.withCapture(
      delegate: {
        self.onCardDetailResult($0)
      })
  }

  private func onCardDetailResult(_ result: CaptureResult) {
    switch result {
    case .id(let result):
      guard let result = result as? CardDetectResult else { return }

      var successData = [String: Any]()

      successData["step"] = getStep(result.step)
      successData["instruction"] = getInstruction(result.instruction)
      successData["image"] = result.image

      let location = result.boundingBox
      if location != nil {
        let origin = location!.origin
        let left = origin.x
        let top = origin.y
        let right = left + location!.width
        let bottom = right + location!.height

        successData["location"] = ["l": left, "t": top, "r": right, "b": bottom]
      }

      eventSink?(successData)

      if result.step == Step.postable {
        cameraHelper?.stopCapture()
        DispatchQueue.global().async {
          do {
            let job = try self.session.postFrontId(detectedCard: result)
            DispatchQueue.main.async { [self] in
              self.channel.invokeMethod("success", arguments: self.convertObjToString(job))
            }
          } catch {
            DispatchQueue.main.async {
              self.channel.invokeMethod("error", arguments: error.localizedDescription)
            }
          }
        }
      }

    default:
      print("")
    }
  }

  func view() -> UIView {
    self.configureHelper()
    self.cameraHelper?.startCapture()

    return previewView
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError?
  {
    self.eventSink = events
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  private func pauseCamera() {
    cameraHelper?.stopCapture()
  }

  private func resumeCamera() {
    cameraHelper?.startCapture()
  }

  private func convertObjToString<T>(_ obj: T) -> String? where T: Encodable {
    do {
      return String(data: try JSONEncoder().encode(obj), encoding: .utf8)!
    } catch {
      print(error)
    }
    return nil
  }

  private func getStep(_ step: Step) -> String {
    switch step {

    case .preDetected:
      return "PRE_DETECTED"
    case .detected:
      return "DETECTED"
    case .postable:
      return "POSTABLE"
    @unknown default:
      return "NONE"
    }
  }

  private func getInstruction(_ instruction: Instruction) -> String {
    switch instruction {

    case .onlyOne:
      return "NO_CARD"
    case .moveCloser:
      return "MOVE_CLOSER"
    case .moveAway:
      return "MOVE_AWAY"
    case .holdSteady:
      return "HOLD_STEADY"
    case .openMouth:
      return "OPEN_MOUTH"
    case .closeMouth:
      return "CLOSE_MOUTH"
    case .lookForward:
      return "LOOK_FORWARD"
    case .blinkEyes:
      return "BLINK_EYES"
    case .none:
      return "NONE"
    @unknown default:
      return "NONE"
    }
  }
}
