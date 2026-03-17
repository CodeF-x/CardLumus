import UIKit

class AddWordViewController: UIViewController {
    
    var onSave: ((String, String) -> Void)?
    
    private let stackView = UIStackView()
    private let termField = UITextField()
    private let translationField = UITextField()
    private let sentenceField = UITextField()
    private let saveButton = GlassNavButton(type: .system)
    private let categoryID: UUID

    init(categoryID: UUID) {
        self.categoryID = categoryID
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.1, alpha: 1)
        setupFields()
    }
    
    private func setupFields() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        configureField(termField, placeholder: "Word / Term")
        configureField(translationField, placeholder: "Translation")
        configureField(sentenceField, placeholder: "discription / sentence")
        
        saveButton.setTitle("ADD TO LIST", for: .normal)
        saveButton.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        
        [termField, translationField,sentenceField, saveButton].forEach { stackView.addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            termField.heightAnchor.constraint(equalToConstant: 50),
            translationField.heightAnchor.constraint(equalToConstant: 50),
            sentenceField.heightAnchor.constraint(equalToConstant: 50),
            saveButton.heightAnchor.constraint(equalToConstant: 55)
        ])
    }
    
    
    
    private func configureField(_ tf: UITextField, placeholder: String) {
        tf.placeholder = placeholder
        tf.textColor = .white
        tf.backgroundColor = .white.withAlphaComponent(0.05)
        tf.layer.cornerRadius = 12
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 0))
        tf.leftViewMode = .always
    }
    
    @objc private func saveTapped() {
        guard let term = termField.text, !term.isEmpty,
        let trans = translationField.text, !trans.isEmpty,
        let sent = sentenceField.text, !sent.isEmpty else { return }
    
        saveNewWord(term: term,translation: trans,sentence: sent)
        
    }
    
    func saveNewWord(term: String, translation: String, sentence: String) {
        var allCategories = StorageManager.shared.load()

        if let index = allCategories.firstIndex(where: { $0.id == categoryID }) {
            let newWord = Word(term: term, translation: translation, sentence: sentence)
            allCategories[index].words.append(newWord)
            
            StorageManager.shared.save(categories: allCategories)
            
            onSave?(term, translation)
            dismiss(animated: true)
        }
    }
    
}
