
import SwiftUI
import SwiftUIX
import PureSwiftUI

extension MomentOutputView {
    
    @ViewBuilder
    public var NavigationBar: some View {
        GeometryReader {
            let height = $0.size.height
            HStack(spacing: 15){
                _BackButton(height: height)
                Spacer()
                _SaveButton(height: height)
            }
            .disabled(shareMomentVM.showAudienceSheet)
            .opacity(shareMomentVM.showAudienceSheet ? 0.5 : 1)
            .overlay(alignment: .top) { AudienceButton(height: height) }
        }
        .frame(height: homeVM.navBarHeight)
        .padding(.horizontal, 20)
        .yOffsetToYPositionIf(keyboardController.isShowed, -(homeVM.navBarHeight + UIDevice.current.statusBarHeight()))
        .opacity(shareMomentVM.viewWillAppear ? 1 : 0.0001)
    }
    
    @ViewBuilder
    private func _BackButton(height: CGFloat) -> some View {
        
        Button {
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            Task{
                await shareMomentVM.deinitView(false)
                cameraManager.capturedPhoto = nil
                cameraManager.outputDidShowed = false
                cameraManager.outputWillShowed = false
            }
        } label: {
            Image(systemName: "xmark")
                .foregroundColor(.primary)
                .font(.system(size: 24, weight: .medium, design: .default))
                .frame(width: height, height: height)
                .contentShape(Rectangle())
        }
        .buttonStyle(.scaled)
    }
    
    @ViewBuilder
    private func _SaveButton(height: CGFloat) -> some View {
        Button {
            Task{ await shareMomentVM.saveImage() }
        } label: {
            Group {
                if shareMomentVM.imageDidSaved {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.primary)
                        .font(.system(size: 20))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                shareMomentVM.resetSaveImageValues()
                            }
                        }
                } else if shareMomentVM.imageIsSaving {
                    ProgressView()
                } else {
                    Image("save")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.primary)
                }
            }
            .frame(26, 26, .center)
            .contentShape(Rectangle())
        }
        .buttonStyle(.scaled)
        .disabled(shareMomentVM.imageIsSaving || shareMomentVM.imageDidSaved)
        .animation(.default, value: shareMomentVM.imageDidSaved)
        .animation(.default, value: shareMomentVM.imageIsSaving)
    }
}
