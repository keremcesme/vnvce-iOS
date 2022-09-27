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

@MainActor
class CreateAccountViewModel: ObservableObject {
    private let authAPI = AuthAPI.shared
    private let storageAPI = StorageAPI.shared
    private let meAPI = MeAPI.shared
    
    // MARK: Show Create Account View
    @Published public var show: Bool = false
    
    // MARK: Phone Number
    @Published public var phoneNumberField: String = ""
    @Published public var phoneNumber: String? = nil
    @Published public var regionCode: String? = nil
    
    // MARK: Username
    @Published public var showUsernameView: Bool = false
    @Published public var usernameField: String = ""
    
    // MARK: OTP
    @Published public var showVerifyView: Bool = false
    @Published public var otpField: String = ""
    @Published public var smsAttempt: SMSOTPAttempt? = nil
    
    
    // MARK: Profile Picture
    @Published public var showProfilePictureView: Bool = false
    @Published public var profilePicture: UIImage? = nil
    @Published public var profilePictureAlignment: Alignment = .center
    
    // MARK: Display Name
    @Published public var showDisplayNameView: Bool = false
    @Published public var displayNameField: String = ""
    
    // MARK: Biography
    @Published public var showBiographyView: Bool = false
    @Published public var biographyField: String = ""
    
    // MARK: Phases
    @Published public var phoneNumberPhase: CheckPhoneNumberPhase = .none
    @Published public var checkUsernamePhase: CAUsernamePhase = .none
    @Published public var reserveUsernameAndSendOTPPhase: ReserveUsernameAndSendOTPPhase = .none
    @Published public var resendSMSOTPPhase: ResendSMSOTPPhase = .none
    @Published public var createAccountPhase: CreateAccountPhase = .none
    @Published public var editProfilePicturePhase: CAOptionalPhase = .none
    @Published public var editDisplayNamePhase: CAOptionalPhase = .none
    @Published public var editBiographyPhase: CAOptionalPhase = .none
    
    
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
    public func createAccount() async -> LoginAccountResponse? {
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
    
    @MainActor @Sendable
    public func editProfilePicture() async {
        let phase = await editProfilePictureTask()
        self.editProfilePicturePhase = phase
        if self.editProfilePicturePhase == .success {
            self.showDisplayNameView = true
        }
    }
    
    @MainActor @Sendable
    public func editDisplayName() async {
        if displayNameField == "" {
            self.showBiographyView = true
        } else {
            let phase = await editDisplayNameTask()
            self.editDisplayNamePhase = phase
            if self.editDisplayNamePhase == .success {
                self.showBiographyView = true
            } else {
                self.editDisplayNamePhase = .none
            }
        }
    }
    
    @MainActor @Sendable
    public func editBiography(finish: @MainActor @escaping () -> ()) async {
        let phase = await editBiographyTask()
        self.editBiographyPhase = phase
        if self.editBiographyPhase == .success {
            finish()
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
        
        guard let clientID = UIDevice.current.identifierForVendor?.uuidString else {
            return .error(.unknown)
        }
        
        do {
            guard let result = try await authAPI.checkPhoneNumber(phoneNumber: phoneNumber, clientID: clientID) else {
                return .error(.unknown)
            }
            if Task.isCancelled { return .error(.taskCancelled) }
            
            switch result {
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
            guard let result = try await authAPI.autoCheckUsername(username: usernameField, clientID: clientID) else {
                return .error(.unknown)
            }
            if Task.isCancelled { return .error(.taskCancelled) }
            
            switch result {
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
            
            guard let result = try await authAPI.reserveUsernameAndSendSMSOTP(payload: payload) else {
                return .error(.unknown)
            }
            if Task.isCancelled { return .error(.taskCancelled) }
            
            switch result {
                case let .success(attempt):
                    self.smsAttempt = attempt
                    return .success
                case let .failure(error):
                    switch error {
                        case let .phone(phoneError):
                            switch phoneError {
                                case .alreadyTaken:
                                    return .error(.numberAlreadyTaken)
                                case .otpExist:
                                    return .error(.otpExist)
                            }
                        case let .username(usernameError):
                            switch usernameError {
                                case .alreadyTaken:
                                    return .error(.usernameAlreadyTaken)
                                case .reserved:
                                    return .error(.usernameIsReserved)
                            }
                    }
            }
            
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    // Resend SMS OTP.
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
            let payload = SendSMSOTPPayload(
                phoneNumber: phoneNumber,
                clientID: clientID,
                type: .createAccount)
         
            guard let result = try await authAPI.resendSMSOTP(payload: payload) else {
                return .error(.unknown)
            }
            if Task.isCancelled { return .error(.taskCancelled) }
            self.smsAttempt = result
            return .success
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    // Step 3 - Verify OTP and create account.
    private func createAccountTask() async -> CreateAccountPhase {
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
            
            guard let result = try await authAPI.createAccount(payload: payload) else {
                return .error(.unknown)
            }
            if Task.isCancelled { return .error(.taskCancelled) }
            
            switch result {
                case let .failure(failure):
                    switch failure {
                        case .expired:
                            return .error(.otpExpired)
                        case .failure:
                            return .error(.otpNotVerified)
                    }
                case let .success(success):
                    print(success)
                    return .success(success)
            }
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    // Optional Steps
    // Step 4 - Edit Profile Picture Image
    @MainActor
    private func editProfilePictureTask() async -> CAOptionalPhase {
        if Task.isCancelled { return .error(.taskCancelled) }
        self.editProfilePicturePhase = .running
        guard let image = self.profilePicture else {
            return .error(.unknown)
        }
        do {
            let uploadResult = try await storageAPI.uploadProfilePicture(image: image)
            if Task.isCancelled { return .error(.taskCancelled) }
            let payload = EditProfilePicturePayload(
                url: uploadResult.url,
                name: uploadResult.name,
                alignment: profilePictureAlignment.convert)
            try await meAPI.editProfilePicture(payload: payload)
            if Task.isCancelled { return .error(.taskCancelled) }
            return .success
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    @MainActor
    private func editDisplayNameTask() async -> CAOptionalPhase {
        if Task.isCancelled { return .error(.taskCancelled) }
        self.editDisplayNamePhase = .running
        
        do {
            try await meAPI.editDisplayName(displayName: self.displayNameField)
            if Task.isCancelled { return .error(.taskCancelled) }
            return .success
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
    @MainActor
    private func editBiographyTask() async -> CAOptionalPhase {
        if Task.isCancelled { return .error(.taskCancelled) }
        self.editBiographyPhase = .running
        
        do {
            try await meAPI.editBiography(biography: self.biographyField)
            if Task.isCancelled { return .error(.taskCancelled) }
            return .success
        } catch {
            if Task.isCancelled { return .error(.taskCancelled) }
            print(error.localizedDescription)
            return .error(.unknown)
        }
    }
    
}
