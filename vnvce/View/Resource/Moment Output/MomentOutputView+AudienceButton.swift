
import SwiftUI
import CoreLocation
import VNVCECore

extension MomentOutputView {
    
    private func onChangeLocationAuthorizationStatus(_ status: CLAuthorizationStatus) {
        onChangeAuthorization(status, locationManager.accuracyAuthorization)
    }
    
    private func onChangeLocationAccuracyAuthorization(_ status: CLAccuracyAuthorization) {
        onChangeAuthorization(locationManager.authorizationStatus, status)
    }
    
    private func onChangeScenePhase(_ scene: ScenePhase) {
        if scene == .active {
            let authorization = locationManager.authorizationStatus
            let accuracy = locationManager.accuracyAuthorization
            onChangeAuthorization(authorization, accuracy)
        }
    }
    
    private func onChangeAuthorization(_ authorization: CLAuthorizationStatus, _ accuracy: CLAccuracyAuthorization) {
        if shareMomentVM.selectedAudience == .nearby {
            if accuracy == .reducedAccuracy || (authorization != .authorizedAlways && authorization != .authorizedWhenInUse) {
                shareMomentVM.selectedAudience = .friendsOnly
            }
        }
    }
    
    private var nearbyIsAvailable: Bool {
        guard locationManager.accuracyAuthorization == .fullAccuracy else {
            return false
        }
        switch locationManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
    
    private var showNearbyOpenSettings: Bool {
        if locationManager.authorizationStatus == .denied || locationManager.accuracyAuthorization == .reducedAccuracy {
            return true
        } else {
            return false
        }
    }
    
    private func returnOpacity(_ type: MomentAudience) -> Double {
        return shareMomentVM.selectedAudience == type ? 1 : 0.65
    }
    
    private func buttonAction(_ type: MomentAudience) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        shareMomentVM.selectedAudience = type
        if type == .nearby {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestAuthorization()
            } else if showNearbyOpenSettings {
                shareMomentVM.showLocationAlert = true
            }
        }
    }
    
    @ViewBuilder
    public func AudienceButton(height: CGFloat) -> some View {
        VStack(spacing:20) {
            Button {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                shareMomentVM.showAudienceSheet = !shareMomentVM.showAudienceSheet
            } label: {
                HStack(spacing: 3){
                    Group {
                        if shareMomentVM.showAudienceSheet {
                            Text("Audience")
                                .opacity(0.65)
                        } else {
                            Text(shareMomentVM.selectedAudience.title)
                        }
                    }
                    .foregroundColor(.white)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .lineLimit(1)
                    .transition(.scale(scale: 0).combined(with: .opacity))
                    
                    Image(systemName: "chevron.down")
                        .foregroundColor(.white).opacity(0.65)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .rotationEffect(.degrees(shareMomentVM.showAudienceSheet ? 180 : 0))
                }
                .padding(.horizontal, 12.5)
                .background {
                    Capsule()
                        .fill(.ultraThinMaterial)
                        .frame(height: height)
                }
                .frame(height: height)
            }
            .buttonStyle(.scaled)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.66)
            
            if shareMomentVM.showAudienceSheet {
                AudienceSheetView
            }
        }
        .onChange(of: locationManager.authorizationStatus, perform: onChangeLocationAuthorizationStatus)
        .onChange(of: locationManager.accuracyAuthorization, perform: onChangeLocationAccuracyAuthorization)
        .onChange(of: appState.scenePhase, perform: onChangeScenePhase)
    }
    
    @ViewBuilder
    private var AudienceSheetView: some View {
        VStack(spacing: 15){
            VStack(alignment: .leading, spacing: 0){
                VStack(alignment: .leading, spacing: 2) {
                    AudienceCell(.friendsOnly)
                    AudienceCell(.friendsOfFriends)
                    AudienceCell(.nearby)
                }
                .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .leading)
                .cornerRadius(27.5)
                .padding(4)
                AudienceDescription
            }
            .background(.thinMaterial)
            .preferredColorScheme(.dark)
            .cornerRadius(31)
        }
        .transition(.scale(scale: 0, anchor: .top).combined(with: .opacity))
        .alert("Need Permission", isPresented: $shareMomentVM.showLocationAlert) {
            Button("Cancel") {
                shareMomentVM.selectedAudience = .friendsOnly
            }
            Button("Open Settings") {
                locationManager.openSettings()
            }
        } message: {
            Text("Open settings. Tap the location. Select 'While Using the App' and turn on 'Percise Location'.")
        }
        .preferredColorScheme(.dark)

    }
    
    @ViewBuilder
    private func AudienceCell(_ type: MomentAudience) -> some View {
        Button {
            buttonAction(type)
        } label: {
            HStack(spacing: 12.5){
                Circle()
                    .fill(.white.opacity(0.1))
                    .colorScheme(.dark)
                    .frame(UIDevice.current.navigationBarHeight)
                    .overlay {
                        Image(systemName: type == .nearby && !nearbyIsAvailable ? "location.slash.fill" : type.icon)
                            .foregroundColor(.white).opacity(returnOpacity(type))
                            .font(.system(size: 18, weight: .medium, design: .default))
                    }
                VStack(alignment: .leading) {
                    Text(type.title)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                    if type == .nearby && (locationManager.authorizationStatus == .notDetermined || showNearbyOpenSettings) {
                        Text("Permission needed")
                            .font(.system(size: 9, weight: .regular, design: .rounded))
                            .lineLimit(2)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
                .foregroundColor(.white).opacity(returnOpacity(type))
                Spacer()
                if type == .nearby && (locationManager.authorizationStatus == .notDetermined || showNearbyOpenSettings) {
                    Group {
                        if locationManager.authorizationStatus == .notDetermined {
                            Text("Allow")
                        } else if showNearbyOpenSettings {
                            Text("Open Settings")
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.system(size: 9, weight: .semibold, design: .default))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7.5)
                    .background(Capsule().fill(.white.opacity(0.1)))
                } else {
                    Image(systemName: shareMomentVM.selectedAudience == type ? "smallcircle.filled.circle.fill" : "circle")
                        .foregroundColor(.white).opacity(returnOpacity(type))
                        .font(.system(size: 22, weight: .regular, design: .default))
                }
                
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.scaled)
        .padding(10)
        .background(.white.opacity(0.1))
        
    }
    
    @ViewBuilder
    private var AudienceDescription: some View {
        Text(shareMomentVM.selectedAudience.description)
            .foregroundColor(.white).opacity(0.55)
            .font(.system(size: 11, weight: .regular, design: .rounded))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.top, 2.5)
            .padding(.bottom, 7.5)
            .padding(.horizontal, 15)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: .center)
    }
}
