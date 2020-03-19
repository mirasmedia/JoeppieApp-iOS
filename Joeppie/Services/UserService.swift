//
//  UserService.swift
//  Joeppie
//
//  Created by Shahin Mirza on 06/01/2020.
//  Copyright © 2020 Bever-Apps. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper

class UserService {
    
    //Shahin: - Instances
    private static var userInstance : User?
    private static var coachInstance : Coach?
    private static var patientInstance : Patient?
    
    //Shahin: LogOut
    
    //Removes all instances off the user, coach and patient from the app
    public static func logOut(){
        UserDefaults.standard.removeObject(forKey: Constants.userKey)
        UserDefaults.standard.removeObject(forKey: Constants.coachKey)
        UserDefaults.standard.removeObject(forKey: Constants.patientKey)
        KeychainWrapper.standard.removeObject(forKey: Constants.tokenIdentifier)
        
        userInstance = nil
        coachInstance = nil
        patientInstance = nil
    
    }
    
    
    //Shahin: - User
    
    //Sets the user instance
    public static func setUser(instance: User) {
        userInstance = instance
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(instance) else {
            return
        }
        UserDefaults.standard.set(data, forKey: Constants.userKey)
    }
    
    public static func getUser(withCompletionHandeler cH : @escaping (User?) -> ()) {
        //If there is an instance, return it
        if let instance = userInstance {
            cH(instance)
            return
        }
        //If there is an instance saved in userdefaults, return it
        if let data = UserDefaults.standard.data(forKey: Constants.userKey) {
            let decoder = JSONDecoder()
            if let user = try? decoder.decode(User.self, from: data) {
                userInstance = user
                cH(user)
                return
            }
        }
        //If there is no user, return nil
        cH(nil)
    }
    
    //Shahin: - Coach
    
    //returns the coach instance, if it's not here, it will get it from the api using the user instance, if api doesn't have it, returns nil
    public static func getCoachInstance(withCompletionHandler cH : @escaping (Coach?) -> ()){
        //If there is no user, there should be no coach
        guard let userInstance = userInstance else {
            cH(nil)
            return
        }
        //If there is an instance, return it
        if let instance = coachInstance {
            cH(instance)
            return
        }
        //If there is an instance saved in userdefaults, return it
        if let data = UserDefaults.standard.data(forKey: Constants.coachKey) {
            let decoder = JSONDecoder()
            if let coach = try? decoder.decode(Coach.self, from: data) {
                coachInstance = coach
                cH(coach)
                return
            }
        }
        //If gets the instance from api
        ApiService.getCoach(withUserId: userInstance.id).responseData(completionHandler: { response in
            guard let jsonData = response.data else {
                cH(nil)
                return
            }
            //print(String(decoding: jsonData, as: UTF8.self))
            let decoder = JSONDecoder()
            guard let coaches = try? decoder.decode([Coach].self, from: jsonData) else {
                cH(nil)
                return
            }
            guard let coach = coaches.first else {
                cH(nil)
                return
            }
            self.setCoachInstance(instance: coach)
            cH(coach)
        })
    }
    
    private static func setCoachInstance(instance: Coach) {
        coachInstance = instance
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(instance) else {
            //print("encoding failed")
            return
        }
        UserDefaults.standard.set(data, forKey: Constants.coachKey)
    }
    
    
    //Shahin: - Patient
    
    //returns the patient instance, if it's not here, it will get it from the api using the user instance, if api doesn't have it, returns nil
    public static func getPatientInstance(withCompletionHandler cH : @escaping (Patient?) -> ()) {
        //If there is no user, there should be no patient
        guard let userInstance = userInstance else {
            cH(nil)
            return
        }
        //If there is an instance, return it
        if let instance = patientInstance {
            cH(instance)
            return
        }
        //If there is an instance saved in userdefaults, return it
        if let data = UserDefaults.standard.data(forKey: Constants.patientKey) {
            let decoder = JSONDecoder()
            if let patient = try? decoder.decode(Patient.self, from: data) {
                patientInstance = patient
                cH(patient)
                return
            }
        }
        //If gets the instance from api
        ApiService.getPatient(withUserId: userInstance.id).responseData(completionHandler: { response in
            guard let jsonData = response.data else {
                cH(nil)
                return
            }
            //print(String(decoding: jsonData, as: UTF8.self))
            
            let decoder = JSONDecoder()
            let dateFormatter = DateFormatter()

            dateFormatter.locale = Locale.current
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            
            guard let patients = try? decoder.decode([Patient].self, from: jsonData) else {
                cH(nil)
                return
            }
            guard let patient = patients.first else {
                cH(nil)
                return
            }
            //print("PatientId: \(patient.id)")
            self.setPatientInstance(instance: patient)
            cH(patient)
        })
    }
    
    private static func setPatientInstance(instance: Patient) {
        patientInstance = instance
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(instance) else {
            //print("encoding failed")
            return
        }
        UserDefaults.standard.set(data, forKey: Constants.patientKey)
    }
}
