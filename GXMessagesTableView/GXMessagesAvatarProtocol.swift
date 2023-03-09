//
//  GXMessagesCellDataSource.swift
//  GXChatUIKit
//
//  Created by Gin on 2023/3/9.
//

import UIKit

/// 头像cell接口
public typealias GXMessagesAvatarCellProtocol = UITableViewCell & GXMessagesAvatarViewProtocol

/// 消息连续状态
public enum GXMessageContinuousStatus: Int {
    /// 开始
    case begin       = 0
    /// 持续中
    case ongoing     = 1
    /// 结束
    case end         = 2
    /// 开始And结束
    case beginAndEnd = 3
}

/// 消息状态
public enum GXMessageStatus : Int {
    /// 发送
    case sending   = 0
    /// 接收
    case receiving = 1
}

/// 头像视图接口
public protocol GXMessagesAvatarViewProtocol {

    var avatar: UIView { get }
        
    func createAvatarView() -> UIView
}

/// 头像数据接口
public protocol GXMessagesAvatarDataProtocol {
    
    var gx_messageContinuousStatus: GXMessageContinuousStatus { get }
    
    var gx_messageStatus: GXMessageStatus { get }
    
    var gx_senderId: String { get }
    
}
