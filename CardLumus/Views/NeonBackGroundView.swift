import UIKit

class NeonBackgroundView: UIView {
    
    private let neonGlowLayer = CAGradientLayer()
    private let purpleBlob = UIView()
    private let peachBlob = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBackground()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupBackground()
    }
    
    private func setupBackground() {
        let backgroundGradient = CAGradientLayer()
        backgroundGradient.frame = UIScreen.main.bounds
        backgroundGradient.colors = [UIColor.l_bg.cgColor, UIColor.d_bg.cgColor]
        backgroundGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backgroundGradient.endPoint = CGPoint(x: 0.5, y: 1)
        layer.insertSublayer(backgroundGradient, at: 0)
        
        let blobsContainer = UIView(frame: UIScreen.main.bounds)
        addSubview(blobsContainer)
        
        setupBlob(purpleBlob, color: .line_grad_color_1, frame: CGRect(x: -50, y: 150, width: 300, height: 300))
        setupBlob(peachBlob, color: .line_grad_color_2, frame: CGRect(x: UIScreen.main.bounds.width - 200, y: 450, width: 350, height: 350))
        
        blobsContainer.addSubview(purpleBlob)
        blobsContainer.addSubview(peachBlob)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        blurView.frame = UIScreen.main.bounds
        blurView.alpha = 0.9
        blobsContainer.addSubview(blurView)
        
        setupNeonGlowLayer()
    }
    
    private func setupBlob(_ blob: UIView, color: UIColor, frame: CGRect) {
        blob.frame = frame
        blob.backgroundColor = color.withAlphaComponent(0.6)
        blob.layer.cornerRadius = frame.width / 2
        blob.layer.shadowColor = color.cgColor
        blob.layer.shadowOpacity = 1.0
        blob.layer.shadowRadius = 120
        blob.layer.shadowOffset = .zero
    }
    
    
    private func setupNeonGlowLayer() {
        neonGlowLayer.colors = [
            UIColor.line_grad_color_1.cgColor,
            UIColor.line_grad_color_2.cgColor,
            UIColor.line_grad_color_2.cgColor,
            UIColor.line_grad_color_1.cgColor
        ]
        neonGlowLayer.type = .conic
        neonGlowLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        neonGlowLayer.endPoint = CGPoint(x: 1, y: 1)
        neonGlowLayer.locations = [0.0, 0.4, 0.6, 1.0]
        neonGlowLayer.shadowColor = UIColor.line_grad_color_1.cgColor
        neonGlowLayer.shadowOpacity = 1.0
        neonGlowLayer.shadowRadius = 15
        
        layer.addSublayer(neonGlowLayer)
        
        let mask = CAShapeLayer()
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.black.cgColor
        mask.lineWidth = 2.5
        mask.lineCap = .round
        neonGlowLayer.mask = mask
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        neonGlowLayer.frame = bounds
        
        let screen = window?.windowScene?.screen
        let displayCornerRadius = screen?.value(forKey: "_displayCornerRadius") as? CGFloat ?? 0
        let path = UIBezierPath(roundedRect: bounds.insetBy(dx: 1.5, dy: 1.5), cornerRadius: displayCornerRadius)
        
        if let mask = neonGlowLayer.mask as? CAShapeLayer {
            mask.path = path.cgPath
        }
    }
    
    func animateBlobs() {
        UIView.animate(withDuration: 10.0, delay: 0, options: [.autoreverse, .repeat, .curveEaseInOut]) {
            self.purpleBlob.transform = CGAffineTransform(translationX: 40, y: -40).scaledBy(x: 1.1, y: 1.1)
            self.peachBlob.transform = CGAffineTransform(translationX: -40, y: 40).scaledBy(x: 0.9, y: 0.9)
        }
    }
    
    func updateNeonColor(targetColor1: UIColor, targetColor2: UIColor, percentage: CGFloat) {
        let newColors = [
            UIColor.interpolate(from: .line_grad_color_1, to: targetColor1, percent: percentage).cgColor,
            UIColor.interpolate(from: .line_grad_color_2, to: targetColor2, percent: percentage).cgColor,
            UIColor.interpolate(from: .line_grad_color_2, to: targetColor2, percent: percentage).cgColor,
            UIColor.interpolate(from: .line_grad_color_1, to: targetColor1, percent: percentage).cgColor
        ]
        
        self.purpleBlob.backgroundColor = UIColor.interpolate(from: UIColor.line_grad_color_1, to: targetColor1, percent: percentage)
        self.peachBlob.backgroundColor = UIColor.interpolate(from: UIColor.line_grad_color_2, to: targetColor2, percent: percentage)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        neonGlowLayer.colors = newColors
        neonGlowLayer.shadowColor = targetColor1.cgColor
        neonGlowLayer.shadowOpacity = Float(percentage)
        CATransaction.commit()
    }
    
    func applyTheme(forCount count: Int) {
            let theme = UIColor.colorForCount(count)
            
            UIView.animate(withDuration: 1.0) {
                self.purpleBlob.backgroundColor = theme.color1.withAlphaComponent(0.6)
                self.purpleBlob.layer.shadowColor = theme.color1.cgColor
                
                self.peachBlob.backgroundColor = theme.color2.withAlphaComponent(0.6)
                self.peachBlob.layer.shadowColor = theme.color2.cgColor
                
                self.neonGlowLayer.colors = [
                    theme.color1.cgColor,
                    theme.color2.cgColor,
                    theme.color2.cgColor,
                    theme.color1.cgColor
                ]
                self.neonGlowLayer.shadowColor = theme.color1.cgColor
            }
        }
}
