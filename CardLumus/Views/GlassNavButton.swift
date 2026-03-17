import UIKit

class GlassNavButton: UIButton {
    private let glassLayer = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterialDark))
    private let neonBorder = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        layer.cornerRadius = 12
        clipsToBounds = true
        
        glassLayer.isUserInteractionEnabled = false
        glassLayer.frame = bounds
        glassLayer.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(glassLayer, at: 0)
        
        neonBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
        neonBorder.fillColor = UIColor.clear.cgColor
        neonBorder.strokeColor = UIColor(hex: "#E0E0E0").cgColor
        neonBorder.lineWidth = 1.5
        neonBorder.shadowColor = UIColor.white.cgColor
        neonBorder.shadowRadius = 5
        neonBorder.shadowOpacity = 0.6
        layer.addSublayer(neonBorder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        neonBorder.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
    }
}
