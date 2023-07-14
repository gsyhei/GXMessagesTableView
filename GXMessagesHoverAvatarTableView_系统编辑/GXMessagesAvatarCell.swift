//
//  GXMessagesAvatarCell.swift
//  GXMessagesTableViewSample
//
//  Created by Gin on 2023/6/11.
//

import UIKit

open class GXMessagesAvatarCell: UITableViewCell {
    open var gx_editControl: UIView?
    open lazy var gx_checkmarkView: UIImageView = {
        let imageView = UIImageView(image: self.gx_checkmarkImage(false), highlightedImage: self.gx_checkmarkImage(true))
        imageView.frame = CGRect(x: -100, y: 0, width: 30, height: 30)
        
        return imageView
    }()
    
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.contentView.addSubview(self.gx_checkmarkView)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        self.gx_checkmarkView.isHighlighted = selected
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        let editControlWidth = self.contentView.left
        var rect = self.gx_checkmarkView.frame
        if (editControlWidth == 0) {
            rect.origin.x = -(rect.width + 10.0)
        } else {
            rect.origin.x = -(rect.width + editControlWidth)/2
        }
        rect.origin.y = (self.contentView.height - rect.height) / 2
        self.gx_checkmarkView.frame = rect
    }
    
    open override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            self.gx_editControl = self.gx_editControlView()
            self.gx_editControl?.isHidden = true
        }
    }
}

private extension GXMessagesAvatarCell {
    
    func gx_checkmarkImage(_ checked: Bool) -> UIImage? {
        if checked {
            return UIImage(systemName: "checkmark.circle.fill")
        }
        else {
            return UIImage(systemName: "circle")
        }
    }
    
    func gx_editControlView() -> UIView? {
        guard let editClass = NSClassFromString("UITableViewCellEditControl") else { return nil }
        for subview in self.subviews {
            if subview.isMember(of: editClass) {
                return subview
            }
        }
        return nil
    }
    
}
