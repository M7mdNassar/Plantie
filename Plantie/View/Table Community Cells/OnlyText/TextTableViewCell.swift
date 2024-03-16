import UIKit

class TextTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contentPostLabel: ExpandableLabel!
    @IBOutlet weak var backgroundContentView: ShadowView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var dislikesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    // MARK: Variables
    var post: Post!
    private var isLikeSelected = false
    private var isDislikeSelected = false
    
    // MARK: Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Reset label's content
        contentPostLabel.text = nil
        
        // Remove the "Read more" button if it's added
        removeReadMoreButtonIfNeeded()
    }

    private func removeReadMoreButtonIfNeeded() {
        // Find and remove the "Read more" button if it's added
        if let readMoreButton = self.contentView.viewWithTag(9090) {
            readMoreButton.removeFromSuperview()
        }
    }

    
    // MARK: Actions
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "commentButtonTapped"), object: nil , userInfo: ["cell" : self]))
    }
    

    @IBAction func makeLike(_ sender: UIButton) {
        guard let postId = post?.id else { return }

        let isAlreadyLiked = likeButton.tintColor == .plantieGreen

        if isAlreadyLiked { // If already liked, remove the like
            RealtimeDatabaseManager.shared.updateLikes(forPost: postId, increment: -1) { [weak self] error in
                // Handle error and update UI as needed
                if error == nil {
                    self?.likeButton.tintColor = .systemGray2
                    self?.updateLikeCountLabel(-1)
                }
            }
        } else { // If not liked, add the like and deselect the dislike button
            RealtimeDatabaseManager.shared.updateLikes(forPost: postId, increment: 1) { [weak self] error in
                // Handle error and update UI as needed
                if error == nil {
                    self?.likeButton.tintColor = .plantieGreen
                    self?.updateLikeCountLabel(1)
                    self?.deselectDislikeButton()
                }
            }

            // If the user had previously disliked the post, update the dislike count and UI
            if dislikeButton.tintColor == .plantieGreen {
                RealtimeDatabaseManager.shared.updateDislikes(forPost: postId, increment: -1) { [weak self] error in
                    // Handle error and update UI as needed
                    if error == nil {
                        self?.dislikeButton.tintColor = .systemGray2
                        self?.updateDislikeCountLabel(-1)
                    }
                }
            }
        }
    }

    @IBAction func makeDislike(_ sender: UIButton) {
        guard let postId = post?.id else { return }

        let isAlreadyDisliked = dislikeButton.tintColor == .plantieGreen

        if isAlreadyDisliked { // If already disliked, remove the dislike
            RealtimeDatabaseManager.shared.updateDislikes(forPost: postId, increment: -1) { [weak self] error in
                // Handle error and update UI as needed
                if error == nil {
                    self?.dislikeButton.tintColor = .systemGray2
                    self?.updateDislikeCountLabel(-1)
                }
            }
        } else { // If not disliked, add the dislike and deselect the like button
            RealtimeDatabaseManager.shared.updateDislikes(forPost: postId, increment: 1) { [weak self] error in
                // Handle error and update UI as needed
                if error == nil {
                    self?.dislikeButton.tintColor = .plantieGreen
                    self?.updateDislikeCountLabel(1)
                    self?.deselectLikeButton()
                }
            }

            // If the user had previously liked the post, update the like count and UI
            if likeButton.tintColor == .plantieGreen {
                RealtimeDatabaseManager.shared.updateLikes(forPost: postId, increment: -1) { [weak self] error in
                    // Handle error and update UI as needed
                    if error == nil {
                        self?.likeButton.tintColor = .systemGray2
                        self?.updateLikeCountLabel(-1)
                    }
                }
            }
        }
    }



     private func toggleLikeButton() {
         guard let postId = post?.id else { return }
         
         if likeButton.tintColor == .plantieGreen {
             isLikeSelected = false
             RealtimeDatabaseManager.shared.updateLikes(forPost: postId, increment: -1) { [weak self] error in
                 if let error = error {
                     print("Error updating likes: \(error.localizedDescription)")
                     return
                 }
                 self?.updateLikeCountLabel(-1)
             }
         } else {
             isLikeSelected = true
             RealtimeDatabaseManager.shared.updateLikes(forPost: postId, increment: 1) { [weak self] error in
                 if let error = error {
                     print("Error updating likes: \(error.localizedDescription)")
                     return
                 }
                 self?.updateLikeCountLabel(1)
                 self?.deselectDislikeButton()
             }
         }
         
         likeButton.tintColor = (likeButton.tintColor == .plantieGreen) ? .systemGray2 : .plantieGreen
     }

     private func toggleDislikeButton() {
         guard let postId = post?.id else { return }
         
         if dislikeButton.tintColor == .plantieGreen {
             isDislikeSelected = false
             RealtimeDatabaseManager.shared.updateDislikes(forPost: postId, increment: -1) { [weak self] error in
                 if let error = error {
                     print("Error updating dislikes: \(error.localizedDescription)")
                     return
                 }
                 self?.updateDislikeCountLabel(-1)
             }
         } else {
             isDislikeSelected = true
             RealtimeDatabaseManager.shared.updateDislikes(forPost: postId, increment: 1) { [weak self] error in
                 if let error = error {
                     print("Error updating dislikes: \(error.localizedDescription)")
                     return
                 }
                 self?.updateDislikeCountLabel(1)
                 self?.deselectLikeButton()
             }
         }
         
         dislikeButton.tintColor = (dislikeButton.tintColor == .plantieGreen) ? .systemGray2 : .plantieGreen
     }
     
     // MARK: Helper Methods

     private func updateLikeCountLabel(_ increment: Int) {
         guard let currentLikes = Int(likesCountLabel.text ?? "0") else { return }
         likesCountLabel.text = "\(currentLikes + increment)"
     }

     private func updateDislikeCountLabel(_ increment: Int) {
         guard let currentDislikes = Int(dislikesCountLabel.text ?? "0") else { return }
         dislikesCountLabel.text = "\(currentDislikes + increment)"
     }
     
     private func deselectLikeButton() {
         guard let postId = post?.id else { return }
         
         if isLikeSelected {
             isLikeSelected = false
             RealtimeDatabaseManager.shared.updateLikes(forPost: postId, increment: -1) { [weak self] error in
                 if let error = error {
                     print("Error updating likes: \(error.localizedDescription)")
                     return
                 }
                 self?.updateLikeCountLabel(-1)
             }
         }
         
         likeButton.tintColor = .systemGray2
     }

     private func deselectDislikeButton() {
         guard let postId = post?.id else { return }
         
         if isDislikeSelected {
             isDislikeSelected = false
             RealtimeDatabaseManager.shared.updateDislikes(forPost: postId, increment: -1) { [weak self] error in
                 if let error = error {
                     print("Error updating dislikes: \(error.localizedDescription)")
                     return
                 }
                 self?.updateDislikeCountLabel(-1)
             }
         }
         
         dislikeButton.tintColor = .systemGray2
     }



    // MARK: Methods
    
    func configure(post: Post) {
        self.post = post
        if post.owner["avatarLink"] as? String != "" {
            self.userImageView.sd_setImage(with: URL(string: post.owner["avatarLink"] as! String))

            self.userImageView.layer.cornerRadius = self.userImageView.frame.height / 2
            self.userImageView.clipsToBounds = true
        }

        self.userNameLabel.text = post.owner["userName"] as? String
        self.contentPostLabel.text = post.text

        // Update comments count label
        self.commentsCountLabel.text = "\(post.countOfComments)"

        self.likesCountLabel.text = "\(post.likes)"
        self.dislikesCountLabel.text = "\(post.dislikes)"
    }
    
}
