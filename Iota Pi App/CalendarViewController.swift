import UIKit

class CalendarViewController: UIViewController {
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        self.webView.loadHTMLString("<iframe src=\"https://calendar.google.com/calendar/embed?src=1hqrjeptpdfs33q37qa7osa0ak%40group.calendar.google.com&ctz=America/Los_Angeles\" style=\"border: 0\" width=\"800\" height=\"600\" frameborder=\"0\" scrolling=\"no\"></iframe>", baseURL: nil)
    }
}

