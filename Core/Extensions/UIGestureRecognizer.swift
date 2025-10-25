//
//  UIGestureRecognizer.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 22/07/2025.
//

import UIKit

extension UIGestureRecognizer {
    /// Essaie de caster le gesture en `UIPanGestureRecognizer`, sinon déclenche une `assertionFailure` en debug.
    ///
    /// - Parameters:
    ///   - message: Message d'erreur personnalisé.
    ///   - file: Fichier appelant (par défaut automatiquement rempli).
    ///   - function: Fonction appelante (par défaut automatiquement rempli).
    ///   - line: Ligne appelante (par défaut automatiquement rempli).
    /// - Returns: Le gesture casté en `UIPanGestureRecognizer`, ou `nil` si le cast échoue.
    func debugCast<T>(
        to type: T.Type,
        _ message: @autoclosure () -> String,
        file: StaticString = #file,
        function: StaticString = #function,
        line: UInt = #line
    ) -> T? {
        if let result = self as? T {
            return result
        } else {
            #if DEBUG
            let fileName = (String(describing: file) as NSString).lastPathComponent
            assertionFailure("❌ [\(fileName):\(line) → \(function)] \(message())")
            #endif
            return nil
        }
    }
}
