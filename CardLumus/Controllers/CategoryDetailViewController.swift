import UIKit

class CategoryDetailViewController: UIViewController {
    
    let categoryName: String
    let categoryID: UUID
    
    private let backgroundView = NeonBackgroundView()

    private let chooseButton: GlassNavButton = {
            let btn = GlassNavButton(type: .system)
            btn.tintColor = .white
            return btn
        } ()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No words here yet..."
        label.textColor = .white.withAlphaComponent(0.4)
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    private var words: [Word] = []
    
    private let collectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.minimumLineSpacing = 12
            let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
            cv.backgroundColor = .clear
            return cv
        }()
    
    init(categoryID: UUID, categoryName: String) {
        self.categoryID = categoryID
        self.categoryName = categoryName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            backgroundView.animateBlobs()
            updateBackground()
        }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        updateBackground()
        setupUI()
        setupCollectionView()
        loadWords()
    }
    
    private func setupBackground() {
            backgroundView.frame = view.bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(backgroundView)
            view.sendSubviewToBack(backgroundView)
        }
    
    private func updateBackground(){
        backgroundView.applyTheme(forCount: words.count)
    }
    
    private func setupUI() {
        title = categoryName
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewWord)
        )
        
        chooseButton.setTitle("CHOOSE CATEGORY", for: .normal)
        chooseButton.addTarget(self, action: #selector(chooseCategoryTapped), for: .touchUpInside)
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(chooseButton)
        
        collectionView.dataSource = self
        // delegate нужен только если будешь обрабатывать нажатия (didSelectItemAt)
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "WordCell")
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            collectionView.bottomAnchor.constraint(equalTo: chooseButton.topAnchor, constant: -20),
            
            chooseButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            chooseButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            chooseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            chooseButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    private func setupCollectionView() {
        let config = UICollectionLayoutListConfiguration(appearance: .plain)
        
        let layout = UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var listConfig = config
            listConfig.backgroundColor = .clear
            listConfig.showsSeparators = false
            listConfig.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
                return self?.makeDeleteAction(for: indexPath)
            }
            
            let sectionLayout = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
            
            sectionLayout.interGroupSpacing = 10
            
            return sectionLayout
        }
        
        collectionView.collectionViewLayout = layout
    }
    
    private func makeDeleteAction(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            var allCategories = StorageManager.shared.load()
            
            if let categoryIndex = allCategories.firstIndex(where: { $0.id == self.categoryID }) {
                
                allCategories[categoryIndex].words.remove(at: indexPath.item)
                
                self.words = allCategories[categoryIndex].words
                
                StorageManager.shared.save(categories: allCategories)
                
                self.collectionView.deleteItems(at: [indexPath])
                self.updateBackground()
                
                completion(true)
            } else {
                completion(false)
            }
        }
        
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func loadWords() {
        let allCategories = StorageManager.shared.load()
        if let currentCategory = allCategories.first(where: { $0.id == categoryID }) {
            self.words = currentCategory.words
            collectionView.reloadData()
            
            let hasNoWords = words.isEmpty
            emptyLabel.isHidden = !hasNoWords
            collectionView.isHidden = hasNoWords
            
            chooseButton.isEnabled = !hasNoWords
            chooseButton.alpha = hasNoWords ? 0.5 : 1.0
            
            updateBackground()
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func addNewWord() {
        

        let addVC = AddWordViewController(categoryID: categoryID)
        
        if let sheet = addVC.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        
        addVC.onSave = { [weak self] term, trans in
            self?.loadWords()
            self?.updateBackground()
        }
        
        
        present(addVC, animated: true)
    }
    
    @objc private func chooseCategoryTapped() {
        UserDefaults.standard.set(categoryID.uuidString, forKey: "SelectedCategory")
        if let navigationController = self.navigationController {
            navigationController.popToRootViewController(animated: true)
        }
        
    }
}

extension CategoryDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WordCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let heightConstraint = cell.contentView.heightAnchor.constraint(equalToConstant: 80)
        heightConstraint.priority = .defaultHigh
        heightConstraint.isActive = true
        
        let theme = UIColor.colorForCount(words.count)

        let glass = UIVisualEffectView(effect: UIGlassEffect(style: .clear))
        glass.layer.cornerRadius = 15
        glass.clipsToBounds = true
        glass.layer.borderWidth = 1
        glass.layer.borderColor = theme.color1.withAlphaComponent(0.2).cgColor
        glass.translatesAutoresizingMaskIntoConstraints = false
        
        cell.contentView.addSubview(glass)

        NSLayoutConstraint.activate([
            glass.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            glass.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor),
            glass.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor),
            glass.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4)
        ])

        let gradientView = UIView()
        gradientView.translatesAutoresizingMaskIntoConstraints = false
        glass.contentView.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            gradientView.topAnchor.constraint(equalTo: glass.contentView.topAnchor),
            gradientView.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor),
            gradientView.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor),
            gradientView.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor)
        ])

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [theme.color1.withAlphaComponent(0.3).cgColor, theme.color2.withAlphaComponent(0.1).cgColor]
        gradientLayer.cornerRadius = 15
        gradientView.layer.addSublayer(gradientLayer)

        DispatchQueue.main.async {
            gradientLayer.frame = gradientView.bounds
        }

        let word = words[indexPath.item]
        let textStack = UIStackView()
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        textStack.translatesAutoresizingMaskIntoConstraints = false
        
        let mainLabel = UILabel()
        mainLabel.text = "\(word.term) — \(word.translation)"
        mainLabel.textColor = .white
        mainLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        
        let sentenceLabel = UILabel()
        sentenceLabel.text = word.sentence
        sentenceLabel.textColor = .white.withAlphaComponent(0.6)
        sentenceLabel.font = .systemFont(ofSize: 14, weight: .regular)
        
        textStack.addArrangedSubview(mainLabel)
        textStack.addArrangedSubview(sentenceLabel)
        
        glass.contentView.addSubview(textStack)
        
        NSLayoutConstraint.activate([
            textStack.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor, constant: 15),
            textStack.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor, constant: -15),
            textStack.centerYAnchor.constraint(equalTo: glass.contentView.centerYAnchor)
        ])
        
        return cell
    }
}
