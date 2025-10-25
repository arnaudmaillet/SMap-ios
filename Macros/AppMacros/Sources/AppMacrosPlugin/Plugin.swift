//
//  Plugin.swift
//  AppMacros
//
//  Created by Arnaud Maillet on 19/10/2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        FeatureMacro.self
    ]
}
