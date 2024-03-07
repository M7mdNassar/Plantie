
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
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    // MARK: Actions
    
    @IBAction func commentButtonTapped(_ sender: UIButton) {
        NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "commentButtonTapped")))
    }
    
    // MARK: Methods
    
    func configure(post: Post ){
        
        
        if post.owner["avatarLink"] as? String != ""{
            self.userImageView.sd_setImage(with: URL(string: post.owner["avatarLink"] as! String))
            
            self.userImageView.layer.cornerRadius = self.userImageView.frame.height/2
            self.userImageView.clipsToBounds = true
        }
        
        self.userNameLabel.text = post.owner["userName"] as? String
        self.contentPostLabel.text = post.text

        
        self.commentsCountLabel.text = String(post.countOfComments)
        
        self.likesCountLabel.text = String(post.likes)
        self.dislikesCountLabel.text = String(post.dislikes)

    
    }
}
