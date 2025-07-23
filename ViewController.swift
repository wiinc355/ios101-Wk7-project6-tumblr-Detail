//
//  ViewController.swift
//  ios101-project6-tumblr
//

import UIKit
import NukeExtensions

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blog Post"
        //navigationItem.backButtonTitle = ""
        tableView.dataSource = self
        tableView.delegate = self
        fetchPosts()
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.summaryLabel.text = post.summary
        
        if let photo = post.photos.first {
            NukeExtensions.loadImage(with: photo.originalSize.url, into: cell.postImageView)
        }
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "showDetail", sender: tableView.cellForRow(at: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let detailVC = segue.destination as? DetailViewController,
               let indexPath = tableView.indexPathForSelectedRow {
                let selectedPost = posts[indexPath.row]
                detailVC.post = selectedPost
            }
        }
    }
    
    // MARK: - Networking
    
    func fetchPosts() {
        let url = URL(string: "https://api.tumblr.com/v2/blog/humansofnewyork/posts/photo?api_key=1zT8CiXGXFcQDyMFG7RtcfGLwTdDjFUJnZzKJaWTmgyK4lKGYk")!
        
        let session = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, (200...299).contains(statusCode) else {
                print("❌ Response error: \(String(describing: response))")
                return
            }
            
            guard let data = data else {
                print("❌ Data is NIL")
                return
            }
            
            do {
                let blog = try JSONDecoder().decode(Blog.self, from: data)
                
                DispatchQueue.main.async { [weak self] in
                    self?.posts = blog.response.posts
                    self?.tableView.reloadData()
                    
                    print("✅ We got \(blog.response.posts.count) posts!")
                }
            } catch {
                print("❌ Error decoding JSON: \(error.localizedDescription)")
            }
        }
        session.resume()
    }
}

