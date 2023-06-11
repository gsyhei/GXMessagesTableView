//
//  GXMessagesAvatarCell.swift
//  GXMessagesTableViewSample
//
//  Created by Gin on 2023/6/11.
//

import UIKit
import Reusable

public class GXMessagesAvatarCell: UITableViewCell, Reusable {

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        NotificationCenter.default.addObserver(self, selector: #selector(editNotification), name: GXMessagesTableView.GXEditNotification, object: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func editNotification(notification: NSNotification) {
        if let object = notification.object as? [String: Bool] {
            let editing = object[GXMessagesTableView.GXEditIsEditingKey] ?? false
            let animated = object[GXMessagesTableView.GXEditIsEditingKey] ?? false
            self.gx_setEditing(editing, animated: animated)
        }
    }
    
    public func gx_setEditing(_ editing: Bool, animated: Bool) {
        
    }
    
}
