//
//  PDFPreviewController.swift
//  Nasif
//
//  Created by Denish Gediya on 28/11/25.
//

import UIKit
import PDFKit
import UniformTypeIdentifiers

import UIKit
import PDFKit
import UniformTypeIdentifiers

class PDFPreviewController: UIViewController {
    
    var pdfURL: URL?
    private var pdfView = PDFView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavigation()
        setupPDF()
    }
    
    
    // MARK: - UI SETUP
    private func setupNavigation() {
        
        title = pdfURL?.lastPathComponent
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closePDF)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .action,
            target: self,
            action: #selector(sharePDF)
        )
    }
    
    
    private func setupPDF() {
        pdfView.frame = view.bounds
        pdfView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        pdfView.autoScales = true
        
        if let url = pdfURL {
            pdfView.document = PDFDocument(url: url)
        }
        
        view.addSubview(pdfView)
    }
    
    
    // MARK: - ACTIONS
    @objc func closePDF() {
        dismiss(animated: true)
    }
    
    
    @objc func sharePDF() {
        guard let remoteURL = pdfURL else { return }
        
        let fileName = remoteURL.lastPathComponent
        
        // Save destination
        let destURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent(fileName)
        
        // If file already downloaded and valid → share immediately
        if FileManager.default.fileExists(atPath: destURL.path),
           PDFDocument(url: destURL) != nil {
            shareFile(destURL)
            return
        }
        
        // Download fresh copy
        downloadPDF(remoteURL, saveTo: destURL)
    }
    
    
    private func downloadPDF(_ remoteURL: URL, saveTo destination: URL) {
        
        URLSession.shared.dataTask(with: remoteURL) { data, response, error in
            
            guard let data = data, error == nil else {
                print("❌ Download error:", error?.localizedDescription ?? "")
                return
            }
            
            do {
                // Save clean File
                try data.write(to: destination, options: .atomic)
                
                // Validate file
                guard PDFDocument(url: destination) != nil else {
                    print("❌ File saved but INVALID PDF format")
                    return
                }
                
                DispatchQueue.main.async {
                    self.shareFile(destination)
                }
                
            } catch {
                print("❌ Write error:", error)
            }
            
        }.resume()
    }
    
    private func shareFile(_ url: URL) {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        present(activityVC, animated: true)
    }
}
