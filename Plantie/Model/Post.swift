
import Foundation
import UIKit

struct Post {
    var postId: String
    var owner: User
    var content: String
    var imageUrls: [String?]
    var likes: Int
    var comments: [Comment]
}

struct Comment {
    var id: String
    var postId: String
    var owner: User
    var message: String
    
}

