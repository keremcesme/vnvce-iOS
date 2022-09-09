//
//  RefreshableScrollView.swift
//  vnvce
//
//  Created by Kerem Cesme on 7.09.2022.
//

import SwiftUI
import Introspect

struct RefreshableScrollView<Content: View>: View {
    
    @StateObject var controller = RefreshController()
    
    var spacing: CGFloat
    var content: Content
    var onRefresh: @Sendable (_ completion: @escaping () -> Void) -> Void
    
    init(
        spacing: CGFloat = 0,
        @ViewBuilder content: @escaping () -> Content,
        onRefresh: @Sendable @escaping (_ completion: @escaping () -> Void) -> Void
    ) {
        self.spacing = spacing
        self.content = content()
        self.onRefresh = onRefresh
    }
    
    var body: some View {
        Group {
            if #available(iOS 15.0, *) {
                List {
                    content
                        .listRowSeparatorTint(.clear)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(0, 0, spacing, 0))
                }
                .listStyle(.plain)
                .onRefresh { refreshControl in
                    onRefresh {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            refreshControl.endRefreshing()
                        }
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing:0) {
                        content
                    }
                }
                .onRefreshScroll { refreshControl in
                    onRefresh {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            refreshControl.endRefreshing()
                        }
                    }
                }
//                List {
//                    content
//                        .frame(maxWidth: .infinity, alignment: .center)
////                        .hideListRowSeparator()
//                        .listRowBackground(Color.clear)
//                        .listRowInsets(EdgeInsets(-20, -20, spacing, -20))
//                        .introspectTableViewCell { cell in
//                            cell.backgroundColor = .clear
//                        }
//                }
//                .listStyle(.plain)
                
            }
        }
        
    }
}

class RefreshController: ObservableObject {
    
    func fetch(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }
}


extension UIScrollView {
    
    private struct Keys {
        static var onValueChanged: UInt8 = 0
    }
    
    typealias ValueChangedAction = ((_ refreshControl: UIRefreshControl) -> Void)
    
    private var onValueChanged: ValueChangedAction? {
        get {
            objc_getAssociatedObject(self, &Keys.onValueChanged) as? ValueChangedAction
        }
        set {
            objc_setAssociatedObject(self, &Keys.onValueChanged, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func onRefresh(_ onValueChanged: @escaping ValueChangedAction) {
        if refreshControl == nil {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(
                   self,
                   action: #selector(self.onValueChangedAction),
                   for: .valueChanged
               )
            self.refreshControl = refreshControl
        }
        self.onValueChanged = onValueChanged
    }
    
    @objc private func onValueChangedAction(sender: UIRefreshControl) {
        self.onValueChanged?(sender)
    }
}

struct OnListRefreshModifier: ViewModifier {
    
    let onValueChanged: UIScrollView.ValueChangedAction
    
    func body(content: Content) -> some View {
        content
            .introspectTableView { tableView in
                if #available(iOS 14.0, *) {
                    tableView.backgroundColor = .clear
                    tableView.separatorColor = .clear
                }
                tableView.onRefresh(onValueChanged)
            }
    }
}

struct OnScrollRefreshModifier: ViewModifier {
    
    let onValueChanged: UIScrollView.ValueChangedAction
    
    func body(content: Content) -> some View {
        content
            .introspectScrollView { scrollView in
                scrollView.onRefresh(onValueChanged)
            }
    }
}

extension View {
    
    func onRefresh(onValueChanged: @escaping UIScrollView.ValueChangedAction) -> some View {
        self.modifier(OnListRefreshModifier(onValueChanged: onValueChanged))
    }
    
    func onRefreshScroll(onValueChanged: @escaping UIScrollView.ValueChangedAction) -> some View {
        self.modifier(OnScrollRefreshModifier(onValueChanged: onValueChanged))
    }
}

extension View {
    
    func hideListRowSeparator() -> some View {
        return customListRowSeparator(insets: .init(), insetsColor: .clear)
    }
    
    func customListRowSeparator(
        insets: EdgeInsets,
        insetsColor: Color) -> some View {
        modifier(HideRowSeparatorModifier(insets: insets,
                                          background: insetsColor
        )) .onAppear {
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().separatorColor = .clear
        }
    }
}

// MARK: ViewModifier

private struct HideRowSeparatorModifier: ViewModifier {
        
    var insets: EdgeInsets
    var background: Color
    
    func body(content: Content) -> some View {
        content
            .padding(insets)
            .frame(
                minWidth: 0,
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .leading
            )
            .listRowInsets(EdgeInsets())
            .background(background)
    }
}
