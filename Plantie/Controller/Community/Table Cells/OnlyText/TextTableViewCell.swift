
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
    
    // MARK: Methods
    
    func configure(post: Post ){
        if post.owner.avatarLink != ""{
            self.userImageView.sd_setImage(with: URL(string: post.owner.avatarLink))
            
            self.userImageView.layer.cornerRadius = self.userImageView.frame.height/2
            self.userImageView.clipsToBounds = true
        }
        
        self.userNameLabel.text = post.owner.userName
        self.contentPostLabel.text = post.content

        
        self.commentsCountLabel.text = String(post.comments.count)
        
        self.likesCountLabel.text = String(post.likes)
        
    
    }
}
