
import Foundation
import UIKit
import ProgressHUD
import FirebaseStorage

let storage = Storage.storage()

class FileStorage{
    
    
    // MARK: Images
    
    // Uplaod Image
    class func uploadImage(_ image: UIImage, directory: String, completion: @escaping (_ documentLink: String?) -> Void) {
           let storageRef = storage.reference().child(directory) // Use child method to create "folders"
           guard let imageData = image.jpegData(compressionQuality: 0.5) else {
               completion(nil)
               return
           }
           
           let imageName = UUID().uuidString + ".jpg"
           let imageRef = storageRef.child(imageName) // Specify the image name within the "folder"
           
           let task = imageRef.putData(imageData, metadata: nil) { metaData, error in
               if let error = error {
                   print("Error uploading image \(error.localizedDescription)")
                   completion(nil)
                   return
               }
               
               imageRef.downloadURL { url, error in
                   guard let downloadUrl = url else {
                       completion(nil)
                       return
                   }
                   completion(downloadUrl.absoluteString)
               }
           }
           
           task.observe(StorageTaskStatus.progress) { snapshot in
               let progress = Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount)
               ProgressHUD.progress(CGFloat(progress))
           }
       }
    
    // Download Image
    
    class func downloadImage(imageUrl: String, completion: @escaping (_ image: UIImage?) -> Void) {
          
          guard let documentUrl = URL(string: imageUrl) else {
              print("Invalid URL")
              completion(nil)
              return
          }
          
          let imageFileName = fileNameFrom(fileUrl: imageUrl)
          
          if fileExistsPath(path: imageFileName) {
              // file exists locally
              if let contentsOfFile = UIImage(contentsOfFile: fileInDocumentsDirectory(fileName: imageFileName)) {
                  completion(contentsOfFile)
              } else {
                  print("Could not convert local image")
                  completion(UIImage(named: "avatar"))
              }
          } else {
              // download from Firebase
              let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
              
              downloadQueue.async {
                  if let data = try? Data(contentsOf: documentUrl) {
                      FileStorage.saveFileLocally(fileData: data as NSData, fileName: imageFileName)
                      DispatchQueue.main.async {
                          completion(UIImage(data: data))
                      }
                  } else {
                      print("No document found in the database")
                      DispatchQueue.main.async {
                          completion(nil)
                      }
                  }
              }
          }
      }
    
  
    
    
    // save file locally in device (to make it fast in retrive , if not in local so, get it from firebase )
    
    class func saveFileLocally(fileData: NSData , fileName: String){
        let docUrl = getDocumentURL().appendingPathComponent(fileName, isDirectory: false)
        fileData.write(to: docUrl, atomically: true)
    }
    
}

// MARK: Helpers


func getDocumentURL() -> URL{
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
    
}


func fileInDocumentsDirectory(fileName: String) -> String{
    return getDocumentURL().appendingPathComponent(fileName).path
    
}

func fileExistsPath(path: String) -> Bool{
    return FileManager.default.fileExists(atPath: fileInDocumentsDirectory(fileName: path))
}
