//
//  ImageCacheManager.swift
//  NewsApp
//
//  Created by Yaroslav Merinov on 27.08.25.
//

import UIKit

final class ImageCacheManager {
    
    //MARK: - Properties
    
    static let shared = ImageCacheManager()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() { }
    
    // MARK: - Public Methods
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: url as NSURL) {
            DispatchQueue.main.async {
                completion(cachedImage)
            }
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            var image: UIImage? = nil
            if let data = data, let downloadedImage = UIImage(data: data) {
                image = downloadedImage
                self.cache.setObject(downloadedImage, forKey: url as NSURL)
            }
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}
