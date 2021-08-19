
import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var ivLogo: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        view.backgroundColor = UIColor.init(displayP3Red: 99/255, green: 197/255, blue: 148/255, alpha: 1)

        let sqlite = SQLite()
        sqlite.createTable()
        
        let time = DispatchTime.now() + .seconds(1)

        ivLogo.alpha = 0
        
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseOut, animations: {
            self.ivLogo.alpha = 1.0
        })
        DispatchQueue.main.asyncAfter(deadline: time, execute: self.moveToMain)
    }
    
    func moveToMain(){
      let mainVC = self.storyboard?.instantiateViewController(withIdentifier: "main")
        mainVC?.modalPresentationStyle = .fullScreen
        self.present(mainVC!, animated: true, completion: nil)
        self.navigationController?.popViewController(animated: false)
    }
}

extension InitialViewController: ManageDBErrorProtocol{
    func manageDBError() {
        let alert = UIAlertController(title: "Error", message: "데이터베이스 에러, 앱을 재실행해 주세요.", preferredStyle: .alert)
        let actionDefault = UIAlertAction(title: "확인", style: .default, handler: {
            ACTION in
            exit(0)
        })
        alert.addAction(actionDefault)
        self.present(alert, animated: true, completion: nil)
    }
}
