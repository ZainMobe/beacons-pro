//
//  ViewController.swift
//  Beacon Sample
//
//  Created by Zain Haider on 21/09/2021.
//  Copyright © 2021 Apple. All rights reserved.
//

import UIKit

class DashboardController: BaseViewController {

    @IBOutlet weak var tableView: UITableView!
    
    let dashboardViewModel = DashboardViewModel()
    var tableData = [DashboardModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setup()
    }
    
    private func setup() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "support"), style: .plain, target: self, action: #selector(supportTapped))
        title = "Dashboard"
        tableData = dashboardViewModel.getTableData()
        tableView.reloadData()
    }

    fileprivate func setupCell(_ cell: DashboardCell, model: DashboardModel) {
        cell.lblTitle.text = model.title
        cell.lblSubtitle.text = model.subtitle
        cell.imgCentre.image = model.image
        cell.infoButtonPressed = {[weak self] in
            DispatchQueue.main.async {
                self?.alert(message: model.details)
            }
        }
    }
    
    private func showUUIDAlert() {
        let controller = self.getController(identifier: .EnterUUIDController) as! EnterUUIDController
        controller.uuidAdded = {[weak self] uuid in
            DispatchQueue.main.async {
                let controller = self?.getController(identifier: .ConfigureBeaconViewController) as! ConfigureBeaconViewController
                controller.beaconUUID = uuid
                self?.navigationController?.pushViewController(controller, animated: true)
            }
        }
        self.present(controller, animated: true)
    }
    
    @objc private func supportTapped() {
        let vc = self.getController(identifier: .SupportController)
        self.present(vc, animated: true)
    }
    
}


//MARK:- UITableViewDelegate
extension DashboardController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        (self.view.frame.height / 2) - 40
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cell_identifiers.DashboardCell, for: indexPath) as! DashboardCell
        let model = tableData[indexPath.row]
        setupCell(cell, model: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let data = self.tableData[indexPath.row]
        switch data.configuration {
        case .act_as_beacon:
            DispatchQueue.main.async {
                self.showUUIDAlert()
            }
        case .look_for_beacon:
            DispatchQueue.main.async {
                self.push(identifier: .RangeBeaconViewController)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
