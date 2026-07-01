import SwiftUI

enum AppTheme {
    static let background  = Color(red: 26/255.0, green: 15/255.0, blue: 18/255.0)
    static let surface     = Color(red: 43/255.0, green: 22/255.0, blue: 27/255.0)
    static let accent      = Color(red: 212/255.0, green: 175/255.0, blue: 55/255.0)
    static let label       = Color(red: 242/255.0, green: 233/255.0, blue: 220/255.0)
    static let sublabel    = Color(red: 155/255.0, green: 136/255.0, blue: 117/255.0)
    static let positive    = Color(red: 122/255.0, green: 175/255.0, blue: 122/255.0)
    static let negative    = Color(red: 179/255.0, green: 58/255.0, blue: 58/255.0)
    static let edge        = Color.primary.opacity(0.08)

    static let corner: CGFloat      = 6
    static let cornerSmall: CGFloat = 4
    static let cornerLarge: CGFloat = 14

    static func display(_ size: CGFloat) -> Font  { .system(size: size, weight: .bold,      design: .default) }
    static func heading(_ size: CGFloat) -> Font  { .system(size: size, weight: .semibold,  design: .default) }
    static func body(_ size: CGFloat) -> Font     { .system(size: size, weight: .regular,   design: .default) }
    static func caption(_ size: CGFloat) -> Font  { .system(size: size, weight: .medium,    design: .default) }
    static func mono(_ size: CGFloat) -> Font     { .system(size: size, weight: .regular,   design: .monospaced) }
}
