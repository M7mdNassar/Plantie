
import Foundation
import UIKit

// Post struct representing a post in the community feed
struct Post {
    let id: String // Unique identifier for the post
    let text: String? // Text content of the post
    let images: [String?] // URLs of images attached to the post
    let owner: [String: Any] // Dictionary representing the owner of the post
    var likes: Int // Number of likes for the post
    var dislikes: Int // Number of dislikes for the post
    var countOfComments: Int
    var isLiked: Bool = false
    var isDisliked: Bool = false
}


// Comment struct representing a comment on a post
struct Comment {
    let id: String // Unique identifier for the comment
    let text: String // Text content of the comment
    let owner: [String: Any] // Dictionary representing the owner of the post
    let postId: String // ID of the post the comment belongs to
}


