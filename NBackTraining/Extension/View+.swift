import SwiftUI

struct RoundedRectangleBorderModifier<Style: ShapeStyle>: ViewModifier {
    var style: Style, width: CGFloat = 0, radius: CGFloat, background: Color

    func body(content: Content) -> some View {
        content
            .background(background)
            .overlay {
                RoundedRectangle(cornerRadius: radius)
                    .stroke(lineWidth: width*2)
                    .fill(style)
            }
            .mask {
                RoundedRectangle(cornerRadius: radius)
            }
            .shadow(radius: 5)
    }
}

struct CircleBorderModifier<Style: ShapeStyle>: ViewModifier {
    var style: Style, width: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay {
                Circle()
                    .stroke(lineWidth: width*2)
                    .fill(style)
            }
            .mask {
                Circle()
            }
    }
}


extension View {
    func roundedRectangleBorder<S: ShapeStyle>(
        _ style: S,
        width: CGFloat,
        radius: CGFloat,
        background: Color
    ) -> some View {
        let modifier = RoundedRectangleBorderModifier(
            style: style,
            width: width,
            radius: radius,
            background: background
        )
        return self.modifier(modifier)
    }

    func circleBorder<S: ShapeStyle>(
        _ style: S,
        width: CGFloat
    ) -> some View {
        let modifier = CircleBorderModifier(
            style: style,
            width: width
        )

        return self.modifier(modifier)
    }
}

struct BevelCircle: View {
    let buttonTitle: String
    let size: CGSize
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(.normal1))
                .frame(width: size.width, height: size.height)
                .shadow(
                    color: Color(.normal3),
                    radius: 0,
                    x: 0,
                    y: 5
                )
                .overlay(
                    Circle()
                        .stroke(Color(.normal1), lineWidth: 10)
                        .frame(width: 110, height: 110)
                        .offset(x: 0, y: 5)
                        .mask(
                            Circle()
                                .frame(width: 100, height: 100)
                        )
                )
                .overlay(
                    Circle()
                        .stroke(Color(.normal2), lineWidth: 10)
                        .frame(width: 110, height: 110)
                        .offset(x: 0, y: -5)
                        .mask(
                            Circle()
                                .frame(width: 100, height: 100)
                        )
                )
            Text(buttonTitle)
                .font(.system(size: 30, weight: .heavy))
                .foregroundColor(.white)
        }
    }
}

#Preview(body: {
    BevelCircle(buttonTitle: "A", size: .init(width: 100, height: 100))
})

