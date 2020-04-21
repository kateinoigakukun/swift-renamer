# swift-renamer

SwiftRenamer is a tool that renames Swift identifiers


If you want to rename `name` to `nickname`,
```swift
class User {
    var name: String?
}

class ViewController: UIViewController {

    let user = User()
    override func viewDidLoad() {
        super.viewDidLoad()

        user.name = "Initial Name"
    }
}
```

You can use this library like below:

```swift
import SwiftRenamer

let renamer = SwiftRenamer(storePath: indexStorePath)
let replacements = try renamer.replacements(for: "s:16IntegrationTests9ViewModelC4nameSSSgvp", newSymbol: "nickname")

for (filePath, replacements) in replacements {
    let rewriter = try SourceRewriter(content: String(contentsOfFile: filePath))
    replacements.forEach(rewriter.replace)
    let newContent = rewriter.apply()
    newContent.write(toFile: filePath, atomically: true, encoding: .utf8)
}
```

Then, the file will be rewritten as:

```diff
 class User {
-    var name: String?
+    var nickname: String?
 }

 class ViewController: UIViewController {

    let user = User()
    override func viewDidLoad() {
        super.viewDidLoad()

-        user.name = "Initial Name"
+        user.nickname = "Initial Name"
    }
}
```
