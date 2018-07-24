//
//  ShowDetailsViewController.swift
//  TVShows
//
//  Created by Infinum Student Academy on 23/07/2018.
//  Copyright © 2018 Ivan Milicevic. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire
import CodableAlamofire

class ShowDetailsViewController: UIViewController {
    
    // MARK: - IBOutlets
   
    @IBOutlet weak var showDetailsTableView: UITableView! {
        didSet {
            showDetailsTableView.dataSource=self
            showDetailsTableView.delegate=self
            showDetailsTableView.estimatedRowHeight=100
            showDetailsTableView.rowHeight=UITableViewAutomaticDimension
            showDetailsTableView.separatorStyle = .none
        }
    }
    
    // MARK: - Public
    var loginData: LoginData?
    var showID: String?
    
    // MARK: - Private
    private var showDetails: ShowDetails?
    private var episodesArray: [ShowEpisode]?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        fetchShowDetails()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)

        customizeBackButton()
        floatingButton()
        
    }
    
    // MARK: - Private Functions
    private func fetchShowDetails() {
        guard
            let token=loginData?.token
            else {
                return
        }
        let headers = ["Authorization": token]
        
        SVProgressHUD.show()
        
        Alamofire
            .request("https://api.infinum.academy/api/shows/\(showID!)",
                     method: .get,
                     encoding: JSONEncoding.default,
                     headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) {
                (response: DataResponse<ShowDetails>) in
                switch response.result {
                case .success(let details):
                    self.showDetails=details
                    print("Show Details fetched: \(details)")
                    self.fetchShowEpisodes()
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print("Fetching show details went wrong: \(error)")
                    let alertController = UIAlertController(title: "Error",
                                                            message: error.localizedDescription,
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel){
                        (action:UIAlertAction) in
                        self.returnToHomeScreen()
                    })
                    self.present(alertController, animated: true, completion: nil)
                    
                }
        }
    }
    private func fetchShowEpisodes() {
        guard
            let token=loginData?.token
            else {
                return
        }
        let headers = ["Authorization": token]
        
        Alamofire
            .request("https://api.infinum.academy/api/shows/\(showID!)/episodes",
                method: .get,
                encoding: JSONEncoding.default,
                headers: headers)
            .validate()
            .responseDecodableObject(keyPath: "data", decoder: JSONDecoder()) {
                (response: DataResponse<[ShowEpisode]>) in
                switch response.result {
                case .success(let episodes):
                    self.episodesArray=episodes
                    print("Show episodes fetched: \(episodes)")
                    SVProgressHUD.dismiss()
                    self.showDetailsTableView.reloadData()
                case .failure(let error):
                    SVProgressHUD.dismiss()
                    print("Fetching episodes went wrong: \(error)")
                    let alertController = UIAlertController(title: "Error",
                                                            message: error.localizedDescription,
                                                            preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel){
                        (action:UIAlertAction) in
                        self.returnToHomeScreen()
                    })
                    self.present(alertController, animated: true, completion: nil)
                    
                }
        }
        
    }
    private func customizeBackButton() {
        
        let btn = UIButton(type: .custom)
        let btnImg = UIImage(named: "ic-navigate-back")
        btn.frame = CGRect(x: 0, y: 5, width: 70, height: 70)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 35
        btn.setImage(btnImg, for: .normal)
        btn.addTarget(self,action: #selector(ShowDetailsViewController.returnToHomeScreen), for: UIControlEvents.touchUpInside)
        view.addSubview(btn)
        
    }
    
    @objc private func returnToHomeScreen(){
        navigationController?.popViewController(animated: true)
    }
    
    func floatingButton(){
        
        let btn = UIButton(type: .custom)
        let btnImg = UIImage(named: "ic-fab-button")
        btn.frame = CGRect(x: self.view!.bounds.width - 80, y: self.view!.bounds.height - 80, width: 70, height: 70)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 35
        btn.setImage(btnImg, for: .normal)
        btn.addTarget(self,action: #selector(ShowDetailsViewController.buttonTapped), for: UIControlEvents.touchUpInside)
        view.addSubview(btn)
    }
    
    @objc func buttonTapped(){
        navigationController?.popViewController(animated: true)
    }
    

}

extension ShowDetailsViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let numberOfRows = episodesArray?.count else {
            return 2
        }
        return 2 + numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = showDetailsTableView.dequeueReusableCell(
                withIdentifier: "TVShowsImageCell",
                for: indexPath
            ) as! TVShowsImageCell
//            cell.configure(with: <#T##UIImage#>)
            return cell
        case 1:
            let cell = showDetailsTableView.dequeueReusableCell(
                withIdentifier: "TVShowsDescriptionCell",
                for: indexPath
            ) as! TVShowsDescriptionCell
            
            if showDetails != nil {
                cell.configure(with: showDetails!, count: episodesArray != nil ? episodesArray!.count : 0)
            } else {
                //do nothing
            }
            
            return cell
        default:
            let cell = showDetailsTableView.dequeueReusableCell(
                withIdentifier: "TVShowsEpisodeCell",
                for: indexPath
            ) as! TVShowsEpisodeCell
            cell.configure(with: episodesArray![indexPath.row-2])
            return cell
        }

    }
    
}

extension ShowDetailsViewController: UITableViewDelegate {
    
}
