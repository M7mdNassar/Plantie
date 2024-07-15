
import UIKit
import FirebaseDatabase
import FirebaseStorage
import Gallery
import ProgressHUD
import IQKeyboardManagerSwift


class AddPostViewController: UIViewController {

    // MARK: Variables
    let currentUser = User.currentUser
    var images: [UIImage] = []
    var gallery: GalleryController!
    
    // MARK: Outlets
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var postContent: UITextView!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstrain:NSLayoutConstraint!
    @IBOutlet weak var topBarStackViewOutlet: UIStackView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addNotifications()
        tapGestureToHideKeyboard()
        setUpCollection()
        setUpTextView()
        setUpView()
        
        IQKeyboardManager.shared.enable = false
    }
    
    // MARK: Actions
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true)
        
    }
    @IBAction func AddImagesButton(_ sender: UIButton) {
        showGallery()
    }
    
    @IBAction func postButton(_ sender: UIButton) {
        guard let content = postContent.text, content != "اكتب منشورك هنا..." || !images.isEmpty else {
              ProgressHUD.error("الرجاء إدخال محتوى أو إضافة صورة واحدة على الأقل")
              return
          }
        if !Reachability.isConnectedToNetwork() {
                  ProgressHUD.error("لا يوجد اتصال بالإنترنت. الرجاء التحقق من اتصالك والمحاولة مرة أخرى.")
                  return
              }
              
    
        var imageUrls: [String] = []
        let dispatchGroup = DispatchGroup()
        
        for image in images {
            dispatchGroup.enter()
            FileStorage.uploadImage(image, directory: "PostImages") { imageUrl in
                if let imageUrl = imageUrl {
                    imageUrls.append(imageUrl)
                } else {
                    ProgressHUD.error("فشل في التحميل")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            let currentUser = User.currentUser!
            let ownerDict: [String: Any] = [
                "id": currentUser.id,
                "userName": currentUser.userName,
                "email": currentUser.email,
                "pushId": currentUser.pushId,
                "avatarLink": currentUser.avatarLink,
                "bio": currentUser.bio,
                "country": currentUser.country
            ]
            
            let post = Post(
                id: UUID().uuidString,
                text: content == "اكتب منشورك هنا..." ? "": content,
                images: imageUrls,
                owner: ownerDict,
                likes: 0,
                dislikes: 0,
                countOfComments: 0
            )
            
            RealtimeDatabaseManager.shared.addPost(post: post)
            self.dismiss(animated: true)
            ProgressHUD.success("تم النشر ")
        }
    }

}

// MARK: Private Methods

private extension AddPostViewController {
    
    func setUpCollection() {
        collectionView.delegate = self
        collectionView.dataSource = self
        let nib = UINib(nibName: "ImagesPostCollectionViewCell", bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: "ImagesPostCollectionViewCell")
    }
    
    func setUpTextView() {
        postContent.delegate = self
        postContent.text = "اكتب منشورك هنا..." // Set the initial placeholder
        postContent.textColor = UIColor.lightGray
    }
    
    func setUpView() {
        self.userImageView.sd_setImage(with: URL(string: self.currentUser!.avatarLink))
        self.userImageView.layer.cornerRadius = self.userImageView.frame.width / 2
        
        self.userNameLabel.text = self.currentUser!.userName
        
        self.postButton.layer.cornerRadius = 15
        self.postButton.clipsToBounds = true
        
        self.topBarStackViewOutlet.layer.cornerRadius = 15
        self.postButton.clipsToBounds = true

    }
}

// MARK: Gallery

extension AddPostViewController : GalleryControllerDelegate{
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectImages images: [Gallery.Image]) {
         self.collectionViewHeightConstrain.constant = 100
         for image in images {
             image.resolve { resolvedImage in
                 if let resolvedImage = resolvedImage {
                     self.images.append(resolvedImage)
                     self.collectionView.reloadData()
                 }
             }
         }
         controller.dismiss(animated: true, completion: nil)
     }

    // this methods i dont need , so dismiss it
    
    func galleryController(_ controller: Gallery.GalleryController, didSelectVideo video: Gallery.Video) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryController(_ controller: Gallery.GalleryController, requestLightbox images: [Gallery.Image]) {
        controller.dismiss(animated: true, completion: nil)
        
    }
    
    func galleryControllerDidCancel(_ controller: Gallery.GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func showGallery(){
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab , .cameraTab]
        Config.Camera.imageLimit = 3
        Config.initialTab = .imageTab
        self.present(self.gallery, animated: true)
    }
}


// MARK: UICollectionViewDataSource, UICollectionViewDelegate

extension AddPostViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
   
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImagesPostCollectionViewCell", for: indexPath) as! ImagesPostCollectionViewCell
    cell.imageView.image = images[indexPath.item]
    return cell
  }
   
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 100)
  }
}

// MARK: TextView
extension AddPostViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
      // Remove placeholder when the user starts typing
      if textView.text == "اكتب منشورك هنا..." {
        textView.text = ""
        textView.textColor = UIColor.black // Set text color to black
      }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
      // Add placeholder if the text is empty
      if textView.text.isEmpty {
        textView.text = "اكتب منشورك هنا..."
        textView.textColor = UIColor.lightGray // Set text color to lightGray
      }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder() // Hide keyboard when return key is pressed
            return false
        }
        return true
    }
    
}

// MARK: - Keyboard Handling

extension AddPostViewController {

    func addNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height

            bottomConstraint.constant = -keyboardHeight - 20
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }

        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        bottomConstraint.constant = -20
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }

        
    }

    func tapGestureToHideKeyboard(){
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
 
        view.addGestureRecognizer(tap)
    }
    @objc func dismissKeyboard() {
           view.endEditing(true)
       }
    
}

