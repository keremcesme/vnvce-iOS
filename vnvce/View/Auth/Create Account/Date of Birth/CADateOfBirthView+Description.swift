
import SwiftUI

extension CADateOfBirthView {
    @ViewBuilder
    public var Description: some View {
        VStack(alignment: .leading, spacing: 10){
            Group {
                Text("We ask for your date of birth to make sure you're over the age of 13 and to ensure the security of your account.")
                Text("Nobody can see your date of birth and you cannot change it later. For some security reasons, you can only see your birth year in the account details. Therefore, you should make sure that you enter your date of birth correctly.")
            }
            .foregroundColor(.secondary)
            .font(.system(size: 12, weight: .regular, design: .default))
            .multilineTextAlignment(.leading)
        }
    }
}
