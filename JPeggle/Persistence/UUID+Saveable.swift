import Foundation

extension UUID: Saveable {}

extension Array: Saveable where Element: Saveable {}
