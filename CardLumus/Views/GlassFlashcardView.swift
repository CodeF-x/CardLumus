import UIKit

class GlassFlashcardView: UIView {
    
    private var effectView: UIVisualEffectView?
    var onSwipeProgress: ((CGFloat) -> Void)?
    enum SwipeDirection { case left, right }
    
    var onSwipe: ((SwipeDirection) -> Void)?
    
    private var isFlipped = false
    private var initialCenter: CGPoint = .zero
    
    private let glassContainer = UIView()
    private let titleLabel = UILabel()
    private let titleLabel_back = UILabel()
    private let vibrancyView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark), style: .label)
        return UIVisualEffectView(effect: vibrancyEffect)
    }()
    
    private let translationLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let backVibrancyView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark), style: .label)
        return UIVisualEffectView(effect: vibrancyEffect)
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupBackSide()
        setupConstraints()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBackSide() {
        translationLabel.translatesAutoresizingMaskIntoConstraints = false
        translationLabel.font = .systemFont(ofSize: 40, weight: .bold)
        translationLabel.textColor = .white
        translationLabel.textAlignment = .center
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = .systemFont(ofSize: 18, weight: .medium)
        descriptionLabel.textColor = .white.withAlphaComponent(0.8)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center
        
        titleLabel_back.translatesAutoresizingMaskIntoConstraints = false
        titleLabel_back.font = .systemFont(ofSize: 32, weight: .bold)
        titleLabel_back.textColor = .white
        titleLabel_back.textAlignment = .center
        
        backVibrancyView.translatesAutoresizingMaskIntoConstraints = false
        backVibrancyView.contentView.addSubview(translationLabel)
        backVibrancyView.contentView.addSubview(descriptionLabel)
        backVibrancyView.contentView.addSubview(titleLabel_back)
        
        glassContainer.addSubview(backVibrancyView)
        
        backVibrancyView.alpha = 0
        
        NSLayoutConstraint.activate([
            backVibrancyView.topAnchor.constraint(equalTo: glassContainer.topAnchor),
            backVibrancyView.leadingAnchor.constraint(equalTo: glassContainer.leadingAnchor, constant: 20),
            backVibrancyView.trailingAnchor.constraint(equalTo: glassContainer.trailingAnchor, constant: -20),
            backVibrancyView.bottomAnchor.constraint(equalTo: glassContainer.bottomAnchor),
            
            titleLabel_back.topAnchor.constraint(equalTo: backVibrancyView.contentView.topAnchor, constant: 40),
                titleLabel_back.centerXAnchor.constraint(equalTo: backVibrancyView.contentView.centerXAnchor),
                titleLabel_back.leadingAnchor.constraint(equalTo: backVibrancyView.contentView.leadingAnchor, constant: 20),
                titleLabel_back.trailingAnchor.constraint(equalTo: backVibrancyView.contentView.trailingAnchor, constant: -20),

                translationLabel.centerYAnchor.constraint(equalTo: backVibrancyView.contentView.centerYAnchor, constant: -10),
                translationLabel.centerXAnchor.constraint(equalTo: backVibrancyView.contentView.centerXAnchor),
                
                descriptionLabel.topAnchor.constraint(equalTo: translationLabel.bottomAnchor, constant: 15),
                descriptionLabel.leadingAnchor.constraint(equalTo: backVibrancyView.contentView.leadingAnchor),
                descriptionLabel.trailingAnchor.constraint(equalTo: backVibrancyView.contentView.trailingAnchor)
        ])
    }
    
    private func setupGesture() {
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
            self.addGestureRecognizer(tap)
        
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            self.addGestureRecognizer(pan)
        }
    
    @objc private func handleTap() {
            flipCard()
        }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        
        switch gesture.state {
        case .began:
            initialCenter = self.center
            
        case .changed:
            
            let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
            self.center = newCenter
            
            let rotationAngle = (translation.x / (superview?.frame.width ?? 300)) * 0.4
            self.transform = CGAffineTransform(rotationAngle: rotationAngle)
            
            self.onSwipeProgress?(translation.x)
            self.updateGlassTint(xOffset: translation.x)
            
            
        case .ended:
            
            if translation.x > 120 {
                finishSwipe(direction: .right)
            } else if translation.x < -120 {
                finishSwipe(direction: .left)
            } else {
                resetGlassTint()
                resetPosition()
            }
            
            
        default:
            break
        }
    }
    
    private func resetPosition() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [], animations: {
            self.center = self.initialCenter
            self.transform = .identity
            self.glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
                self.glassContainer.layer.shadowOpacity = 0
            self.onSwipeProgress?(0)
        })
    }

    private func finishSwipe(direction: SwipeDirection) {
        let xTranslation: CGFloat = direction == .right ? 500 : -500
        UIView.animate(withDuration: 0.3, animations: {
            self.center.x += xTranslation
            self.alpha = 0
        }) { _ in
            self.onSwipe?(direction)
            self.resetPosition()
            self.resetGlassTint()
            self.alpha = 1
            print("Swiped \(direction)")
        }
    }

    
    
    private func flipCard() {
        isFlipped.toggle()

        let transitionOptions: UIView.AnimationOptions = isFlipped ? .transitionFlipFromRight : .transitionFlipFromLeft
        
        UIView.transition(with: glassContainer, duration: 0.6, options: transitionOptions, animations: {
            self.vibrancyView.alpha = self.isFlipped ? 0 : 1
            self.backVibrancyView.alpha = self.isFlipped ? 1 : 0
        }, completion: nil)
    }

    
    private func updateGlassTint(xOffset: CGFloat) {
        let threshold: CGFloat = 150
        let percentage = min(abs(xOffset) / threshold, 1.0)

        let baseColor = UIColor.line_grad_color_1.withAlphaComponent(0.1)

        let targetColor = xOffset > 0 ? UIColor.systemGreen : UIColor.systemRed
        let targetWithAlpha = targetColor.withAlphaComponent(0.15) 
        let interpolatedColor = UIColor.interpolate(from: baseColor, to: targetWithAlpha, percent: percentage)
        
        let newGlassEffect = UIGlassEffect(style: .clear)
        newGlassEffect.tintColor = interpolatedColor
        
        if let effectView = glassContainer.subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView {
            effectView.effect = newGlassEffect
        }
        
    }
    
    private func resetGlassTint() {
        let baseColor = UIColor.line_grad_color_1.withAlphaComponent(0.1)
        
        let newGlassEffect = UIGlassEffect(style: .clear)
        newGlassEffect.tintColor = baseColor
        if let effectView = glassContainer.subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView {
            effectView.effect = newGlassEffect
        }
        
    }
    
    private func setupView() {
        glassContainer.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.layer.cornerRadius = AppConstants.glassRadius
        glassContainer.clipsToBounds = true
        glassContainer.layer.borderWidth = 1.0
        glassContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.15).cgColor
        addSubview(glassContainer)
        
        let glassEffect = UIGlassEffect(style: .clear)
        glassEffect.isInteractive = true
        glassEffect.tintColor = UIColor.line_grad_color_1.withAlphaComponent(0.1)
        
        let effectView = UIVisualEffectView(effect: glassEffect)
        effectView.frame = glassContainer.bounds
        effectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        glassContainer.addSubview(effectView)
        
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 50, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.textAlignment = .center
        
        vibrancyView.contentView.addSubview(titleLabel)
        glassContainer.addSubview(vibrancyView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            glassContainer.topAnchor.constraint(equalTo: topAnchor),
            glassContainer.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            glassContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            vibrancyView.centerXAnchor.constraint(equalTo: glassContainer.centerXAnchor),
            vibrancyView.centerYAnchor.constraint(equalTo: glassContainer.centerYAnchor),
            vibrancyView.widthAnchor.constraint(equalTo: glassContainer.widthAnchor),
            vibrancyView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.centerXAnchor.constraint(equalTo: vibrancyView.contentView.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: vibrancyView.contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: vibrancyView.contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: vibrancyView.contentView.trailingAnchor, constant: -20)
        ])
    }
    
    func configure(with title: String, translation: String, description: String) {
        titleLabel.text = title
        titleLabel_back.text = title
        translationLabel.text = translation
        descriptionLabel.text = description
        
        if isFlipped {
            flipCard()
        }
    }
}
