
import SwiftUI
import SwiftyContacts
import PhoneNumberKit
import VNVCECore

enum ContactsConfiguration {
    case success
    case failed
    case permissionNotDetermined
    case permissionRestricted
    case permissionDenied
    case none
    
    var buttonTitle: String {
        switch self {
        case .permissionDenied:
            return "Open Settings"
        case .permissionNotDetermined:
            return "Allow"
        default:
            return ""
        }
    }
}

struct Contact {
    let name: String
}

class ContactsViewModel: ObservableObject {
    private let searchAPI = SearchAPI()
    
    private let phoneNumberKit = PhoneNumberKit()
    
    private var contacts = [CNContact]()
    
    @Published private(set) public var phoneNumbers = [String]()
    @Published private(set) public var users = [User.Public]()
    
    @Published private(set) public var configuration: ContactsConfiguration = .none
    
    init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    public func requestContactsAccess() async {
        _ = try? await requestAccess()
        await checkAuthorizationStatus()
    }
    
    @MainActor
    public func checkAuthorizationStatus() async {
        let status = authorizationStatus()
        switch status {
        case .authorized:
            self.configuration = .success
            await fetchAllContacts()
            await fetchUsers()
        case .notDetermined:
            self.configuration = .permissionNotDetermined
        case .restricted:
            self.configuration = .permissionRestricted
        case .denied:
            self.configuration = .permissionDenied
        @unknown default:
            self.configuration = .failed
        }
    }
    
    @MainActor
    private func fetchAllContacts() async {
        do {
            let contacts = try await fetchContacts()
            var numbers = [String]()
            
            for contact in contacts {
                let phoneNumbers = contact.phoneNumbers.map({$0.value.stringValue})
                for phoneNumber in phoneNumbers {
                    if let number = try? phoneNumberKit.parse(phoneNumber) {
                        let rawNumber = "+\(number.countryCode)\(number.nationalNumber)"
                        numbers.append(rawNumber)
                    }
                }
            }
            
            self.phoneNumbers = numbers
        } catch {
            print(error.localizedDescription)
        }
    }
    
    @MainActor
    private func fetchUsers() async {
        do {
            self.users = try await searchAPI.searchFromContacts(self.phoneNumbers)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func openSettings() {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl)
        }
    }
    
}
