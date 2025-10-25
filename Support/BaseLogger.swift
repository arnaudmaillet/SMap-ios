//
//  BaseLogger.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 21/10/2025.
//

import Foundation
import os.log

/// Logger général pour tout usage transversal
enum Logger {

    enum Level: String {
        case debug = "💬 DEBUG"
        case info = "ℹ️ INFO"
        case warn = "⚠️ WARNING"
        case error = "❌ ERROR"
        case critical = "🔥 CRITICAL"

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warn: return .default
            case .error: return .error
            case .critical: return .fault
            }
        }

        var color: String {
            switch self {
            case .debug: return "\u{001B}[0;37m"
            case .info: return "\u{001B}[0;36m"
            case .warn: return "\u{001B}[0;33m"
            case .error: return "\u{001B}[0;31m"
            case .critical: return "\u{001B}[0;35m"
            }
        }

        var emoji: String {
            switch self {
            case .debug: return "💬"
            case .info: return "ℹ️"
            case .warn: return "⚠️"
            case .error: return "❌"
            case .critical: return "🔥"
            }
        }
    }

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.socialmap.app"
    private static let oslog = OSLog(subsystem: subsystem, category: "AppLogger")

    static func log(_ message: String,
                    level: Level = .debug,
                    file: String = #file,
                    function: String = #function,
                    line: Int = #line) {

        #if DEBUG
        let fileName = (file as NSString).lastPathComponent
        let timestamp = formattedTimestamp()
        let thread = Thread.isMainThread ? "Main" : "Background"
        let formatted = """
        \(level.color)\(level.emoji) [\(timestamp)] [\(thread)] [\(fileName):\(line)] \(function) → \(message)\u{001B}[0m
        """
        print(formatted)
        #else
        os_log("%{public}@", log: oslog, type: level.osLogType, message)

        if level == .error || level == .critical {
            // Crashlytics.log(message)
            // Sentry.capture(message)
        }
        #endif
    }

    // Shorthands
    static func debug(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(msg, level: .debug, file: file, function: function, line: line)
    }

    static func info(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(msg, level: .info, file: file, function: function, line: line)
    }

    static func warn(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(msg, level: .warn, file: file, function: function, line: line)
    }

    static func error(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(msg, level: .error, file: file, function: function, line: line)
    }

    static func critical(_ msg: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(msg, level: .critical, file: file, function: function, line: line)
    }

    private static func formattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
