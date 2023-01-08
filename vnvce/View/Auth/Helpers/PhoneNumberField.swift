
import SwiftUI
import UIKit
import PhoneNumberKit

struct PhoneNumber {
    var country: String?
    var countryCode: Int
    var nationalNumber: Int
    var number: String
    
    init(_ country: String?, _ countryCode: Int, _ nationalNumber: Int, _ number: String) {
        self.country = country
        self.countryCode = countryCode
        self.nationalNumber = nationalNumber
        self.number = number
    }
    
    init() {
        self.country = nil
        self.countryCode = 0
        self.nationalNumber = 0
        self.number = ""
    }
}

struct PhoneNumberFieldUI: UIViewRepresentable {
    
    @Binding private var phoneNumber: PhoneNumber
    
    public init(_ phoneNumber: Binding<PhoneNumber>) {
        self._phoneNumber = phoneNumber
    }
    
    func makeUIView(context: Context) -> PhoneNumberTextField {
        let textField = PhoneNumberTextField()
        if phoneNumber.nationalNumber != 0 {
            textField.text = String(phoneNumber.nationalNumber)
        }
        textField.withFlag = true
        textField.withDefaultPickerUI = true
        textField.withExamplePlaceholder = false
        textField.modalPresentationStyle = .pageSheet
        textField.withPrefix = false
        textField.isPartialFormatterEnabled = true
        textField.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        textField.adjustsFontSizeToFitWidth = true
        textField.delegate = context.coordinator
        textField.keyboardType = .phonePad
        textField.maxDigits = 16
        textField.placeholder = "Your number"
        
        textField.addTarget(
            context.coordinator,
            action: #selector(Coordinator.textViewDidChange),
            for: .editingChanged
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: PhoneNumberFieldUI
        
        init(_ parent: PhoneNumberFieldUI) {
            self.parent = parent
        }
        
        @objc public func textViewDidChange(_ textField: UITextField) {
            guard let textField = textField as? PhoneNumberTextField else {
                return assertionFailure("Undefined state")
            }
            
            if let number = textField.phoneNumber {
                let country = number.regionID
                let countryCode = Int(number.countryCode)
                let nationalNumber = Int(number.nationalNumber)
                let number = "+" + String(countryCode) + String(nationalNumber)
                
                let phoneNumber = PhoneNumber(country, countryCode, nationalNumber, number)
                
                self.parent.phoneNumber = phoneNumber
            } else {
                self.parent.phoneNumber = PhoneNumber()
            }
        }
    }
    
}
