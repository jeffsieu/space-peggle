protocol FilePersister {
    func writeToFile(withName fileName: String, data: Saveable) throws
    func readFromFile<Data: Saveable>(withName fileName: String) throws -> Data?
    func deleteFile(withName fileName: String) throws
}
