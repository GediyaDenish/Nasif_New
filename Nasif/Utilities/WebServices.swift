//
//  WebServices.swift
//  Nasif
//
//  Created by Denish Gediya on 03/07/25.
//

import Foundation
import Alamofire
import UIKit

// MARK: - WebServices Class
class WebServices {
    typealias ApiHandler<T: Decodable> = (_ response: T?) -> ()
    
    /// Shows a "No Internet" alert with Retry/Cancel on the topmost view controller
    static func showNetworkAlert(on vc: UIViewController? = nil, retryHandler: @escaping () -> Void) {
        // Get top-most VC if nil
        let topVC = vc ?? UIApplication.shared.topMostViewController()
        guard let viewController = topVC else { return }
        
        let alert = UIAlertController(
            title: NSLocalizedString("No Internet", comment: ""),
            message: NSLocalizedString("Please check your internet connection and try again.", comment: ""),
            preferredStyle: .alert
        )
        
        let retryAction = UIAlertAction(title: NSLocalizedString("Retry", comment: ""), style: .default) { _ in
            retryHandler()
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel)
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        
        // iPad safety
        if let popover = alert.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(
                x: viewController.view.bounds.midX,
                y: viewController.view.bounds.midY,
                width: 0,
                height: 0
            )
            popover.permittedArrowDirections = []
        }
        
        viewController.present(alert, animated: true)
    }
}

// MARK: - Headers
extension WebServices {
    class func getHeaders() -> HTTPHeaders {
        var headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "x-version": "1.0",
            "x-os": "ios",
            "x-timezone": TimeZone.current.identifier
        ]
        
        let token = UserDefaultsHelper.shared.token
        if !token.isEmpty {
            headers["Authorization"] = "Bearer \(token)"
            print("🔑 Auth Token:", token)
        }
        return headers
    }
}

// MARK: - Requests
extension WebServices {
    
    class func Get<T: Decodable>(url: String, type: T.Type, completionHandler: ApiHandler<T>?) {
        performRequest(url: url, method: .get, params: nil, type: type, completionHandler: completionHandler)
    }
    
    class func Delete<T: Decodable>(url: String, type: T.Type, completionHandler: ApiHandler<T>?) {
        performRequest(url: url, method: .delete, params: nil, type: type, completionHandler: completionHandler)
    }
    
    class func Post<T: Decodable>(url: String, params: [String: Any], type: T.Type, completionHandler: ApiHandler<T>?) {
        performRequest(url: url, method: .post, params: params, type: type, completionHandler: completionHandler)
    }
    
    class func Put<T: Decodable>(url: String, params: [String: Any], type: T.Type, completionHandler: ApiHandler<T>?) {
        performRequest(url: url, method: .put, params: params, type: type, completionHandler: completionHandler)
    }
    
    private class func performRequest<T: Decodable>(
        url: String,
        method: HTTPMethod,
        params: [String: Any]?,
        type: T.Type,
        completionHandler: ApiHandler<T>?
    ) {
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 180
        
        manager.request("\(WebService.APIConfig.API)\(url)",
                        method: method,
                        parameters: params,
                        encoding: JSONEncoding.default,
                        headers: self.getHeaders())
        .responseDecodable(of: T.self) { response in
            handleResponse(response, completionHandler: completionHandler) {
                // Retry closure without weak self
                performRequest(url: url, method: method, params: params, type: type, completionHandler: completionHandler)
            }
        }
    }
    
    class func Body<T: Decodable>(url: String, method: HTTPMethod, body: Data, completionHandler: ApiHandler<T>?) {
        var requestData = URLRequest(url: URL(string: url)!)
        requestData.httpMethod = method.rawValue
        requestData.httpBody = body
        requestData.allHTTPHeaderFields = self.getHeaders().dictionary
        
        let manager = Alamofire.Session.default
        manager.session.configuration.timeoutIntervalForRequest = 180
        
        manager.request(requestData)
            .responseDecodable(of: T.self) { response in
                handleResponse(response, completionHandler: completionHandler) {
                    // Retry call without capturing 'type'
                    Body(url: url, method: method, body: body, completionHandler: completionHandler)
                }
            }
    }
}

// MARK: - Handle Response + API Debug Logger
extension WebServices {
    
    private class func handleResponse<T: Decodable>(
        _ response: AFDataResponse<T>,
        completionHandler: ApiHandler<T>?,
        retryHandler: @escaping () -> Void
    ) {
        print("\n================= 🌍 API DEBUG LOG =================")
        
        // Request Info
        if let request = response.request {
            let url = request.url?.absoluteString ?? "N/A"
            let method = request.httpMethod ?? "N/A"
            print("➡️ Request URL   : \(url)")
            print("➡️ HTTP Method   : \(method)")
            
            if let body = request.httpBody,
               let bodyString = String(data: body, encoding: .utf8) {
                print("➡️ Request Body:\n\(bodyString)")
            }
        }
        
        // Response Info
        if let statusCode = response.response?.statusCode {
            print("⬅️ Status Code   : \(statusCode)")
        }
        
        if let data = response.data {
            if let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted),
               let prettyString = String(data: prettyData, encoding: .utf8) {
                print("⬅️ Response Body:\n\(prettyString)")
            } else if let rawString = String(data: data, encoding: .utf8) {
                print("⬅️ Response Body:\n\(rawString)")
            }
        }
        
        print("====================================================\n")
        
        // Result Handling
        switch response.result {
        case .success(let value):
            let statusCode = response.response?.statusCode ?? 0
            switch statusCode {
            case 200:
                completionHandler?(value)
            case 401:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    Utility.showToast(message: message.localized)
                    Utility.signOut()
                }
                completionHandler?(nil)
            default:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    Utility.showToast(message: message.localized)
                }
                completionHandler?(nil)
            }
            
        case .failure(let error):
            print("❌ Request failed: \(error.localizedDescription)")
            let statusCode = response.response?.statusCode ?? 0
            switch statusCode {
            case 401:
                if let data = response.data,
                   let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let message = json["message"] as? String {
                    Utility.showToast(message: message.localized)
                    Utility.signOut()
                }
                completionHandler?(nil)
            default:
                // No Internet Handling
                if let afError = error.asAFError,
                   case .sessionTaskFailed(let urlError as URLError) = afError,
                   urlError.code == .notConnectedToInternet {
                    
                    if let topVC = UIApplication.shared.topMostViewController() {
                        WebServices.showNetworkAlert(on: topVC) {
                            retryHandler()
                        }
                    }
                } else if let data = response.data,
                          let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                          let message = json["message"] as? String {
                    Utility.showToast(message: message.localized)
                }
                
                completionHandler?(nil)
            }
        }
    }
}

// MARK: - UIApplication Top Most VC
extension UIApplication {
    func topMostViewController(base: UIViewController? = UIApplication.shared.connectedScenes
        .filter { $0.activationState == .foregroundActive }
        .compactMap { $0 as? UIWindowScene }
        .first?.windows
        .filter { $0.isKeyWindow }.first?.rootViewController) -> UIViewController? {
            
            if let nav = base as? UINavigationController {
                return topMostViewController(base: nav.visibleViewController)
            }
            if let tab = base as? UITabBarController {
                if let selected = tab.selectedViewController {
                    return topMostViewController(base: selected)
                }
            }
            if let presented = base?.presentedViewController {
                return topMostViewController(base: presented)
            }
            return base
        }
}
