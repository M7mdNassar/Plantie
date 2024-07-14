import UIKit
import NVActivityIndicatorView

class CommunityViewController: UIViewController {
    
    // MARK: Variables
    var posts: [Post] = []
    var filteredPosts: [Post] = []
    let searchController = UISearchController(searchResultsController: nil)
    let realtimeDatabaseManager = RealtimeDatabaseManager()

    var isSearchActive: Bool {
        return searchController.isActive && !(searchController.searchBar.text?.isEmpty ?? true)
    }
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setUpTable()
        getPosts()
        NotificationCenter.default.addObserver(self, selector: #selector(commentButtonPressed), name: Notification.Name(rawValue: "commentButtonTapped"), object: nil)
    }
    
    func getPosts(){
        // Clear the current posts to avoid duplicates
        self.posts.removeAll()
        self.tableView.reloadData()
        
        RealtimeDatabaseManager.shared.getAllPosts { posts in
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func commentButtonPressed(notification: Notification) {
        if let cell = notification.userInfo?["cell"] as? UITableViewCell {
            if let indexPath = tableView.indexPath(for: cell){
                let post: Post
                if isSearchActive {
                    post = filteredPosts[indexPath.row]
                } else {
                    post = posts[indexPath.row]
                }
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
extension CommunityViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearchActive ? filteredPosts.count : posts.count
    }
        
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post: Post
        if isSearchActive {
            post = filteredPosts[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        
        if post.images.isEmpty {
            let cell = tableView.dequeue() as TextTableViewCell
            cell.contentPostLabel.isExpaded = false
            cell.configure(post: post)
            return cell
        } else {
            let cell = tableView.dequeue() as TextWithImagesTableViewCell
            cell.contentPostLabel.isExpaded = false
            cell.configure(post: post)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let post: Post
        if isSearchActive {
            post = filteredPosts[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }

        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "showPostView") as! ShowPostViewController
        vc.post = post
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    // MARK: Swipe to Delete
       func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
           let post: Post
           if self.isSearchActive {
               post = self.filteredPosts[indexPath.row]
           } else {
               post = self.posts[indexPath.row]
           }
           
           // Check if the post belongs to the current user
           if post.owner["id"] as? String == User.currentId {
               let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completionHandler) in
                   self.realtimeDatabaseManager.deletePost(post.id) { error in
                       if let error = error {
                           print("Failed to delete post: \(error.localizedDescription)")
                           completionHandler(false)
                       } else {
                           // Remove the post from the array and update the table view
                           if self.isSearchActive {
                               self.filteredPosts.remove(at: indexPath.row)
                           } else {
                               self.posts.remove(at: indexPath.row)
                           }
                           tableView.deleteRows(at: [indexPath], with: .automatic)
                           completionHandler(true)
                       }
                   }
               }
               return UISwipeActionsConfiguration(actions: [deleteAction])
           } else {
               // No swipe actions for posts that do not belong to the current user
               return nil
           }
       }


    // MARK: Pagination
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = tableView.contentSize.height
        let screenHeight = scrollView.frame.size.height

        // Load more data when the user reaches near the bottom
        if position > (contentHeight - screenHeight) {
            guard !realtimeDatabaseManager.isPagination else {
                // We are already fetching more data
                return
            }
            activityIndicatorView.startAnimating()
            // Start fetching more data
            realtimeDatabaseManager.isPagination = true
            let lastPostId = posts.last?.id // Retrieve the last post ID from the current posts
            realtimeDatabaseManager.getAllPosts(startingAfter: lastPostId) { [weak self] additionalPosts in
                guard let self = self else { return }

                // Check if there are additional posts
                if additionalPosts.isEmpty {
                    // No more posts to fetch
                    self.realtimeDatabaseManager.isPagination = false
                    self.activityIndicatorView.stopAnimating()
                    return
                }

                // Append the additional posts to the existing array
                for post in additionalPosts {
                    if !self.posts.contains(where: { $0.id == post.id }) {
                        self.posts.append(post)
                    }
                }

                DispatchQueue.main.async {
                    self.activityIndicatorView.stopAnimating()
                    // Reload the table view with the new data
                    self.tableView.reloadData()
                    self.realtimeDatabaseManager.isPagination = false
                }
            }
        }
    }
}

// MARK: UISearchResultsUpdating
extension CommunityViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            filteredPosts.removeAll()
            tableView.reloadData()
            return
        }

        RealtimeDatabaseManager.shared.getPostsMatchingSearchQuery(searchText) { [weak self] matchingPosts in
            guard let self = self else { return }
            self.filteredPosts = matchingPosts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: Private Methods
private extension CommunityViewController {
    func setupSearchBar(){
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "ابحث عن منشور"
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
