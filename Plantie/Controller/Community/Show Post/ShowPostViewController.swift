import UIKit
import SKPhotoBrowser
import ProgressHUD

class ShowPostViewController: UIViewController {
    
    // MARK: Variables
    
    var post:Post!
    var comments:[Comment] = []
    var skPhotoImages: [SKPhoto] = []

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendCommentButton: UIButton!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
        addNotifications()
        setUpTextView()
        checkIfPostHaveImages()
        
        
        // Fetch comments for the current post ID
           if let postId = post?.id {
               RealtimeDatabaseManager.shared.getAllComments(forPost: postId) { [weak self] comments in
                   self?.comments = comments
                   self?.tableView.reloadData()
               }
           }
    }
    
    // MARK: Actions
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendComment(_ sender: UIButton) {
        guard let content = textView.text, !content.isEmpty else { return }
        guard let currentUser = User.currentUser else { return }

        let ownerDict: [String: Any] = [
            "id": currentUser.id,
            "userName": currentUser.userName,
            "email": currentUser.email,
            "pushId": currentUser.pushId,
            "avatarLink": currentUser.avatarLink,
            "bio": currentUser.bio,
            "country": currentUser.country
        ]

        let comment = Comment(
            id: UUID().uuidString,
            text: content,
            owner: ownerDict,
            postId: post.id
        )

        RealtimeDatabaseManager.shared.addComment(comment: comment) { [weak self] error in
            if let error = error {
                ProgressHUD.error("Error adding comment: \(error.localizedDescription)")
            } else {
                // Update local comment count
                self?.comments.append(comment)
                self?.textView.text = ""
                self?.sendCommentButton.tintColor = .gray
                self?.tableView.reloadData()
                // Update comments count label in the TextTableViewCell
                if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? TextTableViewCell {
                    cell.commentsCountLabel.text = "\(self?.comments.count ?? 0)"
                }

                ProgressHUD.success("تم التعليق")

                // Update comment count in Firebase
                if let postId = self?.post.id {
                    let newCommentCount = self?.comments.count ?? 0
                    RealtimeDatabaseManager.shared.updateCommentCount(forPost: postId, count: newCommentCount) { error in
                        if let error = error {
                            print("Error updating comment count: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
    }

    
    // MARK: private Methods
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nib = UINib(nibName: "ImagesPostCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImagesPostCollectionViewCell")
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
        // This cell for first table cell
        tableView.register(Cell: TextTableViewCell.self)
        //This cell for other cells (contain the comments of post)
        tableView.register(Cell: CommentTableViewCell.self)
       
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
    
    func setUpTextView() {
       textView.layer.cornerRadius = 15.0
       textView.layer.borderColor = UIColor.quaternaryLabel.cgColor
       textView.layer.borderWidth = 1.0
       textView.delegate = self
   }
    
    func checkIfPostHaveImages(){
        
        if !post.images.isEmpty{
            for image in post.images{
                skPhotoImages.append(SKPhoto.photoWithImageURL(image!))
            }
        }else{
            let heightView = view.frame.height
            
            collectionViewHeightConstraint.constant = -heightView * 0.3
            tableViewTopConstraint.constant = 100
        }
    }
   

}


// MARK: - UITextViewDelegate

extension ShowPostViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {
      
        if textView.text.isEmpty {
             // Set button tint color to gray when text is empty
             sendCommentButton.tintColor = .gray
         } else {
             // Set button tint color to green when there is text
             sendCommentButton.tintColor = .plantieGreen
         }

        updateTextViewHeight()
    }

    private func updateTextViewHeight() {
         let maxTextViewHeight: CGFloat = 50.0
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(newSize.height, maxTextViewHeight)
        textViewHeightConstraint.constant = newHeight
    }

}

// MARK: TableView Datasource
extension ShowPostViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeue() as TextTableViewCell
            cell.configure(post: post)
            return cell
        } else if indexPath.row - 1 < comments.count {
            let cell = tableView.dequeue() as CommentTableViewCell
            cell.configure(comment: comments[indexPath.row - 1])
            return cell
        }
      
       return UITableViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         // Create and present SKPhotoBrowser
         let browser = SKPhotoBrowser(photos: skPhotoImages)
         browser.initializePageIndex(indexPath.row)
         present(browser, animated: true, completion: nil)
     }
    
   
}

// MARK: CollectionView Datasource

extension ShowPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return post.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesPostCollectionViewCell", for: indexPath) as! ImagesPostCollectionViewCell
        cell.configure(imageUrl: post.images[indexPath.row]!)
        return cell
    }
}

extension ShowPostViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Keyboard Handling

extension ShowPostViewController {

    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height

            bottomConstraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }

        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
