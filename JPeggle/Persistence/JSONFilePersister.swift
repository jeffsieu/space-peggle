import Foundation

struct JSONFilePersister: FilePersister {
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private func getFileUrl(fileName: String) -> URL {
        URL.documentsDirectory.appending(path: fileName)
    }

    func writeToFile(withName fileName: String, data: Saveable) throws {
        let encoded = try encoder.encode(data)
        let data = Data(encoded)
        let url = getFileUrl(fileName: fileName)

        try data.write(to: url, options: [.atomic, .completeFileProtection])
    }

    func readFromFile<D: Saveable>(withName fileName: String) throws -> D? {
        let url = getFileUrl(fileName: fileName)
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        let decoded = try decoder.decode(D.self, from: data)
        return decoded
    }

    func deleteFile(withName fileName: String) throws {
        let url = getFileUrl(fileName: fileName)
        try FileManager.default.removeItem(at: url)
    }
}
