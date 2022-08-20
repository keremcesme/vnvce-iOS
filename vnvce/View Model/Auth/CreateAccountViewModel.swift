//
//  CreateAccountViewModel.swift
//  vnvce
//
//  Created by Kerem Cesme on 12.08.2022.
//

import Foundation
import PhoneNumberKit
import SwiftUI
import KeychainAccess
import Firebase

class CreateAccountViewModel: ObservableObject {
    private let authAPI = AuthAPI.shared
    
    private let firAuth = Auth.auth()
    private let firestore = Firestore.firestore()
    
    @Published public var show: Bool = false
    
    // MARK: Phone Number
    @Published public var phoneNumberField: String = ""
    @Published public var phoneNumber: String? = nil
    @Published public var regionCode: String? = nil
    
    @Published public var phoneNumberPhase: CheckPhoneNumberPhase = .none
    
    // MARK: Username
    @Published public var showUsernameView: Bool = false
    @Published public var usernameField: String = ""
    @Published public var checkUsernamePhase: CAUsernamePhase = .none
    
    @Published public var reserveUsernameAndSendOTPPhase: ReserveUsernameAndSendOTPPhase = .none
    
    // MARK: OTP
    @Published public var showVerifyView: Bool = false
    @Published public var otpField: String = ""
    
    @Published public var resendSMSOTPPhase: ResendSMSOTPPhase = .none
    
    @Published public var smsAttempt: SMSOTPAttempt? = nil
    
    @Published public var createAccountPhase: CreateAccountPhase = .none
    
    init() {}
    
    public func onNumberChange(_ phoneNumber: PhoneNumber?){
        guard let phone = phoneNumber else {
            self.phoneNumber = nil
            self.regionCode = nil
            return
        }
        let value = "+" + "\(phone.countryCode)" + "\(phone.nationalNumber)"
        self.phoneNumber = value
        self.regionCode = "+" + "\(phone.countryCode)"
        print("Number: \(value)")
    }
    
    @MainActor @Sendable
    public func checkPhoneNumber() async {
        let phase = await checkPhoneNumberTask()
        usernameField = ""
        checkUsernamePhase = .none
        try? await Task.sleep(seconds: 1)
        self.phoneNumberPhase = phase
        if phoneNumberPhase == .success {
            try? await Task.sleep(seconds: 0.2)
            showUsernameView = true
        }
    }
    
    @MainActor @Sendable
    public func autoCheckUsername() async {
        guard let phase = await autoCheckUsernameTask() else {
            return
        }
        self.checkUsernamePhase = phase
    }
    
    @MainActor @Sendable
    public func reserveUsernameAndSendOTP() async {
        smsAttempt = nil
        let phase = await reserveUsernameAndSendOTPTask()
        otpField = ""
        try? await Task.sleep(seconds: 0.2)
        reserveUsernameAndSendOTPPhase = phase
        if reserveUsernameAndSendOTPPhase == .success {
            try? await Task.sleep(seconds: 0.2)
            if smsAttempt != nil {
                showVerifyView = true
            } else {
                reserveUsernameAndSendOTPPhase = .error(.unknown)
            }
        }
    }
    
    @MainActor @Sendable
    public func resendSMSOTP() async {
        smsAttempt = nil
        let phase = await resendSMSOTPTask()
        try? await Task.sleep(seconds: 0.5)
        self.resendSMSOTPPhase = phase
    }
    
    @MainActor @Sendable
    public func createAccount() async -> CreateAccountSuccess? {
        let phase = await createAccountTask()
        try? await Task.sleep(seconds: 0.5)
        self.createAccountPhase = phase
        if case let .success(success) = self.createAccountPhase {
            try? await Task.sleep(seconds: 0.2)
            return success
        } else {
            return nil
        }
        
    }
}

private extension CreateAccountViewModel {
    
    // Step 1 - Check phone number availability.
    private func checkPhoneNumberTask() async -> CheckPhoneNumberPhase {
        if Task.isCancelled { return .error(.taskCancelled) }
        self.phoneNumberPhase = .running
        
        guard let phoneNumber = phoneNumber else {
            return .error(.invalidNumber)
        }
        
        guard let clientID = await UIDevice.current.identifierForVendor?.uuidString else {
            return .error(.unknown)
        }
        
        do {
            let result = try await authAPI.checkPhoneNumber(phoneNumber: phoneNumber, clientID: clientID)
            if Task.isCancelled { return .error(.taskCancelled) }
            switch result.result.status {
                case .available:
                    return .success
                case .alreadyTaken:
                    return .error(.alreadyTaken)
                case .otpExist:
                    return .error(.otpExist)
            }
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    // Auto - Check username availabiltiy.
    private func autoCheckUsernameTask() async -> CAUsernamePhase? {
        if Task.isCancelled { return .error(.taskCancelled) }
        
        guard !usernameField.isEmpty else {
            return nil
        }
        
        guard await usernameRegex(username: usernameField) else {
            return .error(.invalidUsername)
        }
        
        guard let clientID = await UIDevice.current.identifierForVendor?.uuidString else {
            return .error(.unknown)
        }
        
        do {
            let result = try await authAPI.autoCheckUsername(username: usernameField, clientID: clientID)
            if Task.isCancelled { return .error(.taskCancelled) }
            
            switch result.result.status {
                case .available:
                    return .success
                case .alreadyTaken:
                    return .error(.alreadyTaken)
                case .reserved:
                    return .error(.reserved)
            }
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
        
    }
    
    // Step 2 - Reserve Username and Send OTP code to phone number.
    @MainActor
    private func reserveUsernameAndSendOTPTask() async -> ReserveUsernameAndSendOTPPhase {
        if Task.isCancelled { return .error(.taskCancelled) }
        self.reserveUsernameAndSendOTPPhase = .running
        guard let phoneNumber = phoneNumber else {
            return .error(.unknown)
        }
        
        guard let clientID = UIDevice.current.identifierForVendor else {
            return .error(.unknown)
        }
        
        do {
            let payload = ReserveUsernameAndSendSMSOTPPayload(
                username: usernameField,
                phoneNumber: phoneNumber,
                clientID: clientID,
                type: .createAccount)
            
            let result = try await authAPI.reserveUsernameAndSendSMSOTP(payload: payload)
            if Task.isCancelled { return .error(.taskCancelled) }
            
            switch result.result.status {
                case let .failure(failure):
                    switch failure {
                        case let .phone(smsOTPFailure):
                            switch smsOTPFailure {
                                case .alreadyTaken:
                                    return .error(.numberAlreadyTaken)
                                case .otpExist:
                                    return .error(.otpExist)
                            }
                        case let .username( usernameFailure):
                            switch usernameFailure {
                                case .alreadyTaken:
                                    return .error(.usernameAlreadyTaken)
                                case .reserved:
                                    return .error(.usernameIsReserved)
                            }
                    }
                case let .success(success):
                    self.smsAttempt = success
                    return .success
            }
            
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    @MainActor
    private func resendSMSOTPTask() async -> ResendSMSOTPPhase {
        if Task.isCancelled { return .error(.taskCancelled) }
        self.resendSMSOTPPhase = .running
        
        guard let phoneNumber = phoneNumber else {
            return .error(.unknown)
        }
        
        guard let clientID = UIDevice.current.identifierForVendor else {
            return .error(.unknown)
        }
        
        do {
            let payload = ResendSMSOTPPayload(
                phoneNumber: phoneNumber,
                clientID: clientID,
                type: .createAccount)
         
            let result = try await authAPI.resendSMSOTP(payload: payload)
            if Task.isCancelled { return .error(.taskCancelled) }
            self.smsAttempt = result.result.status
            return .success
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    // Step 3 - Verify OTP and create account.
    private func createAccountTask() async -> CreateAccountPhase{
        if Task.isCancelled { return .error(.taskCancelled) }
        
        self.createAccountPhase = .running
        
        guard let phoneNumber = phoneNumber else {
            return .error(.unknown)
        }
        
        guard let clientID = await UIDevice.current.identifierForVendor else {
            return .error(.unknown)
        }
        
        guard let attempt = smsAttempt else {
            return .error(.unknown)
        }
        
        do {
            let otp = VerifySMSPayload(
                phoneNumber: phoneNumber,
                otpCode: otpField,
                clientID: clientID,
                attemptID: attempt.attemptID)
            
            let payload = CreateAccountPayload(
                otp: otp,
                username: usernameField)
            
            let result = try await authAPI.createAccount(payload: payload)
            if Task.isCancelled { return .error(.taskCancelled) }
            switch result.result.status {
                case let .failure(failure):
                    switch failure {
                        case .expired:
                            return .error(.otpExpired)
                        case .failure:
                            return .error(.otpNotVerified)
                    }
                case let .success(success):
                    try await firAuth.signInAnonymously()
                    
                    guard let firebaseID = firAuth.currentUser?.uid else {
                        return .error(.unknown)
                    }
                    
                    let userID = success.user.id.uuidString
                    
                    let firPayload: [String: Any] = [
                        "userID": userID,
                        "firebaseID": firebaseID
                    ]
                    
                    try await firestore.collection("Users").document(userID).setData(firPayload)
                    
                    return .success(success)
            }
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
}
