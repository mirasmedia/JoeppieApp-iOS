// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let doseCreate = try? newJSONDecoder().decode(DoseCreate.self, from: jsonData)

import Foundation

// MARK: - DoseCreate
struct DoseCreate: Codable {
    let id, amount: Int
    let timeTakenIn: String
    let baxter: JSONNull?
    let medicine: Medicine
    let createdAt, updatedAt: String
    let status: JSONNull?
    let lastTaken: String

    enum CodingKeys: String, CodingKey {
        case id, amount
        case timeTakenIn = "time_taken_in"
        case baxter, medicine
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case status
        case lastTaken = "last_taken"
    }
}


// MARK: - Encode/decode helpers

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }

    public var hashValue: Int {
        return 0
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
