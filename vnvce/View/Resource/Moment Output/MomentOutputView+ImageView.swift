
import SwiftUI
import SwiftUIX
import PureSwiftUI

extension MomentOutputView {
    func keyboardOffset() -> CGFloat {
        let safeArea = UIScreen.main.bounds.height - keyboardController.height - momentsStore.momentSize.height / 2 - 15
        return safeArea
    }
    
    private func scaleAmount() -> CGFloat {
        if shareMomentVM.viewWillDisappear {
            return 36 / UIScreen.main.bounds.width * 3 / 2
        } else {
            return 1
        }
    }
    
    @ViewBuilder
    public var ImageView: some View {
        Image(uiImage: capturedPhoto.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(momentsStore.momentSize)
            .clipped()
            .cornerRadius(25)
            .onTapGesture(perform: hideKeyboard)
            .overlay(alignment: .bottom, content: AddMessageField)
            .scaleEffect(scaleAmount())
            .mask(Mask)
            .yOffsetToYPositionIf(keyboardController.isShowed, keyboardOffset())
            .offsetToPositionIf(shareMomentVM.viewWillDisappear, shareMomentVM.animationRect.origin)
            .animation(.easeInOut(duration: keyboardController.duration), value: keyboardController.isShowed)
    }
    
    @ViewBuilder
    private var Mask: some View {
        RoundedRectangle(cornerRadius: shareMomentVM.viewWillDisappear ?
                         100 : 25,
                         style: .circular)
        .frame(shareMomentVM.viewWillDisappear ? shareMomentVM.animationRect.size : momentsStore.momentSize)
    }
}
