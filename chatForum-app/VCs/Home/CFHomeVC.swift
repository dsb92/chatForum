//
//  CFHomeVC.swift
//  ChatForum
//
//  Created by David Buhauer on 09/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit
import SnapKit
import AVKit
import AVFoundation

class CFHomeVC: CFBaseVC {
    @IBOutlet weak var forumTableView: CFForumTableView!
    
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = UIColor.random
        
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        self.forumTableView.addSubview(self.refreshControl)
        self.forumTableView.forumTableViewDelegate = self
        
        self.refreshData()
        
        let floatingButton = CFFloatingButton()
        floatingButton.addTarget(self, action: #selector(self.didTapFloatingActionButton), for: .touchUpInside)
        self.view.addSubview(floatingButton)
        floatingButton.snp.makeConstraints { (make) in
            if #available(iOS 11, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottomMargin).offset(-15)
                make.right.equalTo(self.view.safeAreaLayoutGuide.snp.rightMargin).offset(-20)
            } else {
                make.bottom.equalToSuperview().offset(-15)
                make.right.equalToSuperview().offset(-20)
            }
            
            make.width.height.equalTo(60)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let url = dataCon.getVideoUrl(from: "D4C0CE6A-D64D-4F74-9545-021FA8676F4F")!
//        
//        playVideo(url: url)
    }
    
    func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        
        let vc = AVPlayerViewController()
        vc.player = player
        
        self.present(vc, animated: true) { vc.player?.play() }
    }
    
    // MARK: - Actions
    @objc func didTapFloatingActionButton() {
        let createPostVc = CFCreatePostVC()
        createPostVc.delegate = self
        self.present(UINavigationController(rootViewController: createPostVc), animated: true, completion: nil)
    }
    
    @objc func refreshData() {
        self.view.backgroundColor = UIColor.random
        
        self.dataCon.getPosts { (posts) in
            self.forumTableView.posts = posts
            self.forumTableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
}

extension CFHomeVC: CFCreatePostVCDelegate {
    func createPostVcDidCreatePost(_ post: CFPost, sender: CFCreatePostVC) {
        UIView.animate(withDuration: 0.5, animations: {
            self.forumTableView.contentOffset = .zero
        }) { (_) in
            self.forumTableView.beginUpdates()
            self.forumTableView.posts.insert(post, at: 0)
            self.forumTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
            self.forumTableView.endUpdates()
        }
    }
}

extension CFHomeVC: CFForumTableViewDelegate {
    func didSelectPost(_ post: CFPost, sender: CFForumTableView) {
        self.navigationController?.pushViewController(CFCommentPostVC(post: post), animated: true)
    }
}
