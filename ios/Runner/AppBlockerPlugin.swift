import Flutter
import UIKit

class AppBlockerPlugin: NSObject, FlutterPlugin {

    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.vitality.app_blocker",
            binaryMessenger: registrar.messenger()
        )
        let instance = AppBlockerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "isSupported":
            result(isScreenTimeAvailable())
        case "requestPermission":
            requestPermission(result: result)
        case "hasPermission":
            // TODO: Check AuthorizationCenter.shared.authorizationStatus
            //       once Family Controls entitlement is provisioned.
            result(false)
        case "setBlockedApps":
            setBlockedApps(call: call, result: result)
        case "startBlocking":
            startBlocking(result: result)
        case "stopBlocking":
            stopBlocking(result: result)
        case "unlockTemporarily":
            unlockTemporarily(call: call, result: result)
        case "isBlocking":
            result(UserDefaults.standard.bool(forKey: "app_blocker_is_blocking"))
        case "getRemainingUnlockTime":
            result(getRemainingUnlockSeconds())
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    // MARK: - Helpers

    private func isScreenTimeAvailable() -> Bool {
        if #available(iOS 16.0, *) {
            // Family Controls framework is available starting iOS 16.
            // TODO: Import FamilyControls and check actual availability.
            return true
        }
        return false
    }

    private func requestPermission(result: @escaping FlutterResult) {
        // TODO: Use AuthorizationCenter.shared.requestAuthorization(for: .individual)
        //       This requires the Family Controls entitlement from Apple.
        //       Returning true as a stub so the Flutter side can proceed in dev.
        result(true)
    }

    private func setBlockedApps(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let appIds = args["appIds"] as? [String] else {
            result(nil)
            return
        }
        UserDefaults.standard.set(appIds, forKey: "app_blocker_blocked_apps")
        // TODO: Convert bundle IDs to Application tokens and build a
        //       ManagedSettingsStore shield configuration.
        result(nil)
    }

    private func startBlocking(result: @escaping FlutterResult) {
        UserDefaults.standard.set(true, forKey: "app_blocker_is_blocking")
        // TODO: Apply ManagedSettingsStore shield to selected applications.
        result(nil)
    }

    private func stopBlocking(result: @escaping FlutterResult) {
        UserDefaults.standard.set(false, forKey: "app_blocker_is_blocking")
        unlockEndTime = nil
        // TODO: Remove ManagedSettingsStore shield.
        result(nil)
    }

    private var unlockEndTime: Date?

    private func unlockTemporarily(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let minutes = args["minutes"] as? Int, minutes > 0 else {
            result(nil)
            return
        }
        unlockEndTime = Date().addingTimeInterval(TimeInterval(minutes * 60))
        // TODO: Temporarily remove the shield and schedule re-application.
        result(nil)
    }

    private func getRemainingUnlockSeconds() -> Int {
        guard let end = unlockEndTime else { return 0 }
        let remaining = end.timeIntervalSinceNow
        return remaining > 0 ? Int(remaining) : 0
    }
}
