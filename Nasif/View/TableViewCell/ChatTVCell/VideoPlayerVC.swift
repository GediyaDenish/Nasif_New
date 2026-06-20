//
//  VideoPlayerVC.swift
//  Nasif
//
//  Created by Denish Gediya on 28/11/25.
//

import UIKit
import Foundation
import AVFoundation
import AVKit

class VideoPlayerVC: AVPlayerViewController {
    
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let shareBtn = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(shareTapped)
        )
        
        navigationItem.rightBarButtonItem = shareBtn
    }
    
    @objc private func shareTapped() {
        guard let remoteURL = videoURL else { return }
        
        if remoteURL.isFileURL {
            share(url: remoteURL)
        } else {
            downloadAndPrepareVideo(from: remoteURL)
        }
    }
    
    private func downloadAndPrepareVideo(from url: URL) {
        let fileName = url.lastPathComponent
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let localURL = documentsURL.appendingPathComponent(fileName)
        
        // If exists already → share directly
        if FileManager.default.fileExists(atPath: localURL.path) {
            share(url: localURL)
            return
        }
        
        // Download
        URLSession.shared.downloadTask(with: url) { tempURL, response, error in
            guard let tempURL = tempURL else {
                print("❌ Download failed:", error?.localizedDescription ?? "")
                return
            }
            
            do {
                try FileManager.default.moveItem(at: tempURL, to: localURL)
                
                // Apply correct UTI metadata
                try (localURL as NSURL).setResourceValue(UTType.movie.identifier, forKey: .typeIdentifierKey)
                
                DispatchQueue.main.async {
                    self.share(url: localURL)
                }
            } catch {
                print("❌ File move error:", error)
            }
            
        }.resume()
    }
    
    private func share(url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        DispatchQueue.main.async {
            self.present(activityVC, animated: true)
        }
    }
    
    private func downloadVideo(from url: URL) {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        
        let task = URLSession.shared.downloadTask(with: url) { downloadedURL, _, error in
            if let downloadedURL = downloadedURL {
                do {
                    // Copy file to temp directory
                    if FileManager.default.fileExists(atPath: tempURL.path) {
                        try FileManager.default.removeItem(at: tempURL)
                    }
                    try FileManager.default.copyItem(at: downloadedURL, to: tempURL)
                    
                    DispatchQueue.main.async {
                        self.share(localURL: tempURL)
                    }
                } catch {
                    print("Copy error:", error)
                }
            } else {
                print("Download failed:", error?.localizedDescription ?? "")
            }
        }
        task.resume()
    }
    
    private func share(localURL: URL) {
        let activityVC = UIActivityViewController(activityItems: [localURL], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        DispatchQueue.main.async {
            self.present(activityVC, animated: true)
        }
    }
}
