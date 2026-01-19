
import UIKit
import SwiftUI

@MainActor
public protocol WebViewControllerDelegate: AnyObject {
    func webViewControllerDidLoad(_ controller: WebViewController)
    func webViewControllerDidFinish(_ controller: WebViewController)
}

@MainActor
public class WebViewController: UIViewController {
    
    public weak var delegate: WebViewControllerDelegate?
    private let url: URL
    
    public init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupSwiftUI()
        view.backgroundColor = .systemBackground
    }
    
    private func setupSwiftUI() {
        let adView = AdView(url: url, onClose: { [weak self] in
            self?.handleClose()
        }, onLoad: { [weak self] in
            guard let self = self else { return }
            self.delegate?.webViewControllerDidLoad(self)
        })
        
        let hostingController = UIHostingController(rootView: adView)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear // Important for transparency if needed
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        hostingController.didMove(toParent: self)
    }
    
    private func handleClose() {
        dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.delegate?.webViewControllerDidFinish(self)
        }
    }
}
