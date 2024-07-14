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
    
    func getAllPosts(startingAfter start : String? = nil , limit: UInt = 10 , completion: @escaping ([Post]) -> Void){
        
        
        var query = databaseRef.child("posts").queryOrderedByKey().queryLimited(toFirst: limit)
        
        if let start = start {
            // Query posts starting after the last retrieved post ID
            query = query.queryStarting(afterValue: start)
        }
        
    
        query.observeSingleEvent(of: .value) { snapshot in
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
            
        }
        
    }
    
    
    
    func getPostsMatchingSearchQuery(_ query: String, completion: @escaping ([Post]) -> Void) {
        let ref = Database.database().reference().child("posts")
        let query = ref.queryOrdered(byChild: "text").queryStarting(atValue: query).queryEnding(atValue: query + "\u{f8ff}")
        
        query.observeSingleEvent(of: .value) { snapshot in
            var matchingPosts: [Post] = []
            
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let postData = childSnapshot.value as? [String: Any] {
                    let post = Post(
                        id: childSnapshot.key,
                        text: postData["text"] as? String,
                        images: postData["images"] as? [String] ?? [],
                        owner: postData["owner"] as? [String: Any] ?? [:],
                        likes: postData["likes"] as? Int ?? 0,
                        dislikes: postData["dislikes"] as? Int ?? 0,
                        countOfComments: postData["countOfComments"] as? Int ?? 0
                    )
                    matchingPosts.append(post)
                }
            }
            
            completion(matchingPosts)
        }
    }

    
    
    
    func addComment(comment: Comment, completion: @escaping (Error?) -> Void) {
            let commentData: [String: Any] = [
                "id": comment.id,
                "text": comment.text,
                "owner": comment.owner,
                "postId": comment.postId
            ]

            let commentRef = databaseRef.child("comments").childByAutoId()
            commentRef.setValue(commentData) { error, _ in
                completion(error)
            }
        }

        func getAllComments(forPost postId: String, completion: @escaping ([Comment]) -> Void) {
            databaseRef.child("comments")
                .queryOrdered(byChild: "postId")
                .queryEqual(toValue: postId)
                .observeSingleEvent(of: .value, with: { snapshot in
                    var comments: [Comment] = []

                    for child in snapshot.children {
                        guard let childSnapshot = child as? DataSnapshot,
                            let commentData = childSnapshot.value as? [String: Any] else { continue }

                        let comment = Comment(
                            id: childSnapshot.key,
                            text: commentData["text"] as? String ?? "",
                            owner: commentData["owner"] as? [String: Any] ?? [:],
                            postId: postId
                        )
                        comments.append(comment)
                    }

                    completion(comments)
                }) { error in
                    print("Error getting comments: \(error.localizedDescription)")
                    completion([])
                }
        }

    
    func updateLikes(forPost postId: String, increment: Int, completion: @escaping (Error?) -> Void) {
         let postRef = databaseRef.child("posts").child(postId)
         postRef.child("likes").observeSingleEvent(of: .value) { snapshot in
             if var likes = snapshot.value as? Int {
                 likes += increment
                 postRef.child("likes").setValue(likes) { error, _ in
                     completion(error)
                 }
             } else {
                 completion(NSError(domain: "RealtimeDatabaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Likes data not found"]))
             }
         }
     }

     func updateDislikes(forPost postId: String, increment: Int, completion: @escaping (Error?) -> Void) {
         let postRef = databaseRef.child("posts").child(postId)
         postRef.child("dislikes").observeSingleEvent(of: .value) { snapshot in
             if var dislikes = snapshot.value as? Int {
                 dislikes += increment
                 postRef.child("dislikes").setValue(dislikes) { error, _ in
                     completion(error)
                 }
             } else {
                 completion(NSError(domain: "RealtimeDatabaseManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "Dislikes data not found"]))
             }
         }
     }
   
    
    func updateCommentCount(forPost postId: String, count: Int, completion: ((Error?) -> Void)?) {
        let postRef = databaseRef.child("posts").child(postId)
        postRef.updateChildValues(["countOfComments": count]) { error, _ in
            completion?(error)
        }
    }
    
    // MARK: Delete a post from Realtime Database
       
    func deletePost(_ postId: String, completion: @escaping (Error?) -> Void) {
        databaseRef.child("posts").child(postId).removeValue { error, _ in
            completion(error)
        }
    }


}


