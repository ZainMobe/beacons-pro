import Foundation

extension UUID {
    var shortString: String {
        String(uuidString.prefix(8)).uppercased()
    }
}

extension String {
    func inserting(separator: String, every n: Int) -> String {
        var result = ""
        for (index, char) in self.enumerated() {
            if index != 0 && index % n == 0 {
                result += separator
            }
            result.append(char)
        }
        return result
    }

    static func convertToUUID(_ text: String) -> String {
        let uuidWithoutDashes = "3" + text.inserting(separator: "3", every: 1)
        var uuid = uuidWithoutDashes.inserting(separator: "-", every: 4)
        uuid.remove(at: uuid.index(uuid.startIndex, offsetBy: 4))
        uuid += "-000000000000"
        return uuid
    }

    var isValidUUID: Bool {
        UUID(uuidString: self) != nil
    }
}
