import SwiftUI

extension Color {
    init(hexString: String) {
        let hex = hexString.replacingOccurrences(of: "0x", with: "")
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

struct VisirColorScheme {
    private static let lightColors = (
        isDarkMode: false,
        background: Color(hexString: "0xFFFFFFFF"),
        onBackground: Color(hexString: "0xFF000000"),
        outline: Color(hexString: "0xFFEBEBED"),
        shadow: Color(hexString: "0xFF3A3A3C"),
        onInverseSurface: Color(hexString: "0xff48484A"),
        surfaceTint: Color(hexString: "0xFF8E8E91"),
        primary: Color(hexString: "0xff7C5DFF"),
        secondary: Color(hexString: "0xff5d85ff"),
        error: Color(hexString: "0xffff5d5d"),
        tertiary: Color(hexString: "0xff7b86c4"),
    )
    
    private static let darkColors = (
        isDarkMode: true,
        background: Color(hexString: "0xFF1E1E1E"),
        onBackground: Color(hexString: "0xFFFFFFFF"),
        outline: Color(hexString: "0xFF2C2C2E"),
        shadow: Color(hexString: "0xffDBDBE0"),
        onInverseSurface: Color(hexString: "0xffBDBDC2"),
        surfaceTint: Color(hexString: "0xFF636366"),
        primary: Color(hexString: "0xff7C5DFF"),
        secondary: Color(hexString: "0xff5d85ff"),
        error: Color(hexString: "0xffff5d5d"),
        tertiary: Color(hexString: "0xff7b86c4"),
    )
    
    static func getColor(for colorScheme: ColorScheme) -> (isDarkMode: Bool, background: Color, onBackground: Color, outline: Color, shadow: Color, onInverseSurface: Color, surfaceTint: Color, primary: Color, secondary: Color, error: Color, tertiary: Color) {
        let defaults = UserDefaults(suiteName: "group.com.wavetogether.fillin")
        let themeMode = defaults?.string(forKey: "themeMode") ?? "system"
        
        switch themeMode {
        case "light":
            return lightColors
        case "dark":
            return darkColors
        default: // system
            switch colorScheme {
            case .dark:
                return darkColors
            default:
                return lightColors
            }
        }
    }
} 