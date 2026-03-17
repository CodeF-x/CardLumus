import UIKit

class FoldersViewController: UIViewController {
    
    private let backgroundView = NeonBackgroundView()
    private let mainContentStack = UIStackView()
    
    private var categories: [Category] = []
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        return cv
    }()
    
    private let addCategoryField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Enter new category..."
        tf.textColor = .white
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tf.layer.cornerRadius = 12
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftViewMode = .always
        return tf
    }()
    private let addButton: GlassNavButton = {
        let btn = GlassNavButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        btn.tintColor = .white
        return btn
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        categories = StorageManager.shared.load()
        collectionView.reloadData()
        setupBackground()
        configureUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            backgroundView.animateBlobs()
        }
    
    private func setupBackground() {
            backgroundView.frame = view.bounds
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(backgroundView)
            view.sendSubviewToBack(backgroundView)
        }

    private func configureUI() {
        congigeureMainStack()
        setupNavigationBarTitle()
        
        setupCollectionView()
        mainContentStack.addArrangedSubview(collectionView)
        
        mainContentStack.addArrangedSubview(addCategoryField)
        
        addButton.setTitle("ADD CATEGORY", for: .normal)
        addButton.addTarget(self, action: #selector(handleAddCategory), for: .touchUpInside)
        mainContentStack.addArrangedSubview(addButton)
        
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: 450),
            addCategoryField.heightAnchor.constraint(equalToConstant: 50),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupNavigationBarTitle() {
        let headerLabel = UILabel()
        headerLabel.text = "My Categories"
        headerLabel.font = .systemFont(ofSize: 28, weight: .bold)
        headerLabel.textColor = .white
        headerLabel.textAlignment = .left
        
        let container = UIView()
        container.addSubview(headerLabel)
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 0),
            headerLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor)
        ])
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.titleView = container
    }
    
  
    
    private func congigeureMainStack() {
        mainContentStack.translatesAutoresizingMaskIntoConstraints = false
        mainContentStack.axis = .vertical
        mainContentStack.spacing = 30
        mainContentStack.distribution = .fill
        mainContentStack.alignment = .fill
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


    private func setupCollectionView() {
        var config = UICollectionLayoutListConfiguration(appearance: .plain)
        config.backgroundColor = .clear
        config.showsSeparators = false
        
        config.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            return self?.collectionView(self!.collectionView, trailingSwipeActionsConfigurationForItemAt: indexPath)
        }

        let layout = UICollectionViewCompositionalLayout { section, layoutEnvironment in
            let listConfig = config
            let sectionLayout = NSCollectionLayoutSection.list(using: listConfig, layoutEnvironment: layoutEnvironment)
            sectionLayout.interGroupSpacing = 30
            return sectionLayout
        }
        
        collectionView.collectionViewLayout = layout
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "FolderCell")
    }
    

    @objc private func handleAddCategory() {
        guard let text = addCategoryField.text, !text.isEmpty else { return }
        
        let newCategory = Category(id: UUID(), name: text, words: [])
        
        categories.append(newCategory)
        
        StorageManager.shared.save(categories: categories)
        
        addCategoryField.text = ""
        collectionView.reloadData()
        addCategoryField.resignFirstResponder()
    }
    }

extension FoldersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FolderCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let category = categories[indexPath.item]
        let theme = UIColor.colorForCount(category.words.count)
        
        let cellFrame = CGRect(x: 0, y: 4, width: collectionView.frame.width, height: 72)
        
        let gradientLayer: CAGradientLayer
        if let existingGradient = cell.contentView.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradientLayer = existingGradient
        } else {
            gradientLayer = CAGradientLayer()
            cell.contentView.layer.insertSublayer(gradientLayer, at: 0)
        }
        
        gradientLayer.frame = cellFrame
        gradientLayer.colors = [
            theme.color1.withAlphaComponent(0.4).cgColor,
            theme.color2.withAlphaComponent(0.15).cgColor
        ]
        gradientLayer.cornerRadius = 15
        
        let glassView = UIVisualEffectView(effect: UIGlassEffect(style: .clear))
        glassView.frame = cellFrame
        glassView.layer.cornerRadius = 15
        glassView.clipsToBounds = true
        glassView.layer.borderWidth = 1.2
        glassView.layer.borderColor = theme.color1.withAlphaComponent(0.3).cgColor
        
        cell.contentView.addSubview(glassView)
        
        let label = UILabel(frame: glassView.contentView.bounds)
        label.text = category.name.uppercased()
        label.textColor = .white
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        
        glassView.contentView.addSubview(label)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 60)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, trailingSwipeActionsConfigurationForItemAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return }
            
            self.showDeleteConfirmation(for: indexPath, completion: completionHandler)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    private func showDeleteConfirmation(for indexPath: IndexPath, completion: @escaping (Bool) -> Void) {
        let alert = UIAlertController(
            title: "Delete Category?",
            message: "All words in this category will be lost.",
            preferredStyle: .actionSheet
        )
        
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
            self.categories.remove(at: indexPath.item)
            
            StorageManager.shared.save(categories: self.categories)
            
            self.collectionView.deleteItems(at: [indexPath])
            
            completion(true)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(false)
        }))
        
        present(alert, animated: true)
    }
}

extension FoldersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.item]
        
        let wordsVC = CategoryDetailViewController(categoryID: selectedCategory.id, categoryName: selectedCategory.name)
        navigationController?.pushViewController(wordsVC, animated: true)
    }
}

