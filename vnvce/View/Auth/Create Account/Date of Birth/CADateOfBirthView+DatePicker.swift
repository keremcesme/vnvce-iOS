
import SwiftUI

extension CADateOfBirthView {
    @ViewBuilder
    public var DatePickerView: some View {
        VStack(spacing: 10){
            Group {
                Text("\(authVM.dateOfBirth.formatted(date: .long, time: .omitted))")
                    .font(.system(size: 22, weight: .bold))
                    .adjustsFontSizeToFitWidth(true)
                    .frame(maxWidth: UIScreen.main.bounds.width, alignment: .center)
                    .frame(height: 60)
                    .padding(.horizontal, 15)
                DatePicker("", selection: $authVM.dateOfBirth, in: ...minDate, displayedComponents: .date)
                .datePickerStyle(.wheel)
                .xOffset(-10)
            }
            .background {
                RoundedRectangle(12, style: .continuous)
                    .foregroundColor(.primary)
                    .opacity(0.05)
            }
        }
        .padding(.top, 5)
    }
}
