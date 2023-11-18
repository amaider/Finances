// 27.01.23, Swift 5.0, macOS 13.1, Xcode 12.4
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct View_Previews: PreviewProvider {
    static var previews: some View {
        HStack(content: {
            Button(action: {}, label: {
                HStack(spacing: 5, content: {
                    Text("Anhang hinzufügen...")
                        .opacity(0.5)
                })
            })
            .buttonStyle(.stealthDefault)
        })
        .padding()
    }
}

// MARK: ButtonStyle
struct StealthButtonStyle: ButtonStyle {
    let primary: Color
    let secondary: Color
    let edge: Edge.Set
    
    @Environment(\.isEnabled) var isEnabled
    @State private var isHovering: Bool = false
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .frame(minHeight: 0)
            .foregroundColor(configuration.isPressed ? primary : primary.opacity(0.5))
            .padding(edge, 3)
            .background(isHovering ? secondary : .clear)
            .cornerRadius(5.0)
            .opacity(isEnabled ? 1 : 0.2)
            .onHover(perform: { isHovering = $0 })
    }
}
extension ButtonStyle where Self == StealthButtonStyle {
    static var stealthDefault: StealthButtonStyle { StealthButtonStyle(primary: .white, secondary: .gray, edge: .all) }
    static func stealth(primary: Color = .white, secondary: Color = .gray, edge: Edge.Set = .all) -> StealthButtonStyle {
        StealthButtonStyle(primary: primary, secondary: secondary, edge: edge)
    }
}
struct ColorButtonStyle: ButtonStyle {
    let primary: Color
    let secondary: Color
    let highlighted: Bool
    let edge: Edge.Set
    
    @Environment(\.isEnabled) var isEnabled
    
    //    init(primary: Color = .gray, secondary: Color = .white, highlighted: Bool = false, edge: Edge.Set = .all) {
    //        self.primary = primary
    //        self.secondary = secondary
    //        self.highlighted = highlighted
    //        self.edge = edge
    //    }
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration
            .label
            .frame(minHeight: 0)
            .foregroundColor(configuration.isPressed || highlighted ? primary : secondary)
            .padding(edge, 3)
            .background(configuration.isPressed || highlighted ? secondary : primary.opacity(0.5))
            .cornerRadius(5.0)
            .overlay(
                RoundedRectangle(cornerRadius: 5.0)
                    .strokeBorder(primary, lineWidth: 1)
            )
            .opacity(isEnabled ? 1 : 0.2)
    }
}
extension ButtonStyle where Self == ColorButtonStyle {
    static var colorfulDefault: ColorButtonStyle { ColorButtonStyle(primary: .gray, secondary: .white, highlighted: false, edge: .all) }
    static func colorful(primary: Color = .gray, secondary: Color = .white, highlighted: Bool = false, edge: Edge.Set = .all) -> ColorButtonStyle {
        ColorButtonStyle(primary: primary, secondary: secondary, highlighted: highlighted, edge: edge)
    }
}

// MARK: Blur
#if os(macOS)
struct Blur: NSViewRepresentable {
    var allowsVibrancy: Bool = false
    
    func makeNSView(context: Context) -> some NSVisualEffectView {
        //        let blur = NSVisualEffectView()
        let blur: NSVisualEffectView = allowsVibrancy ? VibrantVisualEffectView() : NSVisualEffectView()
        blur.wantsLayer = true
        blur.blendingMode = .behindWindow
        blur.material = .hudWindow
        blur.state = .active
        blur.isEmphasized = false
        return blur
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {}
    
    private class VibrantVisualEffectView: NSVisualEffectView {
        override var allowsVibrancy: Bool { true }
    }
}
#else
struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
#endif

// MARK: View
extension View {
    func cardView(_ bgdColor: Color, padding: CGFloat = 5) -> some View {
        self
            .padding(padding)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [bgdColor.opacity(0.7), bgdColor.opacity(0.6)]),
                    startPoint: .top, endPoint: .bottomLeading
                )
            )
            .cornerRadius(5.0)
    }
    func cardViewH(_ bgdColor: Color, padding: CGFloat = 8) -> some View {
        self
            .padding(.horizontal, padding)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [bgdColor.opacity(0.7), bgdColor.opacity(0.6)]),
                    startPoint: .top, endPoint: .bottomLeading
                )
            )
            .cornerRadius(5.0)
    }
    
    /// Applies background to given `View` with invisible TextField to enable working focus for Buttons
    func focusedButton<Value>(_ binding: FocusState<Value>.Binding, equals value: Value) -> some View where Value : Hashable {
        self
            .background(
                TextField("", text: .constant(""))
                    .labelsHidden()
                    .focused(binding, equals: value)
                    .fixedSize()
                    .textFieldStyle(.plain)
                    .opacity(0)
            )
    }
    
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: TextField
extension TextField {
    func customStyle(_ alignment: TextAlignment = .leading) -> some View {
        self
            .labelsHidden()
            .multilineTextAlignment(alignment)
            .textFieldStyle(.plain)
            .fixedSize()
        //            .frame(minWidth: 100)
    }
}
struct CustomTextField: TextFieldStyle {
    let alignment: TextAlignment
    
    func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .labelsHidden()
            .multilineTextAlignment(alignment)
            .textFieldStyle(.plain)
            .fixedSize()
    }
}
extension TextFieldStyle where Self == CustomTextField {
    static var custom: CustomTextField { CustomTextField(alignment: .leading) }
    static func custom(_ alignment: TextAlignment) -> CustomTextField {
        CustomTextField(alignment: alignment)
    }
}

// MARK: Animations
extension Animation {
    static func ripple(index: Int) -> Animation {
        Animation.spring(dampingFraction: 0.5)
            .speed(2)
            .delay(0.1 * Double(index))
    }
}

#if os(iOS)
extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}
#endif


struct UI {
    static let dateSelectionPopoverMaxWidth: Double = 600
}
