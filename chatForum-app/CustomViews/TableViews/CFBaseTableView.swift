//
//  CFBaseTableView.swift
//  chatForum-app
//
//  Created by David Buhauer on 20/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit

class CFBaseTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        self.setup()
        self.registerCells()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
        self.registerCells()
    }
    
    func setup() {
        self.tableHeaderView = UIView()
        self.tableFooterView = UIView()
        
        self.sectionHeaderHeight = UITableView.automaticDimension
        self.estimatedSectionHeaderHeight = 100
        
        self.dataSource = self
        self.delegate = self
        
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 100
    }
    
    func registerCells() {
        self.registerReusableCell(CFForumCell.self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fatalError("Override")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        fatalError("Override")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
