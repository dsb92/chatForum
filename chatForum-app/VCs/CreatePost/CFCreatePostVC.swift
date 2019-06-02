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
    @IBOutlet weak var startAVSessionButton: UIButton!
    
    weak var delegate: CFCreatePostVCDelegate?
    
    var capturedImage: UIImage?
    
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
        var post = CFPost(backgroundColorHex: self.view.backgroundColor?.toHexString(),
                      id: nil,
                      text: self.multilineTextField.text,
                      updatedAt: updatedAt,
                      numberOfComments: nil,
                      imageIds: nil)
        
        if let capturedImage = self.capturedImage {
            self.dataCon.uploadImage(capturedImage) { imageId in
                post = CFPost(backgroundColorHex: self.view.backgroundColor?.toHexString(),
                              id: nil,
                              text: self.multilineTextField.text,
                              updatedAt: updatedAt,
                              numberOfComments: nil,
                              imageIds: [UUID(uuidString: imageId.uuidString)!])
                self.dataCon.postPost(post) { post in
                    self.dismiss(animated: true, completion: {
                        self.delegate?.createPostVcDidCreatePost(post, sender: self)
                    })
                }
            }
        } else {
            self.dataCon.postPost(post) { post in
                self.dismiss(animated: true, completion: {
                    self.delegate?.createPostVcDidCreatePost(post, sender: self)
                })
            }
        }
    }
    
    @IBAction func didTapStartAvSessionButton(_ sender: Any) {
        let createPostVc = CFCaptureImageVC()
        createPostVc.delegate = self
        navigationController?.present(createPostVc, animated: true, completion: nil)
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

extension CFCreatePostVC: CFCaptureImageVCDelegate {
    func captureImageVcDidCaptureImage(_ image: UIImage) {
        self.capturedImage = image
        dismiss(animated: true, completion: nil)
    }
}
