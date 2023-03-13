//
//  GXMessagesTableView.swift
//  GXChatUIKit
//
//  Created by Gin on 2023/3/6.
//

import UIKit

public protocol GXMessagesTableViewDatalist: NSObjectProtocol {
    func gx_tableView(_ tableView: UITableView, avatarDataForRowAt indexPath: IndexPath) -> GXMessagesAvatarDataProtocol
    func gx_tableView(_ tableView: UITableView, changeForRowAt indexPath: IndexPath, avatar: UIView)
}

public class GXMessagesTableView: GXMessagesLoadTableView {
    public weak var datalist: GXMessagesTableViewDatalist?
    public var topDifference: CGFloat = 5.0
    
    private var hoverAvatar: UIView?
    private var hoverAvatarData: GXMessagesAvatarDataProtocol?
    private var hoverAvatarIndexPath: IndexPath?
    private var lastHiddenIndexPath: IndexPath?
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super .init(frame: frame, style: style)
        self.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let offset = change?[NSKeyValueChangeKey.newKey] as? CGPoint {
                DispatchQueue.main.async {
                    self.gx_changeContentOffset(offset)
                }
            }
        }
    }
    
    public func gx_scrollBeginDragging() {
        guard let fristIndexPath = self.indexPathsForVisibleRows?.first else { return }
        
        let header = self.headerView(forSection: fristIndexPath.section)
        self.gx_scrollHeaderAnimate(header: header, hidden: false)
    }
    
    public func gx_scrollEndDragging() {
        guard let fristIndexPath = self.indexPathsForVisibleRows?.first else { return }
        
        let headerRect = self.rectForHeader(inSection: fristIndexPath.section)
        let headerTop = self.contentOffset.y + self.adjustedContentInset.top - headerRect.origin.y
        
        if fristIndexPath.row > 0 || headerTop > headerRect.height*0.8 {
            let header = self.headerView(forSection: fristIndexPath.section)
            self.gx_scrollHeaderAnimate(header: header, hidden: true)
        }
    }
    
}

private extension GXMessagesTableView {
    
    func gx_changeContentOffset(_ offset: CGPoint) {
        guard let dataDelegate = self.datalist else { return }
        let lastCell = self.visibleCells.last(where: {$0 is GXMessagesAvatarCellProtocol})
        guard let lastAvatarCell = lastCell as? GXMessagesAvatarCellProtocol else { return }
        guard let lastAvatarIndexPath = self.indexPath(for: lastAvatarCell) else { return }
        let lastAvatarData = dataDelegate.gx_tableView(self, avatarDataForRowAt: lastAvatarIndexPath)
        
        // 悬浮头像与显示的最后一个头像不同
        if self.hoverAvatarData?.gx_senderId != lastAvatarData.gx_senderId {
            self.gx_addLastHoverAvatar(cell: lastAvatarCell, indexPath: lastAvatarIndexPath, data: lastAvatarData)
        }
        // 悬浮头像与显示的最后一个头像的section不同
        else if (self.hoverAvatarIndexPath?.section != lastAvatarIndexPath.section) {
            self.gx_addLastHoverAvatar(cell: lastAvatarCell, indexPath: lastAvatarIndexPath, data: lastAvatarData)
        }
        // 悬浮头像与显示的最后一个头像相同，且section也相同
        else {
            if self.hoverAvatarIndexPath != lastAvatarIndexPath {
                if self.indexPathsForVisibleRows?.last != lastAvatarIndexPath {
                    self.gx_addLastHoverAvatar(cell: lastAvatarCell, indexPath: lastAvatarIndexPath, data: lastAvatarData)
                }
            }
        }
        self.gx_setPointLastHoverAvatar(cell: lastAvatarCell, indexPath: lastAvatarIndexPath, data: lastAvatarData)
    }
    
    func gx_resetPreEndAvatar() {
        self.hoverAvatar?.removeFromSuperview()
        
        guard let preEndIndexPath = self.lastHiddenIndexPath else { return }
        guard let preEndCell = self.cellForRow(at: preEndIndexPath) as? GXMessagesAvatarCellProtocol else { return }
        
        let preEndAvatarData = self.datalist?.gx_tableView(self, avatarDataForRowAt: preEndIndexPath)
        if preEndAvatarData?.gx_messageContinuousStatus == .end || preEndAvatarData?.gx_messageContinuousStatus == .beginAndEnd {
            preEndCell.avatar.isHidden = false
        }
    }
    
    func gx_addLastHoverAvatar(cell: GXMessagesAvatarCellProtocol, indexPath: IndexPath, data: GXMessagesAvatarDataProtocol) {
        self.gx_resetPreEndAvatar()
        
        let avatar = cell.createAvatarView()
        self.datalist?.gx_tableView(self, changeForRowAt: indexPath, avatar: avatar)
        let avatarHeight = cell.height - cell.avatar.top
        let avatarOrigin = CGPoint(x: cell.avatar.left, y: cell.bottom - avatarHeight)
        avatar.frame = CGRect(origin: avatarOrigin, size: cell.avatar.size)
        self.addSubview(avatar)
        self.hoverAvatarData = data
        self.hoverAvatar = avatar
        self.hoverAvatarIndexPath = indexPath
    }
    
    func gx_setPointLastHoverAvatar(cell: GXMessagesAvatarCellProtocol, indexPath: IndexPath, data: GXMessagesAvatarDataProtocol) {
        if data.gx_messageContinuousStatus == .end || data.gx_messageContinuousStatus == .beginAndEnd {
            cell.avatar.isHidden = true
            self.lastHiddenIndexPath = indexPath
        }
        
        guard let avatar = self.hoverAvatar else { return }
        let avatarHeight = cell.height - cell.avatar.top + self.topDifference
        let cellRect = self.rectForRow(at: indexPath)
        let cellTop = cellRect.minY - self.contentOffset.y
        let cellBottom = cellRect.maxY - self.contentOffset.y
        let tDifference = self.height - cellTop
        let bDifference = self.height - cellBottom
        
        if tDifference >= avatarHeight {
            if bDifference <= 0 {
                avatar.top = self.height - avatarHeight + self.contentOffset.y + self.topDifference
            }
            else {
                avatar.top = cellRect.maxY - avatarHeight + self.topDifference
            }
        }
        else {
            guard let preIndexPath = self.indexPathsForVisibleRows?.last(where: {$0 < indexPath}) else { return }
            let preAvatarData = self.datalist?.gx_tableView(self, avatarDataForRowAt: preIndexPath)
            if self.cellForRow(at: preIndexPath) is GXMessagesAvatarCellProtocol &&
                (preAvatarData?.gx_messageContinuousStatus != .end && preAvatarData?.gx_messageContinuousStatus != .beginAndEnd) &&
                preIndexPath.section == indexPath.section
            {
                avatar.top = self.height - avatarHeight + self.contentOffset.y + self.topDifference
            }
            else {
                avatar.top = cellRect.minY + self.topDifference
            }
        }
    }
    
    func gx_scrollHeaderAnimate(header: UIView?, hidden: Bool) {
        let alpha = hidden ? 0.0 : 1.0
        UIView.animate(withDuration: 0.25) {
            header?.alpha = alpha
        }
    }
    
}
