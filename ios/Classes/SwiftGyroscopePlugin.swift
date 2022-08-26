import Flutter
import UIKit
import CoreMotion

public class SwiftGyroscopePlugin: NSObject, FlutterPlugin {

  private let gyroscopeStreamHandler = GyroscopeStreamHandler()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "gyroscope", binaryMessenger: registrar.messenger())
    let instance = SwiftGyroscopePlugin(registrar: registrar)
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  init(registrar: FlutterPluginRegistrar) {
          let CHANNEL_NAME = "gyroscope/"

          let gyroscopeChannel = FlutterEventChannel(name: CHANNEL_NAME, binaryMessenger: registrar.messenger())
          gyroscopeChannel.setStreamHandler(gyroscopeStreamHandler)
      }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
   switch call.method {
          case "getPlatformVersion":
              result("iOS " + UIDevice.current.systemVersion)
          case "isSensorAvailable":
              result(isSensorAvailable())
          case "setSensorUpdateInterval":
              let arguments = call.arguments as! NSDictionary
              setSensorUpdateInterval(arguments["interval"] as! Int)
          case "onCancleSensor":
              onCancleSensor(withArguments: call.arguments)
          default:
              result(FlutterMethodNotImplemented)
          }
  }
  public func isSensorAvailable() -> Bool {
          let motionManager = CMMotionManager()
          return motionManager.isGyroAvailable
      }

   public func setSensorUpdateInterval(_ interval: Int) {
          let timeInterval = TimeInterval(Double(interval) / 1000000.0)
              gyroscopeStreamHandler.setUpdateInterval(timeInterval)
      }

  public func onCancleSensor(withArguments arguments: Any?){
          gyroscopeStreamHandler.onCancel(withArguments: arguments)
      }
}

class GyroscopeStreamHandler: NSObject, FlutterStreamHandler {
    private let motionManager = CMMotionManager()
    private let queue = OperationQueue()

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        if motionManager.isGyroAvailable {
            motionManager.startGyroUpdates(to: queue) { (data, error) in
                if data != nil {
                    events([data!.rotationRate.x, data!.rotationRate.y, data!.rotationRate.z])
                }
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        motionManager.stopGyroUpdates()
        return nil
    }

    func setUpdateInterval(_ interval: TimeInterval) {
        motionManager.gyroUpdateInterval = interval
    }
}