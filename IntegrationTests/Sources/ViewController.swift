import UIKit

class ViewController: UIViewController {

    let viewModel = ViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.name = "Initial Name"
        viewModel.foo(input: 1)
    }
}
