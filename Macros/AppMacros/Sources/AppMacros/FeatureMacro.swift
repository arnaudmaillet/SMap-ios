//
//  FeatureMacro.swift
//  AppMacros
//
//  Created by Arnaud Maillet on 19/10/2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct FeatureMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        guard let argumentList = node.argumentList,
              let featureName = argumentList.first?.expression.description else {
            throw MacroExpansionError(message: "@Feature(...) requiert un paramètre, ex: @Feature(PostNamespace)")
        }

        let decl: DeclSyntax = "typealias Feature = \(raw: featureName)"
        return [decl]
    }
}

struct MacroExpansionError: Error, CustomStringConvertible {
    var message: String
    var description: String { message }
}

@attached(member, names: arbitrary)
public macro Feature(_ feature: Any.Type) = #externalMacro(
    module: "MacrosPlugin",
    type: "FeatureMacro"
)
