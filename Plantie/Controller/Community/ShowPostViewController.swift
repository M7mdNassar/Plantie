import UIKit

class ViewController2: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    var headerView: UIView!
    let headerHeight: CGFloat = 250

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        headerView = tableView.tableHeaderView
        tableView.tableHeaderView = nil
        tableView.addSubview(headerView)
        tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -headerHeight)
        updateHeader()
    }

    func updateHeader() {
        // Check if there are items in the collection view
        let hasItemsInCollectionView = collectionView.numberOfItems(inSection: 0) > 0
        
        if hasItemsInCollectionView {
            // Adjust the header and content inset to accommodate the collection view
            headerView.frame.origin.y = 0
            headerView.frame.size.height = headerHeight
            tableView.contentInset = UIEdgeInsets(top: headerHeight, left: 0, bottom: 0, right: 0)
        } else {
            // If there are no items in the collection view, remove the empty space
            headerView.frame.origin.y = 0
            headerView.frame.size.height = 0
            tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
}

extension ViewController2: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "[\(indexPath.section),\(indexPath.row)]"
        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateHeader()
    }
}
