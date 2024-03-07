import Foundation
import FirebaseDatabase

class RealtimeDatabaseManager {
    
    // MARK: Variables
    
    static let shared = RealtimeDatabaseManager()
    private let databaseRef = Database.database().reference()
    var refHandle = DatabaseHandle()
    var isPagination = false
    
    // MARK: Add post to Realtime Database
    
    func addPost(post: Post) {
        let postData: [String: Any] = [
            "id": post.id,
            "text": post.text ?? "",
            "images": post.images ,
            "owner": [
                "id": post.owner["id"] ?? "",
                "userName": post.owner["userName"] ?? "",
                "email": post.owner["email"] ?? "",
                "pushId": post.owner["pushId"] ?? "",
                "avatarLink": post.owner["avatarLink"] ?? "",
                "bio": post.owner["bio"] ?? "",
                "country": post.owner["country"] ?? ""
            ],
            "likes": post.likes,
            "dislikes": post.dislikes,
            "countOfComments": post.countOfComments
        ]


        let postRef = databaseRef.child("posts").childByAutoId()
        postRef.setValue(postData) { error, _ in
            if let error = error {
                print("Error adding post: \(error.localizedDescription)")
            } else {
                print("Post added successfully!")
            }
        }
    }

    
    // MARK: get posts from Firebase Realtime Database
    
    func getAllPosts(completion: @escaping ([Post]) -> Void){
        
        databaseRef.child("posts").observeSingleEvent(of: .value, with: { snapshot in
          // Get user value
            
            var posts:[Post] = []
            
            for child in snapshot.children{
                guard let childSnapshot = child as? DataSnapshot,
                    let postData = childSnapshot.value as? [String: Any] else { continue }
                
                let post = Post(
                    id: childSnapshot.key,
                    text: postData["text"] as? String,
                    images: postData["images"] as? [String] ?? [],
                    owner: postData["owner"] as! [String: Any],
                    likes: postData["likes"] as! Int,
                    dislikes: postData["dislikes"] as! Int,
                    countOfComments: postData["countOfComments"] as! Int
                )
                posts.append(post)
            }
         completion(posts)
            
        }) { error in
          print(error.localizedDescription)
        }
        
    }
   
}


