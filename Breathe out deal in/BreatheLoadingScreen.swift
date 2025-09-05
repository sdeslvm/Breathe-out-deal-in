import SwiftUI

// MARK: - Протоколы для улучшения расширяемости

protocol ProgressDisplayable {
    var progressPercentage: Int { get }
}

protocol BackgroundProviding {
    associatedtype BackgroundContent: View
    func makeBackground() -> BackgroundContent
}

// MARK: - Необычный экран загрузки

struct BreatheLoadingOverlay: View, ProgressDisplayable {
    let progress: Double
    @State private var animate = false
    var progressPercentage: Int { Int(progress * 100) }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Новый фон
                Color(hex: "#D98CB2")
                    .ignoresSafeArea()
                    .overlay(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.18),
                                Color(hex: "#D98CB2").opacity(0.9),
                                Color(hex: "#D98CB2")
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: geo.size.width * 0.7
                        )
                    )

                VStack {
                    Spacer()
                    // Необычная анимация загрузки
                    BreatheNeonDotSpinner(progress: progress, animate: $animate)
                        .frame(width: geo.size.width * 0.36, height: geo.size.width * 0.36)
                        .padding(.bottom, 36)
                    // Прогресс и текст
                    VStack(spacing: 14) {
                        Text("Loading \(progressPercentage)%")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .purple.opacity(0.3), radius: 4, y: 2)
                        Text("Please wait...")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(18)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(Color.white.opacity(0.13))
                            .shadow(color: .purple.opacity(0.12), radius: 12, y: 4)
                    )
                    .padding(.bottom, geo.size.height * 0.18)
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .onAppear { animate = true }
        }
    }
}

// MARK: - Неоновый спиннер из точек

struct BreatheNeonDotSpinner: View {
    let progress: Double
    @Binding var animate: Bool

    private let dotCount = 12
    private let colors: [Color] = [
        Color(hex: "#00D4FF"),
        Color(hex: "#5B73FF"),
        Color(hex: "#9D50BB"),
        Color(hex: "#FF006E"),
        Color(hex: "#FBB034"),
        Color(hex: "#FFDD00"),
        Color(hex: "#00FFB4"),
        Color(hex: "#00D4FF"),
        Color(hex: "#5B73FF"),
        Color(hex: "#9D50BB"),
        Color(hex: "#FF006E"),
        Color(hex: "#FBB034"),
    ]

    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<dotCount, id: \.self) { i in
                let angle = Double(i) / Double(dotCount) * 2 * .pi
                let radius: CGFloat = 60
                let dotSize: CGFloat = 18 + (i == activeDotIndex ? 8 : 0)
                let color = colors[i % colors.count]
                let x = cos(angle) * radius
                let y = sin(angle) * radius

                Circle()
                    .fill(
                        RadialGradient(
                            gradient: Gradient(colors: [
                                color.opacity(0.95),
                                color.opacity(0.5),
                                Color.white.opacity(0.01)
                            ]),
                            center: .center,
                            startRadius: 0,
                            endRadius: dotSize * 1.2
                        )
                    )
                    .frame(width: dotSize, height: dotSize)
                    .shadow(color: color.opacity(0.7), radius: 8, y: 0)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.18), lineWidth: 1.5)
                            .frame(width: dotSize + 2, height: dotSize + 2)
                    )
                    .offset(x: x, y: y)
                    .scaleEffect(i == activeDotIndex ? 1.18 : 1.0)
                    .opacity(i == activeDotIndex ? 1.0 : 0.7)
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
        .onChange(of: animate) { value in
            if value {
                rotation = 0
                withAnimation(Animation.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
        }
    }

    private var activeDotIndex: Int {
        // Активная точка зависит от прогресса
        min(Int(round(progress * Double(dotCount - 1))), dotCount - 1)
    }
}

// MARK: - Фоновые представления

struct BreatheBackground: View, BackgroundProviding {
    func makeBackground() -> some View {
        Color(hex: "#D98CB2")
            .ignoresSafeArea()
    }

    var body: some View {
        makeBackground()
    }
}

// MARK: - Превью

#Preview("Vertical") {
    BreatheLoadingOverlay(progress: 0.2)
}

#Preview("Horizontal") {
    BreatheLoadingOverlay(progress: 0.2)
        .previewInterfaceOrientation(.landscapeRight)
}

// MARK: - Вспомогательный инициализатор цвета

//extension Color {
//    init(hex hexValue: String) {
//        let sanitizedHex = hexValue.trimmingCharacters(in: .whitespacesAndNewlines)
//            .replacingOccurrences(of: "#", with: "")
//        var colorValue: UInt64 = 0
//        Scanner(string: sanitizedHex).scanHexInt64(&colorValue)
//
//        self.init(
//            .sRGB,
//            red: Double((colorValue >> 16) & 0xFF) / 255.0,
//            green: Double((colorValue >> 8) & 0xFF) / 255.0,
//            blue: Double(colorValue & 0xFF) / 255.0,
//            opacity: 1.0
//        )
//    }
//}
