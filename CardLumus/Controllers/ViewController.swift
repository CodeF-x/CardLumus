import UIKit

enum AppConstants {
    static let spacing: CGFloat = 12
    static let glassRadius: CGFloat = 25
    static let buttonHeight: CGFloat = 56
    static let sidePadding: CGFloat = 20
}

class MainPageViewController: UIViewController {
    
    private let backgroundView = NeonBackgroundView()
    private let neonGlowLayer = CAGradientLayer()
    private let mainContentStack = UIStackView()
    private let flashcard = GlassFlashcardView()
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Select Category"
        label.numberOfLines = 1
        return label
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Create new Category\nto start learning"
        label.textColor = .white.withAlphaComponent(0.5)
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let progressBar: UIProgressView = {
        let progress = UIProgressView(progressViewStyle: .default)
        progress.trackTintColor = .white.withAlphaComponent(0.1)
        progress.progressTintColor = UIColor.line_grad_color_1
        progress.layer.cornerRadius = 4
        progress.clipsToBounds = true
        return progress
    }()
    
    private var words: [Word] = []
    private var currentIndex: Int = 0
    private var correctAnswers: Int = 0
    
    private let categoryButton: GlassNavButton = {
        let btn = GlassNavButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.tintColor = .white
        return btn
    }()
    
    private let bottomStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .fillEqually
        return stack
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = .dark
        }
        
        view.addSubview(emptyStateLabel)
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        setupBackground()
        configureUI()
    }
    
    private func setupBackground() {
            backgroundView.frame = view.bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(backgroundView)
            view.sendSubviewToBack(backgroundView)
        }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let allCategories = StorageManager.shared.load()
        
        if allCategories.isEmpty {
            showEmptyState(message: "Create new Category\nto start learning")
            return
        }

        guard let selectedIDString = UserDefaults.standard.string(forKey: "SelectedCategory"),
              let selectedID = UUID(uuidString: selectedIDString),
              let activeCategory = allCategories.first(where: { $0.id == selectedID }) else {
            
            showEmptyState(message: "Choose Category\nto start learning")
            return
        }

        if activeCategory.words.isEmpty {
            showEmptyState(message: "No words in this Category.")
            return
        }

        hideEmptyState()
        setupSession(with: activeCategory)
    }
    
    private func setupSession(with category: Category) {
        self.words = category.words.shuffled()
        self.currentIndex = 0
        self.correctAnswers = 0
        
        UIView.transition(with: categoryTitleLabel, duration: 0.3, options: .transitionCrossDissolve) {
            self.categoryTitleLabel.text = category.name.uppercased()
        }
        
        updateProgress()
        updateCardContent()
    }

    private func showEmptyState(message: String) {
        emptyStateLabel.text = message
        emptyStateLabel.isHidden = false
        
        flashcard.isHidden = true
        progressBar.isHidden = true
        categoryTitleLabel.text = "EMPTY"
    }

    private func hideEmptyState() {
        emptyStateLabel.isHidden = true
        flashcard.isHidden = false
        progressBar.isHidden = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            backgroundView.animateBlobs()
        }

    private func configureUI() {
        congigeureMainStack()
        mainContentStack.addArrangedSubview(categoryTitleLabel)
        mainContentStack.addArrangedSubview(progressBar)
        mainContentStack.addArrangedSubview(flashcard)
        configureFlashCard()
        mainContentStack.addArrangedSubview(UIView())
        setupBottomButtons()
        
        mainContentStack.setCustomSpacing(10, after: categoryTitleLabel)
        mainContentStack.setCustomSpacing(25, after: progressBar)
        NSLayoutConstraint.activate([
                progressBar.widthAnchor.constraint(equalTo: mainContentStack.widthAnchor, constant: -AppConstants.sidePadding * 2),
                progressBar.heightAnchor.constraint(equalToConstant: 8)
            ])
        }
    
    private func checkCategories() {
        let categories = StorageManager.shared.load()
        if categories.isEmpty {
            emptyStateLabel.isHidden = false
            flashcard.isHidden = true
        } else {
            emptyStateLabel.isHidden = true
            flashcard.isHidden = false
        }
    }
    
    private func showNextWord(wasCorrect: Bool) {
        if wasCorrect {
            correctAnswers += 1
        }
        
        currentIndex += 1
        updateProgress()
        
        if currentIndex < words.count {
            updateCardContent()
        } else {
            showResults()
        }
    }

    private func updateCardContent() {
        
        let word = words[currentIndex]
        flashcard.configure(with: word.term,
                            translation: word.translation,
                            description: word.sentence)
        
    }
    
    private func updateProgress() {
        progressBar.layer.shadowColor = UIColor.systemCyan.cgColor
        progressBar.layer.shadowRadius = 10
        progressBar.layer.shadowOpacity = currentIndex > 0 ? 0.8 : 0
        
        guard !words.isEmpty else {
            progressBar.setProgress(0, animated: false)
            return
        }
        
        let progress = Float(currentIndex) / Float(words.count)
        progressBar.setProgress(progress, animated: true)
    }
    
    
    private func showResults() {
        let alert = UIAlertController(
            title: "Session Finished!",
            message: "You learned \(correctAnswers) out of \(words.count) words!",
            preferredStyle: .alert
        )
        
        let restartAction = UIAlertAction(title: "Try Again", style: .default) { _ in
            self.restartSession()
        }
        
        alert.addAction(restartAction)
        present(alert, animated: true)
    }
    

    private func restartSession() {
        currentIndex = 0
        correctAnswers = 0
        words.shuffle()
        updateCardContent()
        updateProgress()
    }
    
    private func setupBottomButtons() {
        view.addSubview(bottomStack)
        bottomStack.translatesAutoresizingMaskIntoConstraints = false
        
        bottomStack.addArrangedSubview(categoryButton)
        
        NSLayoutConstraint.activate([
            bottomStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: AppConstants.sidePadding),
            bottomStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -AppConstants.sidePadding),
            bottomStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            
            categoryButton.heightAnchor.constraint(equalToConstant: AppConstants.buttonHeight)
        ])
        
        categoryButton.addTarget(self, action: #selector(didTapCategories), for: .touchUpInside)
        categoryButton.setTitle("CHOOSE CATEGORY", for: .normal)
    }
    
    @objc private func didTapCategories() {

        let foldersVC = FoldersViewController()
        self.navigationController?.pushViewController(foldersVC, animated: true)
    }
    
    
    private func configureFlashCard() {
        
        flashcard.configure(
            with: "Let's start?",
            translation: "Swipe to start",
            description: "Left swipes for incorrect answers and right - for correct ones."
        )
        
        flashcard.onSwipe = { [weak self] direction in
            guard let self = self else { return }
            
            switch direction {
            case .right:
                self.showNextWord(wasCorrect: true)
            case .left:
                self.showNextWord(wasCorrect: false)
            }
        }
        
        NSLayoutConstraint.activate([
            flashcard.heightAnchor.constraint(equalToConstant: 380),
            flashcard.widthAnchor.constraint(equalTo: mainContentStack.widthAnchor, constant: -AppConstants.sidePadding * 2)
        ])
        
        flashcard.onSwipeProgress = { [weak self] xOffset in
            guard let self = self else { return }
            
            let threshold: CGFloat = 150
            let percentage = min(abs(xOffset) / threshold, 1.0)
            var target1 = UIColor.line_grad_color_1.withAlphaComponent(0.6)
            var target2 = UIColor.line_grad_color_2.withAlphaComponent(0.6)
            
            if xOffset < 0 {
                target1 = UIColor.line_grad_color_1_failure.withAlphaComponent(0.6)
                target2 = UIColor.line_grad_color_2_failure.withAlphaComponent(0.6)
            } else if xOffset > 0 {
                target1 = UIColor.line_grad_color_1_success.withAlphaComponent(0.6)
                target2 = UIColor.line_grad_color_2_success.withAlphaComponent(0.6)
            }
            
            backgroundView.updateNeonColor(targetColor1: target1, targetColor2: target2, percentage: percentage)
        }
    }
    
    private func congigeureMainStack() {
        mainContentStack.translatesAutoresizingMaskIntoConstraints = false
        mainContentStack.axis = .vertical
        mainContentStack.spacing = 30
        mainContentStack.alignment = .center
        mainContentStack.distribution = .fill
        mainContentStack.isLayoutMarginsRelativeArrangement = true
        mainContentStack.layoutMargins = UIEdgeInsets(top: 40, left: AppConstants.sidePadding, bottom: 40, right: AppConstants.sidePadding)
        view.addSubview(mainContentStack)
        
        NSLayoutConstraint.activate([
            mainContentStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainContentStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainContentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainContentStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}
