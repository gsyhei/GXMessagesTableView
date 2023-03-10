//
//  ViewController.swift
//  GXMessagesTableViewSample
//
//  Created by Gin on 2023/3/9.
//

import UIKit
import Reusable

public struct TestData: GXMessagesAvatarDataProtocol {
    var avatarID: String = ""
    var messageContinuousStatus: GXMessageContinuousStatus = .begin
    var messageStatus: GXMessageStatus = .sending
    var avatarText: String = ""
    var text: String = ""
    
    //MARK: - GXMessagesAvatarDataSource
    
    public var gx_messageContinuousStatus: GXMessageContinuousStatus {
        return self.messageContinuousStatus
    }
    
    public var gx_messageStatus: GXMessageStatus {
        return self.messageStatus
    }
    
    public var gx_senderId: String {
        return self.avatarID
    }
}

class ViewController: UIViewController {
    
    private var list: [[TestData]] = []
    
    private lazy var tableView: GXMessagesTableView = {
        let tv = GXMessagesTableView(frame: self.view.bounds, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.datalist = self
        tv.backgroundColor = .white
        tv.rowHeight = 100.0
        
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
    }
    
    public func updateDatas() {
        var array: [TestData] = []

        for index in 0..<40 {
            let column = index / 4
            let cuindex = index % 4
            
            var data = TestData()
            data.text = "index\(index)"
            if cuindex == 0 {
                data.messageContinuousStatus = .begin
            } else if cuindex == 3 {
                data.messageContinuousStatus = .end
            } else {
                data.messageContinuousStatus = .ongoing
            }
            data.messageStatus = (column%4 > 1) ? .sending : .receiving
            if data.messageStatus == .sending {
                data.avatarID = "\(column)"
                data.avatarText = "???\(column)"
            }
            else {
                data.avatarID = "\(column)"
                data.avatarText = "???\(column)"
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

extension  ViewController: UITableViewDataSource, UITableViewDelegate, GXMessagesTableViewDatalist {
    
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
        var header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "viewID")
        if header == nil {
            header = UITableViewHeaderFooterView(reuseIdentifier: viewID)
        }
        header?.textLabel?.text = "Section: \(section)"
        
        return header
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}


