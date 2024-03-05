
import UIKit
import SKPhotoBrowser

class CommunityViewController: UIViewController {
    
    // MARK: Variables
    let posts: [Post] = [
        Post(postId: "123", owner: User.currentUser!, content: "Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !Hello Farmers !", imageUrls: [], likes: 0, comments: []),
        Post(postId: "1234", owner: User.currentUser!, content: "بسم الله الرحمن الرحيم ", imageUrls: ["https://firebasestorage.googleapis.com:443/v0/b/foodie-b6084.appspot.com/o/PostImages%2F_596AF6FE-F40A-42F1-8471-CA9DEC0A99DA.jpg?alt=media&token=137435cc-e36b-4283-bcd5-0d6926097f01",""], likes: 0, comments: [])
    ]
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setUpTable()
    }
    
    // MARK: Actions
    @IBAction func composeBarButton(_ sender: UIBarButtonItem) {
        
        let userView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPostView") as! AddPostViewController
        self.navigationController?.pushViewController(userView, animated: true)
    }
    
    
}

// MARK: Table View Data Source
extension CommunityViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if post.imageUrls.isEmpty{
            
            let cell = tableView.dequeue() as TextTableViewCell
            cell.contentPostLabel.isExpaded = false
            cell.configure(post: post)
            return cell
        }
        
        else
        {
            let cell = tableView.dequeue() as TextWithImagesTableViewCell
            cell.delegate = self
            cell.contentPostLabel.isExpaded = false
            cell.configure(post: post)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "showPostView")
//        navigationController?.pushViewController(vc, animated: true)
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
        
    }
    
}

// MARK: UISearchResultsUpdating

extension CommunityViewController: UISearchResultsUpdating{
    
    func updateSearchResults(for searchController: UISearchController) {
        return
    }
    
    
}

// MARK: Private Methods
private extension CommunityViewController{
    
    func setupSearchBar(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Posts"
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
    }
    
    func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Cell: TextWithImagesTableViewCell.self)
        tableView.register(Cell: TextTableViewCell.self)
        
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
    }
}

// MARK: Show the image from post cell

extension CommunityViewController: TextWithImagesTableViewCellDelegate {
    
    func mixedPostCell(_ cell: TextWithImagesTableViewCell, didSelectImageAt indexPath: IndexPath) {
        guard let imageUrl = cell.postImages[indexPath.item] else {
            return
        }
        
        var images = [SKPhoto]()
        let photo = SKPhoto.photoWithImageURL(imageUrl)
        photo.shouldCachePhotoURLImage = false
        images.append(photo)
        
        let browser = SKPhotoBrowser(photos: images)
        browser.initializePageIndex(0)
        
        // Here you can present the SKPhotoBrowser
        present(browser, animated: true, completion: nil)
    }
}
