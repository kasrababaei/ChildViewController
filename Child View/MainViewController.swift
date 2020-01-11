//
//  ViewController.swift
//  Child View
//
//  Created by KASRA BABAEI on 11/01/2020.
//  Copyright © 2020 KASRA BABAEI. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    lazy private var backgroundImageView: UIImageView = {
        let image = UIImage(named: "vancouver")
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy private var childViewController: ChildViewController = {
        let viewController = ChildViewController()
        viewController.view.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.clipsToBounds = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(childViewTapped(_:)))
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(childViewPanned(_:)))
        viewController.handleView.addGestureRecognizer(tapGesture)
        viewController.handleView.addGestureRecognizer(panGesture)
        return viewController
    }()
    
    lazy private var visualEffect: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let childHeight: CGFloat = UIScreen.main.bounds.height * 0.9
    private let childHandleAreaHeight: CGFloat = 60+20
    
    enum ChildState {
        case expanded
        case collapsed
    }
    
    private var childVisible = false
    private var nextState: ChildState {
        return childVisible ? .collapsed : . expanded
    }
        
    private var runningAnimations = [UIViewPropertyAnimator]()
    private var animationProgressWhenInterrupted: CGFloat = 0
    private var childViewControllerHeightAnchor: NSLayoutConstraint? = nil
    
    //MARK:- View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .yellow
        configConstratins()
        setupChild()
        
    }

    private func animateTransitionIfNeeded(_ state: ChildState, duration time: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: time, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.childViewControllerHeightAnchor?.constant = self.childHeight
                    self.view.layoutIfNeeded()
                case .collapsed:
                    self.childViewControllerHeightAnchor?.constant = self.childHandleAreaHeight
                    self.view.layoutIfNeeded()
                }
            }
            
            frameAnimator.addCompletion { (_) in
                self.childVisible = !self.childVisible
                self.runningAnimations.removeAll()
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: time, curve: .linear) {
                let path = UIBezierPath(roundedRect: self.childViewController.view.bounds, byRoundingCorners: [.topLeft, .topRight], cornerRadii: CGSize(width: 15, height: 15))
                let mask = CAShapeLayer()
                mask.path = path.cgPath
                
                switch state {
                case .expanded:
                    self.childViewController.view.layer.mask = mask
                case .collapsed:
                    self.childViewController.view.layer.mask = nil
                }
            }
            
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: time, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffect.effect = UIBlurEffect(style: .dark)
                case .collapsed:
                    self.visualEffect.effect = nil
                }
            }
            
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
        }
    }
    
    private func startInteractiveTransition(_ state: ChildState, duration time: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state, duration: time)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    private func updateInteractiveTransition(fraction complete: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = complete + animationProgressWhenInterrupted
        }
    }
    
    private func continueInteractiveTransition() {
        for animator in runningAnimations {
            // durationFactor = 0 : use whatever duration is left to finish the animation
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    //MARK:- IBActions
    
    @objc private func childViewTapped(_ sender: UITapGestureRecognizer) {
        switch sender.state {
        case .ended:
            animateTransitionIfNeeded(nextState, duration: 0.9)
        default:
            break
        }
    }
    
    @objc private func childViewPanned(_ sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .began:
            startInteractiveTransition(nextState, duration: 0.9)
        case .changed:
            // Smoothly move the child up/down
            let translation = sender.translation(in: self.childViewController.handleView)
            var fractionComplete = translation.y / childHeight
            fractionComplete = childVisible ? fractionComplete : -fractionComplete
            updateInteractiveTransition(fraction: fractionComplete)
        case .ended:
            continueInteractiveTransition()
        default:
            break
        }
    }
    
    //MARK:- Config constraints
    private func setupChild() {
        view.addSubview(visualEffect)
        visualEffect.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        visualEffect.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        visualEffect.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        visualEffect.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.addChild(childViewController)
        self.view.addSubview(childViewController.view)
        
        childViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        childViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        childViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        self.childViewControllerHeightAnchor = childViewController.view.heightAnchor.constraint(equalToConstant: childHandleAreaHeight)
        childViewControllerHeightAnchor?.isActive = true
    }
    
    private func configConstratins() {
        view.addSubview(backgroundImageView)
        
        backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
}

