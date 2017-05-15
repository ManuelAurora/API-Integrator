//
//  ChachedImageView.swift
//  CoreKPI
//
//  Created by Manuel Aurora on 04.05.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class DiscardableImageCacheItem: NSObject, NSDiscardableContent
{
    private(set) public var image: UIImage?
    var accessCount: UInt = 0
    
    init(image: UIImage) {
        super.init()
        
        self.image = image
    }
    
    public func beginContentAccess() -> Bool {
        
        if image == nil
        {
            return false
        }
        
        accessCount += 1
        return true
    }
    
    public func endContentAccess() {
        
        if accessCount > 0
        {
            accessCount -= 1
        }
    }
    
    public func discardContentIfPossible() {
        
        if accessCount == 0
        {
            image = nil
        }
    }
    
    public func isContentDiscarded() -> Bool {
        
        return image == nil
    }
}

class CachedImageView: UIImageView
{
    open static let imageCache = NSCache<NSString, DiscardableImageCacheItem>()
    private var emptyImage = #imageLiteral(resourceName: "defaultProfile")
    private var urlStringForChecking: String?
    private let nc = NotificationCenter.default
    
    init(cornerRadius: Int = 0) {
        super.init(frame: .zero)
        
        layer.cornerRadius = CGFloat(cornerRadius)
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
    
    deinit {
        nc.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        subscribeToNotifications()
        let cornerRadius = frame.height / 2
        layer.cornerRadius = CGFloat(cornerRadius)
        contentMode = .scaleAspectFill
        clipsToBounds = true
    }
 
    private func subscribeToNotifications() {
       
        nc.addObserver(self,
                       selector: #selector(self.removeImage),
                       name: .userLoggedOut, object: nil)
    }
    
    @objc private func removeImage() {
        image = emptyImage
    }
    
    func loadImage(from urlString: String, completion: (()->())? = nil) {
        
        urlStringForChecking = urlString
        let urlKey = urlString as NSString
        
        if let cachedItem = CachedImageView.imageCache.object(forKey: urlKey)
        {
            image = cachedItem.image
            completion?()
            return
        }
        
        guard urlString != Request.avatarsLink, let url = URL(string: urlString) else {
            image = emptyImage
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else { return }
            
            if let imgData = data, let image = UIImage(data: imgData)
            {
                let cachedItem = DiscardableImageCacheItem(image: image)
                DispatchQueue.main.async {
                    CachedImageView.imageCache.setObject(cachedItem,
                                                          forKey: urlKey)
                    
                    if urlString == self.urlStringForChecking
                    {
                        self.image = image
                        completion?()
                    }
                }
            }
            
        }.resume()
    }
}
