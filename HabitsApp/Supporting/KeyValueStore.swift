protocol KeyValueStore {
    func string(forKey key: String) -> String?
    func integer(forKey key: String) -> Int
    func set(_ value: Any?, forKey key: String)
}

extension UserDefaults: KeyValueStore {
    func integer(forKey key: String) -> Int {
        object(forKey: key) as? Int ?? 0
    }
}
