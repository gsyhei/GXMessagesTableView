//
//  ViewController.swift
//  GXMessagesTableViewSample
//
//  Created by Gin on 2023/3/9.
//

import UIKit
import Reusable

/// 消息状态
public enum GXMessageStatus : Int {
    /// 发送
    case send    = 0
    /// 接收
    case receive = 1
}

public struct TestData: GXMessagesAvatarDataProtocol {
    var avatarID: String = ""
    var continuousBegin: Bool = true
    var continuousEnd: Bool = false
    var messageStatus: GXMessageStatus = .send
    var avatarText: String = ""
    var text: String = ""
    
    //MARK: - GXMessagesAvatarDataSource
    
    public var gx_messageStatus: GXMessageStatus {
        return self.messageStatus
    }
    
    public var gx_continuousBegin: Bool {
        set {
            self.continuousBegin = newValue
        }
        get {
            return self.continuousBegin
        }
    }
    
    public var gx_continuousEnd: Bool {
        set {
            self.continuousEnd = newValue
        }
        get {
            return self.continuousEnd
        }
    }
    
    public var gx_senderId: String {
        return self.avatarID
    }
    
}

class ViewController: UIViewController {
    
    private var list: [[TestData]] = []
    
    private lazy var tableView: GXMessagesHoverAvatarTableView = {
        let tv = GXMessagesHoverAvatarTableView(frame: self.view.bounds, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.datalist = self
        tv.backgroundColor = .white
        tv.rowHeight = 100.0
        tv.allowsMultipleSelection = true
        
        return tv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.addSubview(self.tableView)
        self.tableView.register(cellType: GXMessagesTestCell.self)
        self.tableView.sectionHeaderHeight = 30.0
        self.tableView.addMessagesHeader {[weak self] in
            DispatchQueue.main.asyncAfter(deadline:DispatchTime.now() + 2.0) {
                self?.updateDatas()
                self?.tableView.endHeaderLoading()
            }
        }
        
        self.updateDatas()
        self.tableView.reloadData()
        let right = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(self.editItemTapped))
        self.navigationItem.rightBarButtonItem = right
    }
    
    @objc func editItemTapped() {
        if self.tableView.gx_isEditing {
            self.tableView.gx_setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Edit"
        }
        else {
            self.tableView.gx_setEditing(true, animated: true)
            self.navigationItem.rightBarButtonItem?.title = "Cancel"
        }
    }
    
    
    public func updateDatas() {
        var array: [TestData] = []

        for index in 0..<40 {
            let column = index / 4
            let cuindex = index % 4
            
            var data = TestData()
            data.text = "index\(index)"
            if cuindex == 0 {
                data.gx_continuousBegin = true
                data.gx_continuousEnd = false
            } else if cuindex == 3 {
                data.gx_continuousBegin = false
                data.gx_continuousEnd = true
            } else {
                data.gx_continuousBegin = false
                data.gx_continuousEnd = false
            }
            data.messageStatus = (column%4 > 1) ? .send : .receive
            if data.messageStatus == .send {
                data.avatarID = "\(column)"
                data.avatarText = "发\(column)"
            }
            else {
                data.avatarID = "\(column)"
                data.avatarText = "收\(column)"
            }

            array.append(data)
        }
        self.list.append(array)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        let rect = self.view.bounds.insetBy(dx: 0, dy: self.view.safeAreaInsets.bottom)
        self.tableView.frame = rect
    }

}

extension  ViewController: UITableViewDataSource, UITableViewDelegate, GXMessagesHoverAvatarTableViewDatalist {
    
    func gx_tableView(_ tableView: UITableView, avatarDataForRowAt indexPath: IndexPath) -> GXMessagesAvatarDataProtocol {
        return self.list[indexPath.section][indexPath.row]
    }
    
    func gx_tableView(_ tableView: UITableView, changeForRowAt indexPath: IndexPath, avatar: UIView) {
        let data = self.list[indexPath.section][indexPath.row]
        
        if let avatarButton = avatar as? UIButton {
            avatarButton.setTitle(data.avatarText, for: .normal)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.list.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.list[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GXMessagesTestCell = tableView.dequeueReusableCell(for: indexPath)
        
        let data = self.list[indexPath.section][indexPath.row]
        cell.textLabel?.text = "\t\t\t section: \(indexPath.section), row: \(indexPath.row), id: \(data.text)"
        cell.bindCell(data: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewID = "ViewID"
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewID)
        if header == nil {
            header = UITableViewHeaderFooterView(reuseIdentifier: viewID)
        }
        header?.textLabel?.text = "Section: \(section)"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        NSLog("didSelectRowAt: selectedCount = \(tableView.indexPathsForSelectedRows?.count ?? 0)")
    }
    
}


