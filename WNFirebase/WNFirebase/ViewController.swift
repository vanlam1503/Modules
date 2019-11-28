//
//  ViewController.swift
//  WNFirebase
//
//  Created by Lam Le V. on 11/28/19.
//  Copyright © 2019 Lam Le V. All rights reserved.
//

import UIKit

//https://firebase.google.com/docs/ios/setup
final class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    enum Row: String, CaseIterable {
        case signIn
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configView()
    }

    private func configView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    private func moveToSignInVC() {
        let vc = SignInVC()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = Row.allCases[indexPath.row]
        switch row {
        case .signIn:
            moveToSignInVC()
        }
    }
}

extension ViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Row.allCases.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let row = Row.allCases[indexPath.row]
        cell.textLabel?.text = "\(row.rawValue)"
        return cell
    }
}
