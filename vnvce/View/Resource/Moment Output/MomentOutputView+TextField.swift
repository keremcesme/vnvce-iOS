
import SwiftUI
import SwiftUIX
import PureSwiftUI

extension MomentOutputView {
    @ViewBuilder
    public func AddMessageField() -> some View {
        ZStack {
            BlurView(style: .dark)
                .frame(textHelper.bgSize)
                .clipShape(Capsule())
            
            TextFieldUI(vm: textHelper)
                .frame(textHelper.bgSize)
        }
        .padding(.bottom, 15)
        .opacity(shareMomentVM.viewWillAppear ? 1 : 0.0001)
    }
}

extension MomentOutputView {
    class TextHelper: ObservableObject {
        @Published public var text: String = ""
        @Published public var bgSize: CGSize
        
        public let placeholderText = "Add a message"
        public let placeholderWidth: CGFloat
        
        public let textField = UITextField()
        
        init() {
            textField.placeholder = placeholderText
            textField.text = placeholderText
            textField.textColor = .white
            textField.placeholderColor = .white
            textField.textAlignment = .center
            textField.backgroundColor = nil
            textField.font = .rounded(ofSize: 17, weight: .semibold)
            textField.autocorrectionType = .no
            textField.frame.size.height = 40
            textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            
            let width = (textField.attributedText?.size().width)! + 30
            placeholderWidth = width
            bgSize = .init(width, 40)
            
            textField.text = nil
        }
    }
    
    struct TextFieldUI: UIViewRepresentable {
        @StateObject var vm: TextHelper
        
        let textView = UITextView()
        
        init(vm: TextHelper) {
            self._vm = StateObject(wrappedValue: vm)
        }
        
        func makeUIView(context: Context) -> UITextField {
            vm.textField.delegate = context.coordinator
            vm.textField.addTarget(
                context.coordinator,
                action: #selector(Coordinator.textFieldDidChange),
                for: .editingChanged)
            
            return vm.textField
        }
        
        func updateUIView(_ textView: UITextField, context: Context) {}
        
        func makeCoordinator() -> Coordinator {
            return Coordinator(self)
        }
        
        class Coordinator: NSObject, UITextFieldDelegate {
            var parent: TextFieldUI
            
            init(_ parent: TextFieldUI){
                self.parent = parent
            }
            
            func textFieldDidBeginEditing(_ textField: UITextField) {
                textField.placeholderColor = .lightGray
                let newPosition = textField.endOfDocument
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            
            func textFieldDidEndEditing(_ textField: UITextField) {
                textField.placeholderColor = .white
            }
            
            @objc
            func textFieldDidChange() {
                let currentWidth = parent.vm.bgSize.width
                if let text = parent.vm.textField.text {
                    parent.vm.text = text
                    if text != "" {
                        if currentWidth < UIScreen.main.bounds.width - 40 {
                            let width = (parent.vm.textField.attributedText?.size().width)! + 30
                            parent.vm.bgSize.width = width
                        }
                    } else {
                        parent.vm.bgSize.width = parent.vm.placeholderWidth
                    }
                } else {
                    parent.vm.bgSize.width = parent.vm.placeholderWidth
                }
            }
        }
        
    }
}
    

