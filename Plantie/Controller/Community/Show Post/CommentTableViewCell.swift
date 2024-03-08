
import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var commentPostLabel: ExpandableLabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(comment: Comment){
        
        
        if comment.owner["avatarLink"] as? String != ""{
            self.userImageView.sd_setImage(with: URL(string: comment.owner["avatarLink"] as! String))
            
            self.userImageView.layer.cornerRadius = self.userImageView.frame.height/2
            self.userImageView.clipsToBounds = true
        }
        
        self.userNameLabel.text = comment.owner["userName"] as? String
        self.commentPostLabel.text = comment.text
    
    }

    
}
