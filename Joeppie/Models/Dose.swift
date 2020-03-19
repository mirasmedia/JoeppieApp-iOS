import Foundation

struct Dose : Codable {

    let id : Int
    let amount : Int
    let baxter : Baxter?
    let medicine : Medicine
    var lastTaken : Date
    let createdAt : Date
    let updatedAt : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case amount
        case baxter
        case medicine
        case lastTaken = "last_taken"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct NestedDose : Codable {
    let id : Int
    let amount : Int
    let baxter : Int
    let medicine : Int
    var lastTaken : Date
    let createdAt : Date
    let updatedAt : Date
    
    enum CodingKeys : String, CodingKey {
        case id
        case amount
        case baxter
        case medicine
        case lastTaken = "last_taken"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
