//
//  debugUnwrap.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 23/07/2025.
//

import Foundation

/// Niveau de sévérité pour les logs générés par `debugUnwrap`.
///
/// - `.error` (par défaut) : Déclenche une `assertionFailure` si la valeur est `nil`.
/// - `.warning` : Affiche un simple log sans interrompre l'exécution.
enum DebugUnwrapLogLevel {
    case warning
    case error

    /// Préfixe emoji pour identifier le niveau dans les logs.
    var prefix: String {
        switch self {
        case .warning: return "⚠️"
        case .error: return "❌"
        }
    }
}

/// Déballe une valeur optionnelle et affiche un message en debug si elle est `nil`.
///
/// Cette fonction est utile pour vérifier qu'une variable censée être toujours présente l'est bien,
/// tout en fournissant un message d'erreur détaillé (fichier, fonction, ligne, et expression échouée).
///
/// - Important:
///    - En mode **DEBUG** :
///       - Si la valeur est `nil` et `level == .error` (par défaut), une **`assertionFailure`** est levée.
///       - Si la valeur est `nil` et `level == .warning`, un **log d'avertissement** est affiché sans interrompre l'exécution.
///    - En mode **RELEASE**, la fonction ne fait rien si la valeur est `nil`, et retourne simplement `nil`.
///
/// - Parameters:
///   - expression: L'expression à évaluer et à déballer. Grâce à `@autoclosure`, vous pouvez simplement passer la variable ou l'expression (ex: `container?.view`).
///   - message: Un message optionnel personnalisé à afficher en plus de l'expression (`""` par défaut).
///   - level: Le niveau de sévérité à appliquer si la valeur est `nil` (par défaut `.error`).
///   - file: Le nom du fichier appelant. Automatiquement rempli par `#file`.
///   - function: Le nom de la fonction appelante. Automatiquement rempli par `#function`.
///   - line: Le numéro de ligne de l'appel. Automatiquement rempli par `#line`.
///
/// - Returns: La valeur déballée si elle existe, sinon `nil`.
///
/// - Example:
/// ```swift
/// let container = debugUnwrap(container)
/// let view = debugUnwrap(container?.view, "Vue introuvable")
/// let optionalView = debugUnwrap(container?.view, "Vue introuvable", level: .warning)
/// ```
///
/// En cas d'erreur (par défaut) :
/// ```
/// ❌ [MyViewController.swift:42 → functionName()] 'container?.view' is nil – Vue introuvable
/// ```
///
/// En avertissement :
/// ```
/// ⚠️ [MyViewController.swift:42 → functionName()] 'container?.view' is nil – Vue introuvable
/// ```
@discardableResult
func debugUnwrap<T>(
    _ expression: @autoclosure () -> T?,
    _ message: @autoclosure () -> String = "",
    level: DebugUnwrapLogLevel = .error,
    file: StaticString = #file,
    function: StaticString = #function,
    line: UInt = #line
) -> T? {
    let value = expression()
    #if DEBUG
    if value == nil {
        let fileName = (String(describing: file) as NSString).lastPathComponent
        let extra = message().isEmpty ? "" : " – \(message())"
        let log = "\(level.prefix) [\(fileName):\(line) → \(function)] '\(String(describing: expression()))' is nil\(extra)"

        switch level {
        case .warning:
            print(log)
        case .error:
            assertionFailure(log)
        }
    }
    #endif
    return value
}
