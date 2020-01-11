//
//  ChilViewController.swift
//  Child View
//
//  Created by KASRA BABAEI on 11/01/2020.
//  Copyright © 2020 KASRA BABAEI. All rights reserved.
//

import UIKit

class ChildViewController: UIViewController {
    lazy private var backgroundImageView: UIImageView = {
        let image = UIImage(named: "toronto")
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        return view
    }()
    
    private let handleViewHeight: CGFloat = 50
    //MARK:- View life cycle
    override func viewDidLoad() {
        view.backgroundColor = .yellow
        configConstraints()
    }
    
    //MARK:- Config constraints
    private func configConstraints() {
        view.addSubview(backgroundImageView)
        view.addSubview(handleView)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        handleView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        handleView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        handleView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        handleView.heightAnchor.constraint(equalToConstant: handleViewHeight).isActive = true
    }
}
