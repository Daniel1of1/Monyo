import UIKit

/// A wrapper around a `UIImageView` that takes has a settable `url` and updates its image with
/// the contents at that url.
final class IconView: UIView {

    // MARK: - UIView
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    public convenience init() {
        self.init(frame:.zero)
        setup()
    }
    
    // Mark: - Properties
    private let imageView = UIImageView()
    private var task: URLSessionDataTask? = nil
    public var url: URL? { // TODO: clean up this code and cache image
        didSet {
            updateImage(oldURL: oldValue, newURL: url)
        }
    }
    
    // Mark: - Setup
    func setup() {
        self.addSubview(imageView)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: self.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor)
            ])
    }

    // Mark: - Updating Image
    private func updateImage(oldURL: URL?, newURL: URL?) {
        if shouldClearCurrentImage(oldURL: oldURL, newURL: newURL) {
            imageView.image = nil
        }
        guard let url = newURL, url != oldURL else {
            return
        }
        if let cached = URLCache.shared.cachedResponse(for: URLRequest(url: url)), let image = UIImage(data:cached.data) {
            DispatchQueue.main.async {
                self.imageView.image = image
            }
            return
        }
        downloadNewImage(url: url)
    }
        
    
    
    private func shouldClearCurrentImage(oldURL: URL?, newURL: URL?) -> Bool {
        return newURL == nil || oldURL != newURL
    }
    
    
    private func downloadNewImage(url: URL) {
        task?.cancel()
        self.task = URLSession.shared.dataTask(with: url) { [weak self] d,r,e in
            if let data = d, let image = UIImage(data:data) {
                DispatchQueue.main.async {
                    if url == self?.url {
                        self?.imageView.image = image
                    }
                }
            }
        }
        self.task?.resume()
    }
    
}
