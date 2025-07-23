//
//  DetailViewController.swift
//  ios101-project6-tumblr
//
//  Created by Derrick Woodall on 7/22/25.
//
import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    var post: Post?  // optional to avoid crashes
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            title = "Post Detail"
            captionTextView.isEditable = false
            captionTextView.isScrollEnabled = true
            
            guard let post = post else {
                print("❌ No post data")
                return
            }
            
            //captionTextView.text = post.caption
            //captionTextView.attributedText = post.caption.htmlToAttributedString
            
            if let attributedString = post.caption.htmlToAttributedString {
                let mutableAttributed = NSMutableAttributedString(attributedString: attributedString)
                mutableAttributed.addAttributes([
                    .font: UIFont.systemFont(ofSize: 17)
                ], range: NSRange(location: 0, length: mutableAttributed.length))
                captionTextView.attributedText = mutableAttributed
            }
            
            if let firstPhoto = post.photos.first {
                let url = firstPhoto.originalSize.url
                // Load image from url
                URLSession.shared.dataTask(with: url) { data, _, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            self.postImageView.image = UIImage(data: data)
                        }
                    }
                }.resume()
            } else {
                postImageView.image = UIImage(named: "placeholder") // optional fallback image
            }
            
        }
    }
extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil
            )
        } catch {
            print("❌ Error converting HTML: \(error)")
            return nil
        }
    }

    var htmlToString: String {
        return htmlToAttributedString?.string ?? self
    }
}
