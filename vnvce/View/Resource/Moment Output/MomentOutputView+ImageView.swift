
import SwiftUI
import SwiftUIX
import PureSwiftUI

extension MomentOutputView {
    func keyboardOffset() -> CGFloat {
        let safeArea = UIScreen.main.bounds.height - keyboardController.height - homeVM.contentSize.height / 2 - 15
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
        Image(uiImage: shareMomentVM.capturedPhoto.image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(homeVM.contentSize)
            .clipped()
//            .cornerRadius(25)
            .onTapGesture(perform: hideKeyboard)
            .overlay(alignment: .bottom, content: AddMessageField)
            .scaleEffect(scaleAmount())
            .mask(Mask)
            .yOffsetToYPositionIf(keyboardController.isShowed, keyboardOffset())
            .offsetToPositionIf(shareMomentVM.viewWillDisappear, currentUserVM.myMomentsRect.origin)
            .animation(.easeInOut(duration: keyboardController.duration), value: keyboardController.isShowed)
    }
    
    @ViewBuilder
    private var Mask: some View {
        RoundedRectangle(cornerRadius: shareMomentVM.viewWillDisappear ?
                         100 : 0,
                         style: .circular)
        .frame(shareMomentVM.viewWillDisappear ? currentUserVM.myMomentsRect.size : homeVM.contentSize)
    }
}
