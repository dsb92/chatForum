//
//  CFCommentPostVC.swift
//  chatForum-app
//
//  Created by David Buhauer on 20/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit
import GrowingTextView

class CFCommentPostVC: CFBaseVC {
    @IBOutlet weak var commentsTableView: CFCommentTableView!
    @IBOutlet weak var messageComposerView: UIView!
    @IBOutlet weak var messageComposerTextView: GrowingTextView!
    @IBOutlet weak var messageComposerStackView: UIStackView!
    @IBOutlet weak var sendButton: UIButton!
    
    private let refreshControl = UIRefreshControl()
    
    private var post: CFPost?
    
    init(post: CFPost) {
        self.post = post
        super.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hexString: post?.backgroundColorHex ?? "")
        
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: .valueChanged)
        self.commentsTableView.addSubview(self.refreshControl)
        self.commentsTableView.post = post
        self.commentsTableView.backgroundColor = UIColor(hexString: post?.backgroundColorHex ?? "")
        self.commentsTableView.commentTableViewDelegate = self
        
        self.refreshData()
        
        messageComposerTextView.maxLength = 140
        messageComposerTextView.trimWhiteSpaceWhenEndEditing = true
        messageComposerTextView.placeholder = "Say something..."
        messageComposerTextView.placeholderColor = UIColor(white: 0.8, alpha: 1.0)
        messageComposerTextView.minHeight = 40.0
        messageComposerTextView.maxHeight = 120.0
        messageComposerTextView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        messageComposerTextView.layer.cornerRadius = 4.0
        messageComposerTextView.delegate = self
        
        sendButton.setImage(#imageLiteral(resourceName: "icons8-send-comment-filled-100").withRenderingMode(.alwaysTemplate), for: .normal)
        sendButton.tintColor = UIColor(hexString: self.post?.backgroundColorHex ?? "")
    }
    
    @objc func refreshData() {
        guard let post = self.post else { return }
        guard let postId = post.id else { return }
        
        self.dataCon.getComments(from: postId) { (comments) in
            self.commentsTableView.comments = comments
            self.commentsTableView.reloadData()
            
            self.refreshControl.endRefreshing()
        }
    }
    
    @IBAction func didTapSendButton(_ sender: UIButton) {
        guard let post = self.post else { return }
        guard let postId = post.id else { return }
        
        let text = messageComposerTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dataCon.dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        let updatedAt: String = dateFormatter.string(from: Date())
        
        let comment = CFComment(comment: text, id: nil, postID: postId, updatedAt: updatedAt, numberOfLikes: 0, numberOfDislikes: 0)
        
        self.dataCon.postComment(comment) { (comment) in
            self.commentsTableView.beginUpdates()
            self.commentsTableView.comments.append(comment)
            let lastIndexPath = IndexPath(row: self.commentsTableView.comments.count - 1, section: 0)
            self.commentsTableView.insertRows(at: [lastIndexPath], with: .automatic)
            self.commentsTableView.endUpdates()
            
            self.commentsTableView.scrollToRow(at: lastIndexPath, at: .middle, animated: true)
        }
        
        messageComposerTextView.resignFirstResponder()
        messageComposerTextView.text = nil
        
        textViewDidChange(messageComposerTextView)
    }
}

extension CFCommentPostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        
        let text = textView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        UIView.animate(withDuration: 0.2,
                       delay: 0.0,
                       usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1,
                       options: [],
                       animations: {
                        self.sendButton.isHidden = text.isEmpty
                        self.messageComposerStackView.layoutIfNeeded()
        },
                       completion: nil)
    }
}

extension CFCommentPostVC: CFCommentTableViewDelegate {
    func didLikeComment(_ comment: CFComment, liked: Bool, sender: CFCommentTableView) {
        guard let id = comment.id, let uuid = UUID(uuidString: id) else { return }
        
        let index = sender.comments.firstIndex(where: { comment -> Bool in
            comment.id == id
        })
        
        if liked {
            self.dataCon.postLikeComment(commentID: uuid) { numberOfLikes in
                self.dataCon.liked.append(uuid.uuidString)
                
                let newComment = CFComment(comment: comment.comment, id: comment.id, postID: comment.postID, updatedAt: comment.updatedAt, numberOfLikes: numberOfLikes, numberOfDislikes: comment.numberOfDislikes)
                
                if let index = index {
                    sender.comments.remove(at: index)
                    sender.comments.insert(newComment, at: index)
//                    sender.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    sender.reloadData()
                }
            }
        } else {
            self.dataCon.deleteLikeComment(commentID: uuid) { numberOfLikes in
                self.dataCon.liked = self.dataCon.liked.filter { $0 != uuid.uuidString }
                
                let newComment = CFComment(comment: comment.comment, id: comment.id, postID: comment.postID, updatedAt: comment.updatedAt, numberOfLikes: numberOfLikes, numberOfDislikes: comment.numberOfDislikes)
                
                if let index = index {
                    sender.comments.remove(at: index)
                    sender.comments.insert(newComment, at: index)
//                    sender.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    sender.reloadData()
                }
            }
        }
    }
    
    func didDislikeComment(_ comment: CFComment, disliked: Bool, sender: CFCommentTableView) {
        guard let id = comment.id, let uuid = UUID(uuidString: id) else { return }
        
        let index = sender.comments.firstIndex(where: { comment -> Bool in
            comment.id == id
        })
        
        if disliked {
            self.dataCon.postDislikeComment(commentID: uuid) { numberOfDislikes in
                self.dataCon.disliked.append(uuid.uuidString)
                
                let newComment = CFComment(comment: comment.comment, id: comment.id, postID: comment.postID, updatedAt: comment.updatedAt, numberOfLikes: comment.numberOfLikes, numberOfDislikes: numberOfDislikes)
                
                if let index = index {
                    sender.comments.remove(at: index)
                    sender.comments.insert(newComment, at: index)
//                    sender.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    sender.reloadData()
                }
            }
        } else {
            self.dataCon.deleteDislikeComment(commentID: uuid) { numberOfDislikes in
                self.dataCon.disliked = self.dataCon.disliked.filter { $0 != uuid.uuidString }
                
                let newComment = CFComment(comment: comment.comment, id: comment.id, postID: comment.postID, updatedAt: comment.updatedAt, numberOfLikes: comment.numberOfLikes, numberOfDislikes: numberOfDislikes)
                
                if let index = index {
                    sender.comments.remove(at: index)
                    sender.comments.insert(newComment, at: index)
//                    sender.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
                    sender.reloadData()
                }
            }
        }
    }
}
