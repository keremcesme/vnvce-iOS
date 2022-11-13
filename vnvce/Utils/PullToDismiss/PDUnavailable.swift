//
//  PDUnavailable.swift
//  vnvce
//
//  Created by Kerem Cesme on 10.11.2022.
//

import UIKit

extension PDPullToDismiss {
    @available(*, unavailable, renamed: "delegate")
    public weak var delegateProxy: AnyObject? {
        fatalError("\(#function) is no longer available")
    }
    
    @available(*, unavailable, message: "unavailable")
    public weak var scrollViewDelegate: UIScrollViewDelegate? {
        fatalError("\(#function) is no longer available")
    }
    
    @available(*, unavailable, message: "unavailable")
    public weak var tableViewDelegate: UITableViewDelegate? {
        fatalError("\(#function) is no longer available")
    }
    
    @available(*, unavailable, message: "unavailable")
    public weak var collectionViewDelegate: UICollectionViewDelegate? {
        fatalError("\(#function) is no longer available")
    }
    
    @available(*, unavailable, message: "unavailable")
    public weak var collectionViewDelegateFlowLayout: UICollectionViewDelegateFlowLayout? {
        fatalError("\(#function) is no longer available")
    }
}
