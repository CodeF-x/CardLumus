import Foundation

class StorageManager {
    static let shared = StorageManager()
    
    private let fileManager = FileManager.default
    
    private var folderURL: URL {
        let url = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return url
    }
    
    private var fileURL: URL {
        return folderURL.appendingPathComponent("categories_data.json")
    }
    
    init() {
        createFolderIfNeeded()
    }
    
    private func createFolderIfNeeded() {
        if !fileManager.fileExists(atPath: folderURL.path) {
            try? fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
    }
    
    func save(categories: [Category]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(categories)
            try data.write(to: fileURL, options: .atomic)

        } catch {
            print("Ошибка сохранения: \(error.localizedDescription)")
        }
    }
    
    func load() -> [Category] {
        guard fileManager.fileExists(atPath: fileURL.path) else {
            print("Файл базы данных отсутствует")
            return []
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode([Category].self, from: data)
        } catch {
            print("Ошибка загрузки: \(error.localizedDescription)")
            return []
        }
    }
}
