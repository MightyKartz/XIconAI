//
//  View+Compat.swift
//  Icons
//
//  Centralized SwiftUI compatibility helpers for cross-macOS/iOS support
//

import SwiftUI

// MARK: - onChange 兼容封装（macOS 13/14 差异）
// SwiftUI 在 macOS 14 引入了新的重载 onChange(of:initial:_:)；
// 为了兼容 macOS 13，这里提供一个统一入口，内部根据系统版本选择合适实现。
public extension View {
    @ViewBuilder
    func onChangeCompat<T: Equatable>(of value: T, perform action: @escaping (T) -> Void) -> some View {
        if #available(macOS 14.0, *) {
            self.onChange(of: value) { newValue in
                action(newValue)
            }
        } else {
            self.onChange(of: value, perform: action)
        }
    }
}