//
//  ImagePicker.swift
//  Nasif
//
//  Created by Denish Gediya on 01/07/25.
//

import UIKit
import AVFoundation
import PhotosUI
import UniformTypeIdentifiers

class ImagePicker: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {

    enum PickerType {
        case single
        case multiple
    }

    var handler: ((UIImage, URL?) -> ())?
    var multiHandler: (([UIImage]) -> ())?
    var videoHandler: ((URL) -> ())?

    private var picker = UIImagePickerController()
    private weak var viewController: UIViewController?
    private var isAllowsEditing: Bool = false
    private var pickerType: PickerType = .single

    // MARK: - Main Method
    func pickImage(_ viewController: UIViewController,
                   _ title: String = "",
                   type: PickerType = .single,
                   allowsEditing: Bool = false,
                   allowVideo: Bool = true,
                   handler: ((UIImage, URL?) -> ())? = nil,
                   multiHandler: (([UIImage]) -> ())? = nil,
                   videoHandler: ((URL) -> ())? = nil) {

        self.viewController = viewController
        self.isAllowsEditing = allowsEditing
        self.handler = handler
        self.multiHandler = multiHandler
        self.videoHandler = videoHandler
        self.pickerType = type

        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alert.addAction(UIAlertAction(title: "Camera".localized, style: .default) { _ in
                self.openCamera(allowVideo: allowVideo)
            })
        }

        alert.addAction(UIAlertAction(title: "Gallery".localized, style: .default) { _ in
            if #available(iOS 14, *) {
                self.openPHPicker(type: type, allowVideo: allowVideo)
            } else {
                self.openGallery(allowVideo: allowVideo)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
        viewController.present(alert, animated: true)
    }

    // MARK: - Camera
    private func openCamera(allowVideo: Bool) {
        picker.delegate = self
        picker.allowsEditing = isAllowsEditing
        picker.sourceType = .camera
        picker.mediaTypes = allowVideo ? ["public.image", "public.movie"] : ["public.image"]
        viewController?.present(picker, animated: true)
    }

    // MARK: - Gallery (< iOS 14)
    private func openGallery(allowVideo: Bool) {
        picker.delegate = self
        picker.allowsEditing = isAllowsEditing
        picker.sourceType = .photoLibrary
        picker.mediaTypes = allowVideo ? ["public.image", "public.movie"] : ["public.image"]
        viewController?.present(picker, animated: true)
    }

    // MARK: - PHPicker (iOS 14+)
    @available(iOS 14, *)
    private func openPHPicker(type: PickerType, allowVideo: Bool) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.selectionLimit = (type == .multiple) ? 0 : 1
        config.filter = allowVideo ? .any(of: [.images, .videos]) : .images

        let pickerVC = PHPickerViewController(configuration: config)
        pickerVC.delegate = self
        viewController?.present(pickerVC, animated: true)
    }

    // MARK: - PHPicker Result Handler (Fixed)
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }

        var selectedImages: [UIImage] = []
        let dispatchGroup = DispatchGroup()

        for result in results {
            let provider = result.itemProvider

            // ----------- 🎥 VIDEO FIX --------------
            if provider.hasItemConformingToTypeIdentifier(UTType.movie.identifier) {
                dispatchGroup.enter()

                provider.loadFileRepresentation(forTypeIdentifier: UTType.movie.identifier) { tempURL, _ in
                    defer { dispatchGroup.leave() }
                    guard let tempURL = tempURL else { return }

                    let targetURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent("\(UUID().uuidString).mp4")

                    try? FileManager.default.copyItem(at: tempURL, to: targetURL)

                    DispatchQueue.main.async {
                        self.videoHandler?(targetURL)
                    }
                }
                continue
            }
            // ----------------------------------------


            // ----------- 🖼 IMAGE HANDLING ----------
            if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                dispatchGroup.enter()

                provider.loadFileRepresentation(forTypeIdentifier: UTType.image.identifier) { tempURL, _ in
                    defer { dispatchGroup.leave() }
                    guard let tempURL = tempURL else { return }

                    let targetURL = FileManager.default.temporaryDirectory
                        .appendingPathComponent(UUID().uuidString + ".jpg")

                    try? FileManager.default.copyItem(at: tempURL, to: targetURL)

                    if let data = try? Data(contentsOf: targetURL),
                       let img = UIImage(data: data) {
                        let small = img.preparingThumbnail(of: CGSize(width: 1800, height: 1800))
                        selectedImages.append(small ?? img)
                    }
                }
            }
        }

        dispatchGroup.notify(queue: .main) {
            if !selectedImages.isEmpty {
                if self.pickerType == .single {
                    self.handler?(selectedImages.first!, nil)
                } else {
                    self.multiHandler?(selectedImages)
                }
            }
        }
    }

    // MARK: - UIImagePickerController Handler (Camera/Gallery < iOS 14)
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        picker.dismiss(animated: true)

        if let videoURL = info[.mediaURL] as? URL {
            videoHandler?(videoURL)
        } else if let img = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage {
            if pickerType == .single {
                handler?(img, nil)
            } else {
                multiHandler?([img])
            }
        }
    }
}
