//
//  debug.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/07/2025.
//

import Foundation

/// Fonction globale : unwrap + log automatique si nil
@discardableResult
func debugUnwrap<T>(
    _ expression: @autoclosure () -> T?,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> T? {
    let value = expression()
    #if DEBUG
    if value == nil {
        let fileName = (String(describing: file) as NSString).lastPathComponent
        let extra = message().isEmpty ? "" : " – \(message())"
        assertionFailure("❌ [\(fileName):\(line) → \(function)] '\(String(describing: expression()))' is nil\(extra)")
    }
    #endif
    return value
}
