import UIKit

class CalendarViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activityIndicator.hidesWhenStopped = true
        self.webView.loadHTMLString("<iframe src=\"https://calendar.google.com/calendar/embed?src=1hqrjeptpdfs33q37qa7osa0ak%40group.calendar.google.com&ctz=America/Los_Angeles\" style=\"border: 0\" width=\"800\" height=\"600\" frameborder=\"0\" scrolling=\"no\"></iframe>", baseURL: nil)
    }
    
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        activityIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView){
        activityIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        activityIndicator.stopAnimating()
    }
}

