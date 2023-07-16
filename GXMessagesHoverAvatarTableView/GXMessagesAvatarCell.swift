//
//  GXMessagesAvatarCell.swift
//  GXMessagesTableViewSample
//
//  Created by Gin on 2023/6/11.
//

import UIKit

open class GXMessagesAvatarCell: UITableViewCell {
    open var gx_isEditing: Bool = false

    open lazy var gx_checkmarkIcon: UIImageView = {
        let imageView = UIImageView(image: self.gx_checkmarkImage(false), highlightedImage: self.gx_checkmarkImage(true))
        let left = (GXMessagesHoverAvatarTableView.GXEditViewWidth - 30)/2
        imageView.frame = CGRect(x: left, y: 0, width: 30, height: 30)
        
        return imageView
    }()
    open lazy var gx_checkmarkView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: -GXMessagesHoverAvatarTableView.GXEditViewWidth, y: 0, width: GXMessagesHoverAvatarTableView.GXEditViewWidth, height: 30)
        view.addSubview(self.gx_checkmarkIcon)
        
        return view
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        self.contentView.addSubview(self.gx_checkmarkView)
        NotificationCenter.default.addObserver(self, selector: #selector(gx_editNotification), name: GXMessagesHoverAvatarTableView.GXEditNotification, object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.gx_checkmarkIcon.isHighlighted = selected
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        
        self.gx_checkmarkView.centerY = self.contentView.centerY
    }
        
    open func gx_setEditing(_ editing: Bool, animated: Bool) {
        self.gx_isEditing = editing
        if editing {
            self.contentView.addSubview(self.gx_checkmarkView)
            var checkmarkViewFrame = self.gx_checkmarkView.frame
            checkmarkViewFrame.origin.x = 0
            if animated {
                UIView.animate(withDuration: GXMessagesHoverAvatarTableView.GXEditAnimateDuration) {
                    self.gx_checkmarkView.frame = checkmarkViewFrame
                }
            }
            else {
                self.gx_checkmarkView.frame = checkmarkViewFrame
            }
        }
        else {
            var checkmarkViewFrame = self.gx_checkmarkView.frame
            checkmarkViewFrame.origin.x = -GXMessagesHoverAvatarTableView.GXEditViewWidth
            if animated {
                UIView.animate(withDuration: GXMessagesHoverAvatarTableView.GXEditAnimateDuration) {
                    self.gx_checkmarkView.frame = checkmarkViewFrame
                } completion: { finished in
                    self.gx_checkmarkView.removeFromSuperview()
                }
            }
            else {
                self.gx_checkmarkView.frame = checkmarkViewFrame
                self.gx_checkmarkView.removeFromSuperview()
            }
        }
    }
    
}

private extension GXMessagesAvatarCell {
    
    @objc private func gx_editNotification(notification: NSNotification) {
        if let object = notification.object as? [String: Bool] {
            let editing = object[GXMessagesHoverAvatarTableView.GXEditIsEditingKey] ?? false
            let animated = object[GXMessagesHoverAvatarTableView.GXEditIsAnimatedKey] ?? false
            self.gx_setEditing(editing, animated: animated)
        }
    }
    
    func gx_checkmarkImage(_ checked: Bool) -> UIImage? {
        if checked {
            return UIImage(systemName: "checkmark.circle.fill")
        }
        else {
            return UIImage(systemName: "circle")
        }
    }
    
}
