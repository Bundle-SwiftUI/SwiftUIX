//
// Copyright (c) Vatsal Manot
//

import Swift
import SwiftUI

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

/// A control that displays an editable text interface.
public struct TextView<Label: View>: View {
    private let label: Label
    
    @Binding private var text: String
    
    private var onEditingChanged: (Bool) -> Void
    private var onCommit: () -> Void
    
    public var body: some View {
        return ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            label.hidden(!text.isEmpty)
            
            _TextView(
                text: $text,
                onEditingChanged: onEditingChanged,
                onCommit: onCommit
            )
        }
    }
}

fileprivate struct _TextView {
    @Binding var text: String
    
    var onEditingChanged: (Bool) -> Void
    var onCommit: () -> Void
    
    init(
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

// MARK: - Extensions -

extension TextView where Label == Text {
    public init<S: StringProtocol>(
        _ title: S,
        text: Binding<String>,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = { }
    ) {
        self.label = Text(title).foregroundColor(.placeholderText)
        self._text = text
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
    }
}

#if os(iOS) || os(tvOS)

import UIKit

// MARK: - Protocol Implementations -

extension _TextView: UIViewRepresentable {
    typealias UIViewType = _UITextView
    
    class Coordinator: NSObject, UITextViewDelegate {
        var view: _TextView
        
        init(_ view: _TextView) {
            self.view = view
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            view.onEditingChanged(true)
        }
        
        func textViewDidChange(_ textView: UITextView) {
            view.text = textView.text
            
            view.onEditingChanged(true)
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            view.onEditingChanged(false)
            view.onCommit()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> _UITextView {
        let view = _UITextView()
        
        view.backgroundColor = nil
        view.isSelectable = true
        view.text = text
        
        if let font = context.environment.font {
            view.font = font.toUIFont()
        } else {
            view.font = .preferredFont(forTextStyle: .body)
        }
        
        view.textContainerInset = .zero
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateUIView(_ textView: _UITextView, context: Context) {
        if let font = context.environment.font, font.toUIFont() != textView.font {
            textView.font = font.toUIFont()
        }
        
        textView.text = text
    }
}

class _UITextView: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textContainerInset = .zero
        textContainer.lineFragmentPadding = 0
    }
}

#elseif canImport(AppKit)

import AppKit

extension _TextView: NSViewRepresentable {
    typealias NSViewType = _NSTextView
    
    class Coordinator: NSObject, NSTextViewDelegate {
        var view: _TextView
        
        init(_ view: _TextView) {
            self.view = view
        }
        
        func textDidBeginEditing(_ notification: Notification) {
            view.onEditingChanged(true)
        }
        
        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }
            
            view.text.wrappedValue = textView.string
            
            view.onEditingChanged(true)
        }
        
        func textDidEndEditing(_ notification: Notification) {
            view.onEditingChanged(true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeNSView(context: Context) -> NSViewType {
        let view = _NSTextView()
        
        view.backgroundColor = .clear
        view.string = text.wrappedValue
        view.textContainerInset = .zero
        view.delegate = context.coordinator
        
        return view
    }
    
    func updateNSView(_ textView: NSViewType, context: Context) {
        
    }
}

class _NSTextView: NSTextView {
    
}

#endif

#endif
