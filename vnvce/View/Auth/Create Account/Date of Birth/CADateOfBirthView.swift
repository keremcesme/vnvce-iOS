
import SwiftUI
import SwiftUIX
import PureSwiftUI

struct CADateOfBirthView: View {
    @Environment(\.dismiss) public var dismiss
    
    @EnvironmentObject public var authVM: AuthViewModel
    
    @State public var minDate = Calendar.current.date(byAdding: .year, value: -13, to: Date())!
    
    public func continueButtonAction() {
        authVM.showUsernameView = true
    }
    
    var body: some View {
        ZStack(alignment: .top, content: BodyView)
            .navigationTitle("Date of Birth")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarBackButtonHidden(true)
            .toolbar(ToolBar)
    }
    
    @ViewBuilder
    private func BodyView() -> some View {
        ColorfulBackgroundView()
        VStack(alignment: .leading, spacing: 10) {
            Description
            DatePickerView
            Spacer()
            ContinueButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 18)
    }
}
