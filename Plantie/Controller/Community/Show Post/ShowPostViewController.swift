import UIKit
import SKPhotoBrowser

class ShowPostViewController: UIViewController {
    
    // MARK: Variables
    let images = [UIImage(named: "one")! ,UIImage(named: "avatar")! ]
    
//    var post:Post!
    var skPhotoImages: [SKPhoto] = []

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        setupTableView()
        addNotifications()
        setUpTextView()
        //Move it
        // Prepare SKPhoto array for SKPhotoBrowser
             for image in images {
                 skPhotoImages.append(SKPhoto.photoWithImage(image))
             }
        
        
    

    }
    
    // MARK: Actions
    
    @IBAction func closeButton(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func sendComment(_ sender: UIButton) {
    }
    
    // MARK: private Methods
    
    func setupCollectionView(){
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let nib = UINib(nibName: "CollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "CollectionViewCell")
    }
    
    func setupTableView(){
        tableView.dataSource = self
        tableView.delegate = self
        
    }
    
    func setUpTextView() {
       textView.layer.cornerRadius = 15.0
       textView.layer.borderColor = UIColor.quaternaryLabel.cgColor
       textView.layer.borderWidth = 1.0
       textView.delegate = self
   }
   

}


// MARK: - UITextViewDelegate

extension ShowPostViewController: UITextViewDelegate {

    func textViewDidChange(_ textView: UITextView) {

        updateTextViewHeight()
    }

    private func updateTextViewHeight() {
         let maxTextViewHeight: CGFloat = 50.0
        let newSize = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        let newHeight = min(newSize.height, maxTextViewHeight)
        textViewHeightConstraint.constant = newHeight
    }

}

// MARK: TableView Datasource
extension ShowPostViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "[\(indexPath.section),\(indexPath.row)]"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         // Create and present SKPhotoBrowser
         let browser = SKPhotoBrowser(photos: skPhotoImages)
         browser.initializePageIndex(indexPath.row)
         present(browser, animated: true, completion: nil)
     }
    
   
}

// MARK: CollectionView Datasource

extension ShowPostViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.postImageView?.image = images[indexPath.row]
        return cell
    }
}

extension ShowPostViewController: UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - Keyboard Handling

extension ShowPostViewController {

    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height

            bottomConstraint.constant = keyboardHeight
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }

        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

        
    }

}