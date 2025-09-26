import Flutter
import MobileRTC
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let securityEnabled = false  // Toggle this to enable/disable security features
  private var securityOverlayWindow: UIWindow?
  private var isScreenRecording = false
  private var isInMeeting = false
  private var authResultCallback: FlutterResult?
  private var shouldShowSecurityOverlay = false

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    // Initialize security features
    setupScreenRecordingDetection()
    setupSecurityOverlay()

    // Setup Zoom SDK
    setupZoomSDK()

    // Setup method channel for Zoom
    setupZoomMethodChannel()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Security Features

  private func setupScreenRecordingDetection() {
    if !securityEnabled { return }
    if #available(iOS 11.0, *) {
      NotificationCenter.default.addObserver(
        self,
        selector: #selector(screenRecordingChanged),
        name: UIScreen.capturedDidChangeNotification,
        object: nil
      )
    }
    // Also listen for screenshot notifications
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenshotTaken),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
    // Listen for AirPlay/Screen Mirroring changes
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(airplayStatusChanged),
      name: UIScreen.didConnectNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(airplayStatusChanged),
      name: UIScreen.didDisconnectNotification,
      object: nil
    )
  }

  @objc private func screenRecordingChanged() {
    if !securityEnabled { return }
    if #available(iOS 11.0, *) {
      let isCurrentlyRecording = UIScreen.main.isCaptured

      // Add a delay to verify if it's actual recording or just Control Center
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        // Double-check after delay to ensure it's persistent recording
        let isStillRecording = UIScreen.main.isCaptured

        if isStillRecording != self.isScreenRecording {
          self.isScreenRecording = isStillRecording

          // Only trigger security alert if actually recording and in meeting
          // But first check if it's screen mirroring instead of recording
          if isStillRecording && self.isInMeeting {
            if self.isScreenMirroringOrAirPlaying() {
              // This is screen mirroring, not recording - let the airplay handler deal with it
              return
            }
            self.forceLeaveMeetingWithSecurityAlert(
              reason:
                "Screen recording is not allowed during meetings for security reasons."
            )
          }
        }
      }
    }
  }

  @objc private func screenshotTaken() {
    if !securityEnabled { return }
    if isInMeeting {
      forceLeaveMeetingWithSecurityAlert(
        reason: "Screenshots are not allowed during meetings for security reasons.")
    }
  }

  @objc private func airplayStatusChanged() {
    if !securityEnabled { return }
    if isInMeeting && isScreenMirroringOrAirPlaying() {
      forceLeaveMeetingWithSecurityAlert(
        reason:
          "Screen casting (AirPlay/Screen Mirroring) is not allowed during meetings for security reasons."
      )
    }
  }

  private func isScreenMirroringOrAirPlaying() -> Bool {
    // Check for external screens (AirPlay/Screen Mirroring)
    return UIScreen.screens.count > 1
  }

  private func forceLeaveMeetingWithSecurityAlert(reason: String) {
    if !securityEnabled { return }
    DispatchQueue.main.async {
      self.showSecurityAlert(
        title: "Unsecured Action Detected",
        message: reason
      )
      self.shouldShowSecurityOverlay = true
      self.showSecurityOverlay()
      let meetingService = MobileRTC.shared().getMeetingService()
      meetingService?.leaveMeeting(with: .leave)
    }
  }

  private func setupSecurityOverlay() {
    securityOverlayWindow = UIWindow(frame: UIScreen.main.bounds)
    securityOverlayWindow?.windowLevel = UIWindow.Level.alert + 1
    securityOverlayWindow?.backgroundColor = UIColor.black
    securityOverlayWindow?.isHidden = true

    let overlayView = UIView(frame: UIScreen.main.bounds)
    if #available(iOS 13.0, *) {
      overlayView.backgroundColor = UIColor.systemBackground
    } else {
      overlayView.backgroundColor = UIColor.white
    }

    let securityLabel = UILabel()
    securityLabel.text = "Content Hidden for Security"
    securityLabel.textAlignment = .center
    securityLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    if #available(iOS 13.0, *) {
      securityLabel.textColor = UIColor.label
    } else {
      securityLabel.textColor = UIColor.black
    }

    securityLabel.translatesAutoresizingMaskIntoConstraints = false
    overlayView.addSubview(securityLabel)

    NSLayoutConstraint.activate([
      securityLabel.centerXAnchor.constraint(equalTo: overlayView.centerXAnchor),
      securityLabel.centerYAnchor.constraint(equalTo: overlayView.centerYAnchor),
    ])

    securityOverlayWindow?.addSubview(overlayView)
  }

  private func showSecurityOverlay() {
    if !securityEnabled { return }
    guard let securityWindow = securityOverlayWindow else { return }
    securityWindow.isHidden = false
    securityWindow.makeKeyAndVisible()
  }

  private func hideSecurityOverlay() {
    if !securityEnabled { return }
    securityOverlayWindow?.isHidden = true
    if let mainWindow = window {
      mainWindow.makeKeyAndVisible()
    }
  }

  private func showSecurityAlert(title: String, message: String) {
    if !securityEnabled { return }
    guard let rootViewController = window?.rootViewController else { return }

    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default))

    rootViewController.present(alert, animated: true)
  }

  // MARK: - App Lifecycle for Security

  override func applicationWillResignActive(_ application: UIApplication) {
    if !securityEnabled { return }
    super.applicationWillResignActive(application)
    // Only show overlay if we're in meeting and actually going to background
    // Not for temporary states like Control Center
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
      if self.isInMeeting && UIApplication.shared.applicationState == .background {
        self.shouldShowSecurityOverlay = true
        self.showSecurityOverlay()
      }
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    if !securityEnabled { return }
    super.applicationDidBecomeActive(application)
    if shouldShowSecurityOverlay && !isScreenRecording {
      shouldShowSecurityOverlay = false
      hideSecurityOverlay()
    }
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    if !securityEnabled { return }
    super.applicationDidEnterBackground(application)
    if isInMeeting {
      // Show security overlay immediately when going to background
      shouldShowSecurityOverlay = true
      showSecurityOverlay()

      // Treat backgrounding as a security violation - same as screenshot/recording
      forceLeaveMeetingWithSecurityAlert(
        reason:
          "Putting the app in background during meetings is not allowed for security reasons."
      )
    }
  }

  override func applicationWillEnterForeground(_ application: UIApplication) {
    if !securityEnabled { return }
    super.applicationWillEnterForeground(application)
    // Hide security overlay when returning to foreground after a security violation
    if shouldShowSecurityOverlay {
      shouldShowSecurityOverlay = false
      hideSecurityOverlay()
    }
  }

  // MARK: - Zoom SDK Setup

  private func setupZoomSDK() {
    let context = MobileRTCSDKInitContext()
    // Remove enableLogByDefault - it doesn't exist in this SDK version
    context.domain = "https://zoom.us"

    MobileRTC.shared().initialize(context)

    let authService = MobileRTC.shared().getAuthService()
    authService?.delegate = self
  }

  private func setupZoomMethodChannel() {
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(
      name: "zoom_bridge",
      binaryMessenger: controller.binaryMessenger
    )

    channel.setMethodCallHandler { [weak self] (call, result) in
      self?.handleZoomMethodCall(call: call, result: result)
    }
  }

  private func handleZoomMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "init":
      guard let args = call.arguments as? [String: Any],
        let jwtToken = args["jwtToken"] as? String
      else {
        result(FlutterError(code: "ARGS", message: "Missing jwtToken", details: nil))
        return
      }
      initializeZoom(jwt: jwtToken, result: result)

    case "join":
      guard let args = call.arguments as? [String: Any],
        let meetingNumber = args["meetingNumber"] as? String,
        let passcode = args["passcode"] as? String,
        let displayName = args["displayName"] as? String
      else {
        result(FlutterError(code: "ARGS", message: "Missing arguments", details: nil))
        return
      }
      joinMeeting(
        meetingNumber: meetingNumber, passcode: passcode, displayName: displayName,
        result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initializeZoom(jwt: String, result: @escaping FlutterResult) {
    let authService = MobileRTC.shared().getAuthService()
    authService?.jwtToken = jwt
    authService?.sdkAuth()

    authResultCallback = result
  }

  private func joinMeeting(
    meetingNumber: String, passcode: String, displayName: String,
    result: @escaping FlutterResult
  ) {
    guard MobileRTC.shared().isRTCAuthorized() else {
      result(FlutterError(code: "AUTH", message: "SDK not authorized", details: nil))
      return
    }

    let meetingService = MobileRTC.shared().getMeetingService()
    meetingService?.delegate = self

    let params = MobileRTCMeetingJoinParam()
    params.meetingNumber = meetingNumber
    params.password = passcode
    params.userName = displayName

    let joinResult = meetingService?.joinMeeting(with: params)

    if joinResult == .success {
      result(0)  // Return 0 for success
    } else {
      result(
        FlutterError(
          code: "JOIN", message: "Failed to join meeting", details: joinResult?.rawValue))
    }
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }
}

// MARK: - MobileRTCAuthDelegate

extension AppDelegate: MobileRTCAuthDelegate {
  func onMobileRTCAuthReturn(_ returnValue: MobileRTCAuthError) {
    DispatchQueue.main.async {
      if returnValue == .success {
        self.authResultCallback?(true)
      } else {
        self.authResultCallback?(
          FlutterError(
            code: "AUTH",
            message: "Authentication failed",
            details: returnValue.rawValue
          ))
      }
      self.authResultCallback = nil
    }
  }

  func onMobileRTCLoginReturn(_ loginRet: Int) {
    // Not used for JWT authentication
  }

  func onMobileRTCLogoutReturn(_ logoutRet: Int) {
    // Not used for JWT authentication
  }
}

// MARK: - MobileRTCMeetingServiceDelegate

extension AppDelegate: MobileRTCMeetingServiceDelegate {
  func onMeetingReturn(_ error: MobileRTCMeetError, internalError: Int) {
    print("Meeting ended with error: \(error.rawValue)")
    isInMeeting = false
    shouldShowSecurityOverlay = false
    hideSecurityOverlay()
  }

  func onMeetingStateChange(_ state: MobileRTCMeetingState) {
    print("Meeting state changed: \(state.rawValue)")
    switch state {
    case .inMeeting:
      isInMeeting = true
      // Enable strict security during meeting
      if isScreenRecording {
        forceLeaveMeetingWithSecurityAlert(
          reason: "Screen recording is not allowed during meetings for security reasons.")
      } else if isScreenMirroringOrAirPlaying() {
        forceLeaveMeetingWithSecurityAlert(
          reason:
            "Screen casting (AirPlay/Screen Mirroring) is not allowed during meetings for security reasons."
        )
      }
    case .ended, .failed:
      isInMeeting = false
      shouldShowSecurityOverlay = false
      hideSecurityOverlay()
    default:
      break
    }
  }

  func getMeetingPassword() -> String {
    return ""
  }

  func onClickedDialOut(_ number: String) -> Bool {
    return false
  }

  func onClickedInvitePhone() -> Bool {
    return false
  }

  func onClickedInviteH323() -> Bool {
    return false
  }
}
