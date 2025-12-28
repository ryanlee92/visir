import Cocoa
import FlutterMacOS
import LaunchAtLogin
import bitsdojo_window_macos

class MainFlutterWindow:  BitsdojoWindow {
    override func bitsdojo_window_configure() -> UInt {
        return BDW_CUSTOM_FRAME | BDW_HIDE_ON_STARTUP
    }

  override func awakeFromNib() {
      let flutterViewController = FlutterViewController.init()
      // Set an appropriate default size for initial window
      var windowFrame = self.frame
      // (e.g., 1200x800, centered)
      let defaultWidth: CGFloat = 1200
      let defaultHeight: CGFloat = 800

      // if windowFrame.width < 600 || windowFrame.height < 400 {
      //     if let screenFrame = NSScreen.main?.visibleFrame {
      //         windowFrame.size = NSSize(width: defaultWidth, height: defaultHeight)
      //         // Center the new window
      //         windowFrame.origin.x = screenFrame.origin.x + (screenFrame.width - defaultWidth) / 2
      //         windowFrame.origin.y = screenFrame.origin.y + (screenFrame.height - defaultHeight) / 2
      //     } else {
      //         windowFrame.size = NSSize(width: defaultWidth, height: defaultHeight)
      //     }
      // }

      self.contentViewController = flutterViewController
      // self.setFrame(windowFrame, display: true)

      self.backgroundColor = NSColor.clear
      flutterViewController.backgroundColor = NSColor.clear
      
      // Add FlutterMethodChannel platform code
      FlutterMethodChannel(
        name: "launch_at_startup", binaryMessenger: flutterViewController.engine.binaryMessenger
      )
      .setMethodCallHandler { (_ call: FlutterMethodCall, result: @escaping FlutterResult) in
        switch call.method {
        case "launchAtStartupIsEnabled":
          result(LaunchAtLogin.isEnabled)
        case "launchAtStartupSetEnabled":
          if let arguments = call.arguments as? [String: Any] {
            LaunchAtLogin.isEnabled = arguments["setEnabledValue"] as! Bool
          }
          result(nil)
        default:
          result(FlutterMethodNotImplemented)
        }
      }
      
      RegisterGeneratedPlugins(registry: flutterViewController)
      
      UserDefaults.standard.set("true", forKey: "firstOpen")

      super.awakeFromNib()
    }
}
