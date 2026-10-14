import Foundation

/// Heddle launch hook for live frames. `-ReviewScreen today|log|goals`
/// plus thread, onthisday, and settings. Read `ReviewLaunch.screen` once,
/// after onboarding, and open that screen. The parser stays here.
enum ReviewLaunch {
    static let argument = "-ReviewScreen"

    /// The key after `-ReviewScreen`, or nil on a normal launch.
    static var screen: String? {
        screen(in: ProcessInfo.processInfo.arguments)
    }

    /// Parses a launch-argument list. `screen` reads the process once.
    static func screen(in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: argument), index + 1 < arguments.count else {
            return nil
        }
        return arguments[index + 1]
    }
}
