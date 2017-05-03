//
//  UIImageExtension.swift
//  CoreKPI
//
//  Created by Семен Осипов on 04.01.17.
//  Copyright © 2017 SmiChrisSoft. All rights reserved.
//

import UIKit

extension UIImageView {
    
    private func getImageAt(path: String) -> UIImage? {
        
       return UIImage(contentsOfFile: path)
    }
    
    
    private func localPathFor(url: URL) -> URL {
        
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask).first!
        return path.appendingPathComponent(url.lastPathComponent)
    }
    
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        contentMode = mode
        
        let localPath = self.localPathFor(url: url)
        let fileManager = FileManager.default
        
        guard !fileManager.fileExists(atPath: localPath.path) else {
            if let image = getImageAt(path: localPath.path)
            {
                self.image = image
            }
            return
        }
        
        URLSession.shared.downloadTask(with: url) {
            (location, response, error) in
            
            guard let httpURLResponse = response as? HTTPURLResponse,
                httpURLResponse.statusCode == 200,
                error == nil,
                let location = location
                else { return }

            do {
                try fileManager.copyItem(at: location, to: localPath)
            }
            catch let error {
                print(error.localizedDescription)
            }
            
            DispatchQueue.main.async() { () -> Void in
                
                if let image = self.getImageAt(path: localPath.path)
                {
                    self.image = image
                    let userInfo: [String: Any] = ["UIImageViewTag": self.tag,
                                                   "photo": image]
                    
                    NotificationCenter.default.post(name: .profilePhotoDownloaded,
                                                    object: nil,
                                                    userInfo: userInfo)
                }
            }
        }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

extension UIImage {
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    func resized(toWidth width: CGFloat) -> UIImage? {
        let canvasSize = CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
