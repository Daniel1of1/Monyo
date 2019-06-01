import UIKit

class EdgeScrollView: UIScrollView, UIGestureRecognizerDelegate {
    let gr = UIScreenEdgePanGestureRecognizer()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer != gr {
            if self.contentOffset.x > 0 { return true }
            return gr.state == .possible
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (otherGestureRecognizer == gr)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return gestureRecognizer == gr
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init() {
        self.init(frame:.zero)
        gr.edges = .right
        gr.delegate = self
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class DebugViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    @objc func reload()
    {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Current.history.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let historyItem = Current.history[indexPath.row]
        cell.textLabel?.text = String(String(describing: historyItem.message).prefix(50))
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let historyItem = Current.history[indexPath.row]
        Current.reset(model: historyItem.model)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    func update(model: Model) {
        self.tableView.reloadData()
    }
    
}


class DebugViewContainer: UIViewController, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    let debugVC = DebugViewController()
    let scrollView = EdgeScrollView(frame: UIScreen.main.bounds)
    let gr = UIScreenEdgePanGestureRecognizer()
    var appViewController: UIViewController? {
        didSet {
            appViewController.map(self.add)
        }
    }
    
    let previewView = UIView(frame: UIScreen.main.bounds)
    let debugView = UIView(frame: UIScreen.main.bounds)

    
    override func viewDidLayoutSubviews() {
        
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width*2, height: UIScreen.main.bounds.height)
        debugView.frame = UIScreen.main.bounds.offsetBy(dx: UIScreen.main.bounds.width, dy: 0)
        appViewController?.view.frame = UIScreen.main.bounds
        debugVC.view.frame = UIScreen.main.bounds
        appViewController?.view.map(previewView.addSubview)
        debugView.addSubview(debugVC.view)
        self.view.addSubview(scrollView)
        scrollView.addSubview(debugView)
        scrollView.addSubview(previewView)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scale = 1 - 0.6 * scrollView.contentOffset.x/UIScreen.main.bounds.width
        let newBounds = UIScreen.main.bounds.applying (CGAffineTransform(scaleX: scale, y: scale))
        //        appViewController?.view.layer.transform = CATransform3DMakeAffineTransform(CGAffineTransform(scaleX: scale, y: scale))
        previewView.transform = CGAffineTransform(scaleX: scale, y: scale)
        previewView.frame = newBounds.applying(CGAffineTransform(translationX:scrollView.contentOffset.x+(1-scale)*UIScreen.main.bounds.width/2, y: 50*scrollView.contentOffset.x/UIScreen.main.bounds.width))
        previewView.clipsToBounds = true
        debugView.frame = CGRect(x: UIScreen.main.bounds.width, y: (scrollView.contentOffset.x/UIScreen.main.bounds.width)*previewView.frame.maxY, width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height-(scrollView.contentOffset.x/UIScreen.main.bounds.width)*previewView.frame.maxY)
        debugView.clipsToBounds = true
        
    }
    
    var oldDelegate: UIGestureRecognizerDelegate?
    
    var gcs = [UIGestureRecognizer]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        view.addSubview(previewView)
        view.addSubview(scrollView)
        self.add(debugVC)
        gcs = scrollView.gestureRecognizers!
        scrollView.delegate = self
        self.view.addGestureRecognizer(scrollView.gr)
    }
    
    func update(model: Model) {
        debugVC.update(model: model)
    }
    
}


class Debug {
    static func start() {
        
        DispatchQueue.main.async {
            let vc = UIApplication.shared.keyWindow!.rootViewController!
            let debugVC = DebugViewContainer()
            UIApplication.shared.keyWindow?.rootViewController = debugVC
            debugVC.appViewController = vc
            let oldViewUpdate = Current.viewUpdate
            let newViewUpdate: ((Model) -> Void)  = { model in
                debugVC.update(model: model)
                oldViewUpdate?(model)
            }
            Current.viewUpdate = newViewUpdate
            
        }
    }
}
