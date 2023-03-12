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
        
        let previousIndexPath = self.indexPathsForVisibleRows?.last(where: {$0 < lastAvatarIndexPath})
        let lastAvatarData = dataDelegate.gx_tableView(self, avatarDataForRowAt: lastAvatarIndexPath)
        
        if self.hoverAvatarData?.gx_senderId != lastAvatarData.gx_senderId {
            self.gx_resetPreEndAvatar()
            let avatar = lastAvatarCell.createAvatarView()
            dataDelegate.gx_tableView(self, changeForRowAt: lastAvatarIndexPath, avatar: avatar)
            let avatarOrigin = CGPoint(x: lastAvatarCell.avatar.left, y: lastAvatarCell.bottom - lastAvatarCell.avatar.height)
            avatar.frame = CGRect(origin: avatarOrigin, size: lastAvatarCell.avatar.size)
            self.addSubview(avatar)
            self.hoverAvatarData = lastAvatarData
            self.hoverAvatar = avatar
        }
        else if (self.hoverAvatarData?.gx_messageStatus == lastAvatarData.gx_messageStatus && self.hoverAvatarData?.gx_messageStatus == .sending) {
            self.gx_resetPreEndAvatar()
            let avatar = lastAvatarCell.createAvatarView()
            dataDelegate.gx_tableView(self, changeForRowAt: lastAvatarIndexPath, avatar: avatar)
            let avatarHeight = lastAvatarCell.height - lastAvatarCell.avatar.top
            let avatarOrigin = CGPoint(x: lastAvatarCell.avatar.left, y: lastAvatarCell.bottom - avatarHeight)
            avatar.frame = CGRect(origin: avatarOrigin, size: lastAvatarCell.avatar.size)
            self.addSubview(avatar)
            self.hoverAvatarData = lastAvatarData
            self.hoverAvatar = avatar
            
            if lastAvatarData.gx_messageContinuousStatus == .end || lastAvatarData.gx_messageContinuousStatus == .beginAndEnd {
                lastAvatarCell.avatar.isHidden = true
                self.lastHiddenIndexPath = lastAvatarIndexPath
            }
        }
        else {
            guard let preIndexPath = previousIndexPath else { return }
            if self.cellForRow(at: preIndexPath) is GXMessagesAvatarCellProtocol {
                if lastAvatarData.gx_messageContinuousStatus == .end || lastAvatarData.gx_messageContinuousStatus == .beginAndEnd {
                    lastAvatarCell.avatar.isHidden = true
                    self.lastHiddenIndexPath = lastAvatarIndexPath
                }
            }
            else {
                self.gx_resetPreEndAvatar()
                let hoverAvatar = lastAvatarCell.createAvatarView()
                dataDelegate.gx_tableView(self, changeForRowAt: lastAvatarIndexPath, avatar: hoverAvatar)
                let avatarHeight = lastAvatarCell.height - lastAvatarCell.avatar.top
                let avatarOrigin = CGPoint(x: lastAvatarCell.avatar.left, y: lastAvatarCell.bottom - avatarHeight)
                hoverAvatar.frame = CGRect(origin: avatarOrigin, size: lastAvatarCell.avatar.size)
                self.addSubview(hoverAvatar)
                self.hoverAvatarData = lastAvatarData
                self.hoverAvatar = hoverAvatar
            }
        }
        
        guard let avatar = self.hoverAvatar else { return }
        let avatarHeight = lastAvatarCell.height - lastAvatarCell.avatar.top + self.topDifference
        let cellRect = self.rectForRow(at: lastAvatarIndexPath)
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
            guard let preIndexPath = previousIndexPath else { return }
            let preAvatarData = dataDelegate.gx_tableView(self, avatarDataForRowAt: preIndexPath)
            if self.cellForRow(at: preIndexPath) is GXMessagesAvatarCellProtocol &&
                (preAvatarData.gx_messageContinuousStatus != .end && preAvatarData.gx_messageContinuousStatus != .beginAndEnd) &&
                lastAvatarIndexPath.section == preIndexPath.section {
                avatar.top = self.height - avatarHeight + self.contentOffset.y + self.topDifference
            }
            else {
                avatar.top = cellRect.minY + self.topDifference
            }
        }
    }
    
    func gx_resetPreEndAvatar() {
        self.hoverAvatar?.removeFromSuperview()
        if let preEndIndexPath = self.lastHiddenIndexPath,
           let preEndCell = self.cellForRow(at: preEndIndexPath) as? GXMessagesAvatarCellProtocol {
            let preEndAvatarData = self.datalist?.gx_tableView(self, avatarDataForRowAt: preEndIndexPath)
            if preEndAvatarData?.gx_messageContinuousStatus == .end || preEndAvatarData?.gx_messageContinuousStatus == .beginAndEnd {
                preEndCell.avatar.isHidden = false
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
