//
//  Optionnal+Extensions.swift
//  SocialMap
//
//  Created by Arnaud Maillet on 07/10/2025.
//

extension Optional {
    func logFailure(_ message: @autoclosure () -> String) -> Wrapped? {
        if let value = self { return value }
        print("❌ \(message())")
        return nil
    }
}
