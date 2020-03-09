//
//  ApiService.swift
//  Joeppie
//
//  Created by Shahin Mirza on 26/11/2019.
//  Copyright © 2019 Bever-Apps. All rights reserved.
//

import Foundation
import Alamofire
import SwiftKeychainWrapper

class ApiService {
    private static let baseURL = "https://api.stider.space"
    
    //Shahin: - User
    
    //(POST)/login
    static func logUserIn(withIdentiefier identifier: String, andPassword password: String) -> (DataRequest) {
        var parameters : [String:String] = [:]
        parameters["identifier"] = identifier
        parameters["password"] = password
        
        return Alamofire.request(baseURL + "/auth/local", method: .post, parameters: parameters, encoding: Alamofire.JSONEncoding.default, headers: nil)
    }
    
    //(POST)/register
    static func createUser(withUsername username : String, email : String, andPassword password : String) -> (DataRequest) {
        var parameters : [String:String] = [:]
        parameters["username"] = username
        parameters["email"] = email
        parameters["password"] = password
        
        var headers : [String : String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return Alamofire.request(baseURL + "/auth/local/register", method: .post, parameters: parameters, encoding: Alamofire.JSONEncoding.default, headers: nil)
    }
    
    //ERCAN:
    
    //(GET)/baxters
    static func getBaxterClient(dayOfWeek:String,patientId:String) -> (DataRequest) {
        var headers : [String : String] = [:]
        var parameters : [String:String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
            parameters["patient"] = "\(patientId)"
            parameters["day_of_week"] = "\(dayOfWeek)"
        }
        
        return Alamofire.request(baseURL + "/baxters?_sort=intake_time:ASC", method: .get, parameters: parameters,headers: headers)
    }
    //(GET)/medicines
    static func getMedicines() -> (DataRequest) {
        var headers : [String : String] = [:]
        var parameters : [String:String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return Alamofire.request(baseURL + "/medicines", method: .get, parameters: parameters,headers: headers)
    }
    
    //(update)/dose
    static func updateDose(id:String, lastTaken:String) -> (DataRequest) {
        var headers : [String : String] = [:]
        var parameters : [String:String] = [:]
        parameters["last_taken"] = lastTaken
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return Alamofire.request(baseURL + "/doses/"+id, method: .put, parameters: parameters,headers: headers)
    }
    
    //(put)/intake
    static func setIntake(dose:NestedDose, patient:Patient, timeNow:String, state:String) -> (DataRequest) {
        var headers : [String : String] = [:]
        var parameters : [String:String] = [:]
        parameters["medicine"] = String(dose.medicine)
        parameters["patient"] = String(patient.id)
        parameters["time_taken_in"] = timeNow
        parameters["state"] = state
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return Alamofire.request(baseURL + "/intakes", method: .post, parameters: parameters,headers: headers)
    }
    
    
    static func getIntakesCount(takenTime:DoseTakenTime) -> (DataRequest) {
        var headers : [String : String] = [:]
        var parameters : [String:String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        let stringTakenId = String(takenTime.rawValue)
        parameters["state"] = "\(stringTakenId)"
        
        return Alamofire.request(baseURL + "/intakes/count", method: .get, parameters: parameters,headers: headers)
    }
    
    
    //Shahin: - Patient
    
    //(GET)/patients
    static func getPatients(forCoachId coachId : Int) -> (DataRequest) {
        var headers : [String : String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        return Alamofire.request(baseURL + "/patients?coach_id=\(coachId)", method: .get, parameters: nil /*parameters*/, encoding: Alamofire.JSONEncoding.default, headers: headers)
    }
    
    //(POST)/patients
    static func createPatient() -> (DataRequest) {
        var parameters : [String:String] = [:]
        parameters["user"] = ""
        parameters["first_name"] = ""
        parameters["insertion"] = ""
        parameters["last_name"] = ""
        parameters["date_of_birth"] = ""
        parameters["coachId"] = ""
        
        return Alamofire.request(baseURL + "/patients", method: .get, parameters: parameters, encoding: Alamofire.JSONEncoding.default, headers: nil)
    }
    
    //(GET)/patients
    static func getPatient(withUserId userId : Int) -> (DataRequest) {
        var headers : [String : String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        return Alamofire.request(baseURL + "/patients?user=\(userId)", method: .get, parameters: nil, encoding: Alamofire.JSONEncoding.default, headers: headers)
    }
    
    //Shahin: - Coach
    
    //(GET)/coaches
    static func getCoach(withUserId userId : Int) -> (DataRequest) {
        var headers : [String : String] = [:]
        if let token = KeychainWrapper.standard.string(forKey: Constants.tokenIdentifier) {
            headers["Authorization"] = "Bearer \(token)"
        }
        
        return Alamofire.request(baseURL + "/coaches?user=\(userId)", method: .get, parameters: nil, encoding: Alamofire.JSONEncoding.default, headers: headers)
    }
    
}
