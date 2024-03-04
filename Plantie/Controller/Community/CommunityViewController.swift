

import UIKit

class CommunityViewController: UITableViewController {

    // MARK: Variables
    let searchController = UISearchController(searchResultsController: nil)

    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        
    }
    
    // MARK: Actions
    @IBAction func composeBarButton(_ sender: UIBarButtonItem) {
        
        let userView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddPostView") as! AddPostViewController
        self.navigationController?.pushViewController(userView, animated: true)
    }


}


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
    
    
}
