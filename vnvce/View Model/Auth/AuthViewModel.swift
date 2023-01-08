
import Foundation
import SwiftUI
import VNVCECore

enum UsernameAvailability {
    case available
    case unavailable
    case nothing
}

@MainActor
class AuthViewModel: ObservableObject {
    public let authAPI = AuthAPI()
    
    @Published public var loginPhoneNumber = PhoneNumber()
    
    // MARK: Create -
    @Published public var showCreateView: Bool = false
    
    // MARK: Check Phone Number
    @Published public var createPhoneNumber = PhoneNumber()
    @Published private(set) public var showAgreeAndContinueButton: Bool = false
    @Published public var checkPhoneNumberIsRunning: Bool = false
    @Published public var checkPhoneNumberResult: RequestResponse.V1?
    
    // MARK: Date of Birth
    @Published public var showDateOfBirthView: Bool = false
    @Published public var dateOfBirth = Calendar.current.date(byAdding: .year, value: -13, to: Date())!
    
    // MARK: Username
    @Published public var showUsernameView: Bool = false
    @Published public var checkUsernameIsRunning: Bool = false
    @Published public var username: String = ""
    @Published public var usernameAvailability: UsernameAvailability = .nothing
    @Published public var reserveUsernameSendOTPIsRunning: Bool = false
    @Published private(set) public var showUsernameContinueButton: Bool = false
    
    @Published public var otp: OTPResponse.V1?
    
    private var checkUsernameTask: Task<Void, Never>?
    
    // MARK: OTP
    @Published public var showCreateOTPVerifyView: Bool = false
    @Published public var createOTPText: String = ""
    
    public func showCreateAction() {
        showCreateView = true
    }
    
    public func onChangeShowAgreeAndContinueButton(_ value: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            showAgreeAndContinueButton = value != ""
        }
    }
    
    public func onChangeUsernameContinueButton(_ value: UsernameAvailability) {
        withAnimation(.easeInOut(duration: 0.2)) {
            showUsernameContinueButton = value == .available
        }
    }
    
    
    public func checkUsername() {
        if let checkUsernameTask, !checkUsernameTask.isCancelled {
            checkUsernameTask.cancel()
        }
        
        checkUsernameTask = Task {
            await checkUsernameTask()
            checkUsernameTask?.cancel()
        }
    }
    
    
    
    public func checkPhoneNumber() async throws {
        checkPhoneNumberIsRunning = true
        
        let countryCode = createPhoneNumber.countryCode
        let nationalNumber = createPhoneNumber.nationalNumber
        let phoneNumber = String(countryCode) + String(nationalNumber)
        
        let result = try await authAPI.checkPhoneNumber(phoneNumber)
        
        await MainActor.run {
            checkPhoneNumberResult = result
            if let result = checkPhoneNumberResult, !result.error {
                showDateOfBirthView = true
            }
            checkPhoneNumberIsRunning = false
        }
    }
    
    @Sendable
    private func checkUsernameTask() async {
        guard !username.isEmpty else {
            return
        }
        
        checkUsernameIsRunning = true
        
        guard await usernameRegex(username: username) else {
            usernameAvailability = .unavailable
            checkUsernameIsRunning = false
            return
        }
        
        do {
            let result = try await authAPI.checkUsername(username)
            
            await MainActor.run {
                if result.error {
                    usernameAvailability = .unavailable
                } else {
                    usernameAvailability = .available
                }
                checkUsernameIsRunning = false
            }
        } catch {
            usernameAvailability = .unavailable
            checkUsernameIsRunning = false
        }
        
    }
    
    @Sendable
    public func reserveUsernameAndSendOTP() async {
        reserveUsernameSendOTPIsRunning = true
        
        let countryCode = createPhoneNumber.countryCode
        let nationalNumber = createPhoneNumber.nationalNumber
        let phoneNumber = String(countryCode) + String(nationalNumber)
        
        do {
            let result: OTPResponse.V1 = try await {
                if let otp {
                    return try await authAPI.reserveUsernameAndSendOTP(phone: phoneNumber, username: username, otpToken: otp.otp.token)
                } else {
                    return try await authAPI.reserveUsernameAndSendOTP(phone: phoneNumber, username: username)
                }
            }()
            
            UserDefaults.standard.set(result.otp.id, forKey: VNVCEHeaders.otpID)
            
            await MainActor.run {
                otp = result
                print(otp)
                showCreateOTPVerifyView = true
                reserveUsernameSendOTPIsRunning = false
            }
        } catch {
            reserveUsernameSendOTPIsRunning = false
        }
    }
    
}
