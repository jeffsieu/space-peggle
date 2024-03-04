protocol Saveable: Codable {
    init(from decoder: Decoder) throws
    func encode(to encoder: Encoder) throws
}
