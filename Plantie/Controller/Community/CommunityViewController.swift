
import UIKit

class CommunityViewController: UIViewController {
    
    // MARK: Variables
    var posts: [Post] = []
    let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setUpTable()
        getPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(commentButtonPresed), name: Notification.Name(rawValue: "commentButtonTapped"), object: nil)
    }
    
    func getPosts(){
        RealtimeDatabaseManager.shared.getAllPosts { posts in
            self.posts = posts
            self.tableView.reloadData()
        }
    }
    
    @objc func commentButtonPresed(notification : Notification){
    
        if let cell = notification.userInfo?["cell"] as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell){
                let post = posts[indexPath.row]
                let vc = storyboard?.instantiateViewController(withIdentifier: "showPostView") as! ShowPostViewController
                vc.post = post
                vc.modalPresentationStyle = .fullScreen
                present(vc, animated: true, completion: nil)

            }
            
        }
        
        
    }
    // MARK: Actions
    @IBAction func composeBarButton(_ sender: UIBarButtonItem) {
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPostView") as! AddPostViewController

        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    
    
}

// MARK: Table View Data Source
extension CommunityViewController : UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if post.images.isEmpty{
            
            let cell = tableView.dequeue() as TextTableViewCell
            cell.contentPostLabel.isExpaded = false
            cell.configure(post: post)
            return cell
        }
        
        else
        {
            let cell = tableView.dequeue() as TextWithImagesTableViewCell
            cell.contentPostLabel.isExpaded = false
            cell.configure(post: post)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "showPostView") as! ShowPostViewController
        vc.post = posts[indexPath.row]
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

