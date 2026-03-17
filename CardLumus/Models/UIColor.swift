import UIKit

extension UIColor {
    convenience init(hex: String) {
        var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if (cString.hasPrefix("#")) { cString.remove(at: cString.startIndex) }
        
        if ((cString.count) != 6) {
            self.init(white: 0.5, alpha: 1.0)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static let l_bg = UIColor(hex: "#0B0E14")
    static let d_bg = UIColor(hex: "#000000")
    static let line_grad_color_1 =  UIColor(hex: "#E0E0E0")
    static let line_grad_color_2 =  UIColor(hex: "#FFFFFF")
    static let line_grad_color_1_success =  UIColor.systemGreen
    static let line_grad_color_2_success =  UIColor(hex: "#06B6D4")
    static let line_grad_color_1_failure =  UIColor.systemRed
    static let line_grad_color_2_failure =  UIColor(hex: "#9D174D")
    
    static public func interpolate(from: UIColor, to: UIColor, percent: CGFloat) -> UIColor {
        var fR: CGFloat = 0, fG: CGFloat = 0, fB: CGFloat = 0, fA: CGFloat = 0
        var tR: CGFloat = 0, tG: CGFloat = 0, tB: CGFloat = 0, tA: CGFloat = 0
        
        from.getRed(&fR, green: &fG, blue: &fB, alpha: &fA)
        to.getRed(&tR, green: &tG, blue: &tB, alpha: &tA)
        
        return UIColor(
            red: fR + (tR - fR) * percent,
            green: fG + (tG - fG) * percent,
            blue: fB + (tB - fB) * percent,
            alpha: fA + (tA - fA) * percent
        )
    }
    
    static func colorForCount(_ count: Int) -> (color1: UIColor, color2: UIColor) {
            switch count {
            case 0:
                return (.line_grad_color_1, .line_grad_color_2)
            case 1...5:
                return (.systemCyan, .systemBlue)
            case 6...10:
                return (.systemTeal, .systemGreen)
            case 11...15:
                return (.systemYellow, .systemPink)
            default:
                return (.systemOrange, .systemRed)
            }
        }
}
