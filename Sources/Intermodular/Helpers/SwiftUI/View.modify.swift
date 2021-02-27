//
// Copyright (c) Vatsal Manot
//

import SwiftUI

extension View {
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View>(
        @ViewBuilder transform: (Self) -> T
    ) -> some View {
        transform(self)
    }
    
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View>(
        if predicate: Bool,
        @ViewBuilder transform: (Self) -> T
    ) -> some View {
        if predicate {
            transform(self)
        } else {
            self
        }
    }
    
    /// Modifies the view based on a predicate.
    @ViewBuilder
    public func modify<T: View, U: Equatable>(
        if keyPath: KeyPath<EnvironmentValues, U>,
        equals comparate: U,
        @ViewBuilder transform: @escaping (Self) -> T
    ) -> some View {
        EnvironmentValueAccessView(keyPath) { value in
            if value == comparate {
                transform(self)
            } else {
                self
            }
        }
    }
}
