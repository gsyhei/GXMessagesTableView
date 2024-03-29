//
//  GXMessagesTableView.swift
//  GXChatUIKit
//
//  Created by Gin on 2023/3/6.
//

import UIKit

public protocol GXMessagesHoverAvatarTableViewDatalist: NSObjectProtocol {
    func gx_tableView(_ tableView: UITableView, avatarDataForRowAt indexPath: IndexPath) -> GXMessagesAvatarDataProtocol
    func gx_tableView(_ tableView: UITableView, changeForRowAt indexPath: IndexPath, avatar: UIView)
}

public class GXMessagesHoverAvatarTableView: GXMessagesLoadTableView {
    public weak var datalist: GXMessagesHoverAvatarTableViewDatalist?
    public var topDifference: CGFloat = 5.0
    public var avatarToCellIndexPath: IndexPath? {
        return self.toCellIndexPath
    }
    public var hoverToCellAvatar: UIView? {
        return self.hoverAvatar
    }
    
    private var reusableAvatars: [UIView] = []
    private var toCellIndexPath: IndexPath?
    private var hoverAvatar: UIView?
    private var hoverAvatarData: GXMessagesAvatarDataProtocol?
    private var hoverAvatarIndexPath: IndexPath?
    private var lastHiddenIndexPath: IndexPath?
    
    private var gx_editingAnimated: Bool = false
    private let gx_editAnimateDuration: TimeInterval = 0.3
    

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
    
    public override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.gx_editingAnimated = animated
        self.gx_changeContentOffset(self.contentOffset)
        self.gx_editingAnimated = false
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

private extension GXMessagesHoverAvatarTableView {
    
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
        if let avatar = self.hoverAvatar {
            self.reusableAvatars.append(avatar)
        }
        self.hoverAvatar?.removeFromSuperview()
        
        guard let preEndIndexPath = self.lastHiddenIndexPath else { return }
        guard let preEndCell = self.cellForRow(at: preEndIndexPath) as? GXMessagesAvatarCellProtocol else { return }
        
        let preEndAvatarData = self.datalist?.gx_tableView(self, avatarDataForRowAt: preEndIndexPath)
        if preEndAvatarData?.gx_continuousEnd ?? false {
            preEndCell.gx_avatar.isHidden = false
        }
    }
    
    func gx_addLastHoverAvatar(cell: GXMessagesAvatarCellProtocol, indexPath: IndexPath, data: GXMessagesAvatarDataProtocol) {
        self.gx_resetPreEndAvatar()
        
        let avatar = self.gx_dequeueReusableAvatar(cell)
        self.datalist?.gx_tableView(self, changeForRowAt: indexPath, avatar: avatar)
        let avatarHeight = cell.height - cell.gx_avatar.top
        let avatarLeft = cell.gx_avatar.left + cell.left + cell.contentView.left
        let avatarOrigin = CGPoint(x: avatarLeft, y: cell.bottom - avatarHeight)
        avatar.frame = CGRect(origin: avatarOrigin, size: cell.gx_avatar.size)
        self.addSubview(avatar)
        self.hoverAvatarData = data
        self.hoverAvatar = avatar
        self.hoverAvatarIndexPath = indexPath
    }
    
    func gx_setPointLastHoverAvatar(cell: GXMessagesAvatarCellProtocol, indexPath: IndexPath, data: GXMessagesAvatarDataProtocol) {
        if data.gx_continuousEnd {
            cell.gx_avatar.isHidden = true
            self.lastHiddenIndexPath = indexPath
        }
        
        guard let avatar = self.hoverAvatar else { return }
        let avatarLeft = cell.gx_avatar.left + cell.left + cell.contentView.left
        if avatarLeft != avatar.left {
            if self.gx_editingAnimated {
                UIView.animate(withDuration: self.gx_editAnimateDuration) {
                    avatar.left = avatarLeft
                }
            } else {
                avatar.left = avatarLeft
            }
        }
        let avatarHeight = cell.height - cell.gx_avatar.top + self.topDifference
        let cellRect = self.rectForRow(at: indexPath)
        let cellTop = cellRect.minY - self.contentOffset.y
        let cellBottom = cellRect.maxY - self.contentOffset.y
        let tDifference = self.height - cellTop
        let bDifference = self.height - cellBottom
        
        self.toCellIndexPath = indexPath
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
            if self.cellForRow(at: preIndexPath) is GXMessagesAvatarCellProtocol
                && !(preAvatarData?.gx_continuousEnd ?? false)
                && preIndexPath.section == indexPath.section
            {
                avatar.top = self.height - avatarHeight + self.contentOffset.y + self.topDifference
                if avatar.frame.midY - self.contentOffset.y < cellTop {
                    self.toCellIndexPath = preIndexPath
                }
            }
            else {
                avatar.top = cellRect.minY + self.topDifference
            }
        }
    }
    
    func gx_dequeueReusableAvatar(_ cell: GXMessagesAvatarCellProtocol) -> UIView {
        if let avatar = self.reusableAvatars.first {
            self.reusableAvatars.removeFirst()
            return avatar
        }
        return cell.gx_createAvatarView()
    }
    
    func gx_scrollHeaderAnimate(header: UIView?, hidden: Bool) {
        let alpha = hidden ? 0.0 : 1.0
        UIView.animate(withDuration: 0.25) {
            header?.alpha = alpha
        }
    }
    
}
