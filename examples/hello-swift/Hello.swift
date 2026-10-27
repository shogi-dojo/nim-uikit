import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions options: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = HelloController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }
}

final class HelloController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        let title = UILabel(frame: CGRect(x: 16, y: 200, width: view.bounds.width - 32, height: 120))
        title.text = "Hello from Swift"
        title.textColor = .label
        title.font = .systemFont(ofSize: 28)
        title.numberOfLines = 0
        view.addSubview(title)
    }
}
