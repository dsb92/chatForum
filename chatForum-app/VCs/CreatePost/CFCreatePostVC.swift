//
//  CFCreatePostVC.swift
//  chatForum-app
//
//  Created by David Buhauer on 19/03/2019.
//  Copyright © 2019 David Buhauer. All rights reserved.
//

import UIKit
import MultilineTextField

protocol CFCreatePostVCDelegate: class {
    func createPostVcDidCreatePost(_ post: CFPost, sender: CFCreatePostVC)
}

class CFCreatePostVC: CFBaseVC {
    @IBOutlet weak var multilineTextField: MultilineTextField!
    
    weak var delegate: CFCreatePostVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.random
        
        // below are properties that can be optionally customized
        self.multilineTextField.placeholder = "Send en Jodel til hvem som helst inden for 10 k."
        self.multilineTextField.placeholderColor = UIColor.white.withAlphaComponent(0.5)
        self.multilineTextField.textColor = UIColor.white
        self.multilineTextField.delegate = self
        self.multilineTextField.becomeFirstResponder()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Tilbage", style: .plain, target: self, action: #selector(self.didTapBackButton))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.didTapDoneButton))
    }
    
    @objc func didTapBackButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func didTapDoneButton() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = self.dataCon.dateFormat
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        let updatedAt: String = dateFormatter.string(from: Date())
        
        let post = CFPost()
        post.text = self.multilineTextField.text
        post.updatedAt = updatedAt
        
        self.dataCon.postPost(post) { (post) in
            self.dismiss(animated: true, completion: {
                self.delegate?.createPostVcDidCreatePost(post, sender: self)
            })
        }
    }
}

extension CFCreatePostVC: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let existingLines = textView.text.components(separatedBy: CharacterSet.newlines)
        let newLines = text.components(separatedBy: CharacterSet.newlines)
        let linesAfterChange = existingLines.count + newLines.count - 1
        return linesAfterChange <= 10
    }
}
