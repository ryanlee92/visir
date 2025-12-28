import Cocoa
import FlutterMacOS
import FirebaseMessaging

@main
class AppDelegate: FlutterAppDelegate, NSWindowDelegate {
    override func applicationDidFinishLaunching(_ notification: Notification) {
        self.mainFlutterWindow!.delegate = self
        
        if let window = self.mainFlutterWindow {
            let closeBtn = window.standardWindowButton(.closeButton)
            let miniBtn  = window.standardWindowButton(.miniaturizeButton)
            let zoomBtn  = window.standardWindowButton(.zoomButton)

            closeBtn?.isHidden = true
            miniBtn?.isHidden  = true
            zoomBtn?.isHidden  = true
        }

        guard let controller = mainFlutterWindow?.contentViewController as? FlutterViewController else { return }
        let channel = FlutterMethodChannel(name: "window_info",
                                        binaryMessenger: controller.engine.binaryMessenger)
        channel.setMethodCallHandler { [weak self] call, result in
            guard call.method == "getFrame" else { result(FlutterMethodNotImplemented); return }
            guard let win = Self.currentWindow() else {
                result(FlutterError(code: "NO_WINDOW", message: "No window", details: nil)); return
            }
            let frame = win.frame              // 단위: pt(논리픽셀)
            let scale = win.backingScaleFactor // 물리픽셀 변환용

            var dict: [String: Any] = [
                "x": frame.origin.x,
                "yBottomLeft": frame.origin.y,               // mac 좌표계: 좌하단 원점
                "width": frame.size.width,
                "height": frame.size.height,
                "scale": scale
            ]
            if let screen = win.screen ?? NSScreen.main {
                let screenH = screen.frame.size.height
                let visible = screen.visibleFrame
                // 상단-좌측 원점 y (전체 화면 기준)
                let yTopLeft = screenH - frame.origin.y - frame.size.height
                // 메뉴바 높이 (전체 화면 - 작업 영역)
                let menuBarHeight = screenH - visible.size.height - visible.origin.y
                // 작업 영역 기준 상단-좌측 y
                let yTopLeftWorking = yTopLeft - menuBarHeight

                dict["yTopLeft"] = yTopLeft
                dict["menuBarHeight"] = menuBarHeight
                dict["yTopLeftWorking"] = yTopLeftWorking
            }
            // 클라이언트 영역만 필요하면:
            let content = NSWindow.contentRect(forFrameRect: frame, styleMask: win.styleMask)
            dict["contentWidth"]  = content.size.width
            dict["contentHeight"] = content.size.height

            result(dict)
        }

        let titleBarChannel = FlutterMethodChannel(
            name: "custom/titlebar",
            binaryMessenger: controller.engine.binaryMessenger
        )

        titleBarChannel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            switch call.method {
            case "updateButtonPosition":
                guard let args = call.arguments as? [String: Any],
                    let height = args["height"] as? CGFloat
                else {
                result(FlutterError(code: "BAD_ARGS", message: "height missing", details: nil))
                return
                }
               
                result(self?.updateTrafficLightPositions(forTitlebarHeight: height))

            default:
                result(FlutterMethodNotImplemented)
            }
        }

        updateTrafficLightPositions(forTitlebarHeight: 52)
    }

    @discardableResult
    private func updateTrafficLightPositions(forTitlebarHeight titlebarHeight: CGFloat) -> Bool {
        guard let window = NSApplication.shared.windows.first else { return false }

        // 전체 화면 모드 확인
        let isFullScreen = window.styleMask.contains(.fullScreen)
        if isFullScreen {
            return true
        }

        // 세 표준 버튼 가져오기
        let closeBtn = window.standardWindowButton(.closeButton)
        let miniBtn  = window.standardWindowButton(.miniaturizeButton)
        let zoomBtn  = window.standardWindowButton(.zoomButton)

        @discardableResult
        func moveY(_ button: NSButton?, _ x: CGFloat) -> Bool {
            guard let button = button, let superview = button.superview, let window = button.window else { return false }
            let btnHeight = button.frame.size.height

            var targetCenterYInWindow: CGFloat
            
            if isFullScreen {
                // 전체 화면 모드일 때: 화면 상단에서 약 6pt 아래에 위치
                let windowHeight = window.frame.size.height
                let topOffset: CGFloat = 6.0
                targetCenterYInWindow = windowHeight - topOffset - (btnHeight / 2.0)
            } else {
                // 일반 창 모드일 때: 기존 로직 유지
                let windowHeight = window.frame.size.height
                targetCenterYInWindow = windowHeight - (titlebarHeight / 2.0)
            }
            
            // 버튼 superview 좌표계로 변환하여 항상 시각적 중앙 정렬을 유지합니다.
            let targetCenterYInSuperview = superview.convert(NSPoint(x: 0, y: targetCenterYInWindow), from: nil).y

            var frame = button.frame
            frame.origin.y = round(targetCenterYInSuperview - (btnHeight / 2.0))
            frame.origin.x = x
            button.setFrameOrigin(frame.origin)
            button.isHidden = false
            return true
        }


        // 개별 버튼 이동
        let closeResult = moveY(closeBtn, 9 + 6)
        let miniResult = moveY(miniBtn, 32 + 6)
        let zoomResult = moveY(zoomBtn, 55 + 6)

        // 레이아웃 갱신 보장
        window.layoutIfNeeded()
        window.displayIfNeeded()
        return closeResult && miniResult && zoomResult
    }

    private static func currentWindow() -> NSWindow? {
        return NSApp.keyWindow ?? NSApp.mainWindow ?? NSApp.windows.first { $0.isVisible }
    }
    
    override func application(_ application: NSApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    override func applicationDidBecomeActive(_ notification: Notification) {
        self.mainFlutterWindow!.delegate = self
    }

    override func applicationDidUpdate(_ notification: Notification) {
        self.mainFlutterWindow!.delegate = self
    }
    
    // 전체 화면 모드 진입 시 호출
    func windowDidEnterFullScreen(_ notification: Notification) {
        // 전체 화면 모드로 전환될 때 traffic 버튼 위치 업데이트
        updateTrafficLightPositions(forTitlebarHeight: 52)
    }
    
    // 전체 화면 모드 종료 시 호출
    func windowDidExitFullScreen(_ notification: Notification) {
        // 일반 창 모드로 돌아올 때 traffic 버튼 위치 업데이트
        updateTrafficLightPositions(forTitlebarHeight: 52)
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
}
