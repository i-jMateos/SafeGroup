//
//  WallViewController.swift
//  SafeGroup
//
//  Created by jmateos on 28/12/20.
//  Copyright © 2020 Jordi Mateos Manchado. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class WallViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendCommentTextField: UIButton!
    @IBOutlet weak var commentsViewBottomConstraint: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    var postsReference: DocumentReference? = nil
    
    var event: Event!
    var posts: [EventPost] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        getPosts()
    }
    
    func getPosts() {
        postsReference = db.collection("posts").document()
        
        guard let eventDict = event.dictionary else { return }
        var posts: [EventPost] = []
        db.collection("posts")
            .whereField("event", isEqualTo: eventDict)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let dict = document.data()
                        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
                        
                        guard let post: EventPost = try? JSONDecoder().decode(EventPost.self, from: jsonData!) else { return }
                        posts.append(post)
                    }
                }
                
                self.posts = posts
                self.posts.sort(by: { $0.timestamp > $1.timestamp })
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    func createPost(post: EventPost) {
        guard let postEncoded = post.dictionary else { return }
        
        self.showLoading(onView: self.view)
        postsReference?.setData(postEncoded, completion: { (err) in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                print("Document added with ID: \(self.postsReference!.documentID)")
                self.posts.insert(post, at: 0)
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
                    self.tableView.endUpdates()
                    self.tableView.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }
                
                self.postsReference = self.db.collection("posts").document()
            }
            
            self.removeLoading()
        })
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            commentsViewBottomConstraint.constant = keyboardHeight
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        commentsViewBottomConstraint.constant = 0
    }
    

    @IBAction func sendCommentButtonAction(_ sender: Any) {
        guard let firUser = Auth.auth().currentUser else { return }
        let user = User(id: firUser.uid, email: firUser.email ?? "")
        
        guard let message = self.commentTextField.text else { return }
        guard let documentId = postsReference?.documentID else { return }
        let post = EventPost(id: documentId, message: message, timestamp: Date(), imageUrl: nil, user: user, event: self.event)
        
        self.createPost(post: post)
        
        self.commentTextField.text = nil
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WallViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WallTableViewCell.reuseIdentifier) as! WallTableViewCell
        
        let post = posts[indexPath.row]
        cell.commentLabel.text = post.message
        cell.usernameLabel.text = "\(post.user.email)" // "\(post.user.firstname ?? "") \(post.user.lastname ?? "")"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy HH:mm"
        cell.dateLabel.text = dateFormatter.string(from: post.timestamp)
        
        return cell
    }
}
