//
//  GXMessagesLoadHeader.swift
//  GXChatUIKit
//
//  Created by Gin on 2022/12/25.
//

import UIKit
import GXRefresh

public class GXMessagesLoadHeader: GXRefreshBaseHeader {
    
    public var headerMargin: CGFloat = 5.0
    
    private lazy var indicatorView = {
        let aiView: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            aiView = UIActivityIndicatorView(style: .medium)
        } else {
            aiView = UIActivityIndicatorView(style: .white)
        }
        let size: CGFloat  = self.gx_height - headerMargin * 2;
        aiView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        aiView.color = .gray
        return aiView
    }()
    
    private lazy var headerView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: self.gx_height))
        view.backgroundColor = .clear
        view.addSubview(self.indicatorView)
        self.indicatorView.center = CGPoint(x: view.center.x, y: view.center.y)
        self.indicatorView.startAnimating()
        
        return view
    }()
    
    public override var customIndicator: UIView {
        return self.headerView
    }
        
    public override func scrollViewContentOffsetDidChange(change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change: change)
        guard self.state == .idle else { return }
        
        if (self.svContentOffset.y + self.svAdjustedInset.top < -10) {
            self.beginRefreshing()
        }
    }

}
