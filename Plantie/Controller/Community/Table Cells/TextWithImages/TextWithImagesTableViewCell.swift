
import UIKit

class TextWithImagesTableViewCell: UITableViewCell {

    // MARK: Outlets
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var contentPostLabel: ExpandableLabel!
    @IBOutlet weak var PostsImagesCollectionView: UICollectionView!
    @IBOutlet weak var backgroundContentView: ShadowView!
    @IBOutlet weak var commentsCountLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var dislikesCountLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dislikeButton: UIButton!
    @IBOutlet weak var commentButton: UIButton!
    
    // MARK: Variables
    
    var postImages: [String?] = []
    weak var delegate: TextWithImagesTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        
        PostsImagesCollectionView.delegate = self
        PostsImagesCollectionView.dataSource = self
        
       let nib = UINib(nibName: "ImagesPostCollectionViewCell", bundle: nil)
        PostsImagesCollectionView.register(nib, forCellWithReuseIdentifier: "ImagesPostCollectionViewCell")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        
        self.postImages = post.imageUrls.filter{$0 != ""}
        self.PostsImagesCollectionView.reloadData()
    
    }
    
    
}

// MARK: ImagesPost Collection Data Source

extension TextWithImagesTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return postImages.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesPostCollectionViewCell", for: indexPath) as! ImagesPostCollectionViewCell

        
        if let image = postImages[indexPath.item] {
            cell.configure(imageUrl: image)
        }

        return cell
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.mixedPostCell(self, didSelectImageAt: indexPath)
    }


}

extension TextWithImagesTableViewCell: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: Protocol to handle image selection events
protocol TextWithImagesTableViewCellDelegate: AnyObject {
    func mixedPostCell(_ cell: TextWithImagesTableViewCell, didSelectImageAt indexPath: IndexPath)
}
