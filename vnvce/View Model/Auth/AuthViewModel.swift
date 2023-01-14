
import Foundation
import SwiftUI
import VNVCECore
import KeychainAccess

enum UsernameAvailability {
    case available
    case unavailable
    case nothing
}

//@MainActor
class AuthViewModel: ObservableObject {
    public let authAPI = AuthAPI()
    private let meAPI = MeAPI()
    
    private let keychain = Keychain()
    private let pkce = PKCEService()
    
    // MARK: Login -
    // MARK: Check Phone Number and Send OTP
    @Published public var loginPhoneNumber = PhoneNumber()
    @Published private(set) public var showLoginVerifyOTPButton: Bool = false
    @Published public var checkLoginPhoneNumberIsRunning: Bool = false
    @Published public var loginOTPResponse: AuthorizeAndOTPResponse.V1?
    @Published private(set) var checkLoginPhoneNumberError: Bool = false
    
    // MARK: Verify OTP
    @Published public var showLoginOTPVerifyView: Bool = false
    @Published public var loginOTPText: String = ""
    @Published public var loginVerifyOTPIsRunning: Bool = false
    @Published public var loginVerifyOTPError: Bool = false
    @Published public var showLoginButton: Bool = false
    
    
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
    
    // MARK: OTP
    @Published public var showCreateOTPVerifyView: Bool = false
    @Published public var createOTPText: String = ""
    
    // MARK: Create Account
    @Published public var createAccountIsRunning: Bool = false
    @Published private(set) public var showCreateAccountButton: Bool = false
    
    // MARK: Optionals -
    // MARK: Display Name
    @Published public var showDisplayNameView: Bool = false
    @Published public var displayName: String = ""
    @Published public var editDisplayNameTaskIsRunning: Bool = false
    
    // MARK: Biography
    @Published public var showBiographyView: Bool = false
    @Published public var biography: String = ""
    @Published public var editBiographyTaskIsRunning: Bool = false
    
    @Published public var showProfilePictureView: Bool = false
    
    private var checkPhoneAndSendOTPTask: Task<Void, Never>?
    private var verifyOTPAndLoginTask: Task<Void, Never>?
    private var checkPhoneNumberTask: Task<Void, Never>?
    private var checkUsernameTask: Task<Void, Never>?
    private var reserveUsernameAndSendOTPTask: Task<Void, Never>?
    private var createAccountTask: Task<Void, Never>?
    private var editDisplayNameTask: Task<Void, Never>?
    private var editBiographyTask: Task<Void, Never>?
    
    public func showCreateAction() {
        showCreateView = true
    }
    
    public func onChangeShowLoginVerifyOTPButton(_ value: String) {
        if loginOTPResponse != nil {
            loginOTPResponse = nil
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            checkLoginPhoneNumberError = false
            if value != "" && loginOTPResponse == nil {
                showLoginVerifyOTPButton = true
            } else {
                showLoginVerifyOTPButton = false
            }
        }
    }
    
    public func onChangeLoginButton(_ value: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if loginOTPText.count == 6 {
                showLoginButton = true
            } else {
                showLoginButton = false
            }
        }
    }
    
    public func onChangeShowAgreeAndContinueButton(_ value: String) {
        if checkPhoneNumberResult != nil {
            checkPhoneNumberResult = nil
        }
        withAnimation(.easeInOut(duration: 0.2)) {
            if value != "" && checkPhoneNumberResult == nil {
                showAgreeAndContinueButton = true
            } else {
                showAgreeAndContinueButton = false
            }
        }
    }
    
    public func onChangeUsernameContinueButton(_ value: UsernameAvailability) {
        withAnimation(.easeInOut(duration: 0.2)) {
            showUsernameContinueButton = value == .available
        }
    }
    
    public func onChangeCreateAccountButton(_ value: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if createOTPText.count == 6 {
                showCreateAccountButton = true
            } else {
                showCreateAccountButton = false
            }
        }
    }
    
    // MARK: Tasks -
    // MARK: Login
    public func checkPhoneAndSendOTP() {
        checkPhoneAndSendOTPTask?.cancel()
        checkPhoneAndSendOTPTask = Task {
            await checkPhoneAndSendOTPTask()
            checkPhoneAndSendOTPTask?.cancel()
        }
    }
    
    public func verifyOTPAndLogin() {
        verifyOTPAndLoginTask?.cancel()
        verifyOTPAndLoginTask = Task {
            await verifyOTPAndLoginTask()
            verifyOTPAndLoginTask?.cancel()
        }
    }
    
    // MARK: Create
    public func checkPhoneNumber() {
        checkPhoneNumberTask?.cancel()
        checkPhoneNumberTask = Task {
            await checkPhoneNumberTask()
            checkPhoneNumberTask?.cancel()
        }
    }
    
    public func checkUsername() {
        checkUsernameTask?.cancel()
        checkUsernameTask = Task {
            await checkUsernameTask()
            checkUsernameTask?.cancel()
        }
    }
    
    public func reserveUsernameAndSendOTP() {
        reserveUsernameAndSendOTPTask?.cancel()
        reserveUsernameAndSendOTPTask = Task {
            await reserveUsernameAndSendOTPTask()
            reserveUsernameAndSendOTPTask?.cancel()
        }
    }
    
    public func createAccount() {
        createAccountTask?.cancel()
        createAccountTask = Task {
            await createAccountTask()
            createAccountTask?.cancel()
        }
    }
    
    // MARK: Edit
    public func editDisplayName() {
        editDisplayNameTask?.cancel()
        editDisplayNameTask = Task {
            await editDisplayNameTask()
            editDisplayNameTask?.cancel()
        }
    }
    
    public func editBiography() {
        editBiographyTask?.cancel()
        editBiographyTask = Task {
            await editBiographyTask()
            editBiographyTask?.cancel()
        }
    }
}

// MARK: Login
private extension AuthViewModel {
    
    @MainActor
    func checkPhoneAndSendOTPTask() async {
        checkLoginPhoneNumberIsRunning = true
        
        let countryCode = loginPhoneNumber.countryCode
        let nationalNumber = loginPhoneNumber.nationalNumber
        let phoneNumber = String(countryCode) + String(nationalNumber)
        
        do {
            let result = try await authAPI.checkPhoneAndSendOTP(phoneNumber)
            loginOTPResponse = result
            try await Task.sleep(seconds: 0.5)
            showLoginOTPVerifyView = true
            try await Task.sleep(seconds: 0.5)
            checkLoginPhoneNumberIsRunning = false
        } catch {
            checkLoginPhoneNumberError = true
            checkLoginPhoneNumberIsRunning = false
        }
    }
    
    @MainActor
    func verifyOTPAndLoginTask() async {
        loginVerifyOTPIsRunning = true
        
        let countryCode = loginPhoneNumber.countryCode
        let nationalNumber = loginPhoneNumber.nationalNumber
        let phoneNumber = String(countryCode) + String(nationalNumber)
        
        do {
            try await authAPI.verifyOTPAndLogin(phoneNumber, code: loginOTPText)
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.loggedIn)
            try await Task.sleep(seconds: 0.5)
            showLoginOTPVerifyView = false
            UIDevice.current.setStatusBar(style: .lightContent, animation: true)
            try await Task.sleep(seconds: 0.5)
            loginVerifyOTPIsRunning = false
        } catch {
            loginVerifyOTPError = true
            loginVerifyOTPIsRunning = false
        }
    }
    
}

// MARK: Create
private extension AuthViewModel {
    
    @MainActor
    func checkPhoneNumberTask() async {
        checkPhoneNumberIsRunning = true
        
        let countryCode = createPhoneNumber.countryCode
        let nationalNumber = createPhoneNumber.nationalNumber
        let phoneNumber = String(countryCode) + String(nationalNumber)
        
        do {
            let result = try await authAPI.checkPhoneNumber(phoneNumber)
            
            try await Task.sleep(seconds: 0.5)
            
            checkPhoneNumberResult = result
            
            if let result = checkPhoneNumberResult, !result.error {
                showDateOfBirthView = true
            }
            
            try await Task.sleep(seconds: 0.5)
            
            checkPhoneNumberIsRunning = false
        } catch {
            checkPhoneNumberIsRunning = false
        }
    }
    
    @MainActor
    func checkUsernameTask() async {
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
    
    @MainActor
    func reserveUsernameAndSendOTPTask() async {
        reserveUsernameSendOTPIsRunning = true
        
        let countryCode = createPhoneNumber.countryCode
        let nationalNumber = createPhoneNumber.nationalNumber
        let phoneNumber = String(countryCode) + String(nationalNumber)
        
        do {
            let result = try await authAPI.reserveUsernameAndSendOTP(
                phone: phoneNumber,
                username: username)
            try await Task.sleep(seconds: 1)
            try keychain.set(result.otp.id, key: KeychainKey.otpID)
            try keychain.set(result.otp.token, key: KeychainKey.otpToken)
            
            await MainActor.run {
                otp = result
                showCreateOTPVerifyView = true
                reserveUsernameSendOTPIsRunning = false
                print(showCreateOTPVerifyView)
            }
        } catch let error {
            print(error.localizedDescription)
            reserveUsernameSendOTPIsRunning = false
        }
    }
    
    @MainActor
    func createAccountTask() async{
        if let country = createPhoneNumber.country {
            createAccountIsRunning = true
            do {
                let verifier = await pkce.generateCodeVerifier()
                let challenge = try await pkce.generateCodeChallenge(fromVerifier: verifier)
                let calendar = Calendar.current
                let day = calendar.component(.day, from: dateOfBirth)
                let month = calendar.component(.month, from: dateOfBirth)
                let year = calendar.component(.year, from: dateOfBirth)
                
                let payload = VNVCECore.CreateAccountPayload.V1(
                    username: username,
                    dateOfBirth: .init(
                        day: day,
                        month: try month.convertToMonth(),
                        year: year),
                    phoneNumber: .init(
                        country: country,
                        countryCode: createPhoneNumber.countryCode,
                        nationalNumber: createPhoneNumber.nationalNumber),
                    code: createOTPText,
                    codeChallenge: challenge)
                
                try keychain.set(verifier, key: KeychainKey.codeVerifier)
                try keychain.set(challenge, key: KeychainKey.codeChallenge)
                
                let result = try await authAPI.createAccount(payload)
                
                try await Task.sleep(seconds: 1)
                
                try keychain.set(result.userID, key: KeychainKey.userID)
                try keychain.set(result.authCode, key: KeychainKey.authCode)
                try keychain.set(result.authID, key: KeychainKey.authID)
                
                let tokensPayload = VNVCECore.GenerateTokensPayload.V1(
                    authCode: result.authCode,
                    codeVerifier: verifier)
                
                try keychain.remove(KeychainKey.otpToken)
                try keychain.remove(KeychainKey.otpID)
                
                try await authAPI.generateTokens(tokensPayload)
                
                UserDefaults.standard.set(true, forKey: UserDefaultsKey.accountIsCreated)
                
                showDisplayNameView = true
                
                try await Task.sleep(seconds: 0.5)
                
                createAccountIsRunning = false
            } catch {
                createAccountIsRunning = false
            }
        }
        
    }
    
}

// MARK: Edit
private extension AuthViewModel {
    
    @MainActor
    func editDisplayNameTask() async {
        editDisplayNameTaskIsRunning = true
        let displayName = self.displayName == "" ? nil : self.displayName
        try? await meAPI.editDisplayName(displayName)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.loggedIn)
        try? await Task.sleep(seconds: 0.5)
//        showBiographyView = true
        showDisplayNameView = false
        UIDevice.current.setStatusBar(style: .lightContent, animation: true)
        try? await Task.sleep(seconds: 0.5)
        editDisplayNameTaskIsRunning = false
    }
    
    @MainActor
    func editBiographyTask() async {
        editBiographyTaskIsRunning = true
        let biography = self.biography == "" ? nil : self.biography
        try? await meAPI.editBiography(biography)
        try? await Task.sleep(seconds: 0.5)
        UserDefaults.standard.set(true, forKey: UserDefaultsKey.loggedIn)
        try? await Task.sleep(seconds: 0.5)
        editBiographyTaskIsRunning = false
    }
}

