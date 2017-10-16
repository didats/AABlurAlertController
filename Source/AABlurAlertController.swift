//
//  AABlurAlertController.swift
//  AABlurAlertController
//
//  Created by Anas Ait Ali on 17/01/2017.
//
//

import UIKit

public enum AABlurActionStyle {
    case `default`, cancel, modern, modernCancel
}

public enum AABlurTopImageStyle {
    case `default`, fullWidth
}

public enum AABlurAlertStyle {
    case `default`, modern
}

open class AABlurAlertAction: UIButton {
    public var buttonColor : UIColor?
    public var buttonBackgroundColor: UIColor?
    public var buttonFont : UIFont?
    
    fileprivate var handler: ((AABlurAlertAction) -> Void)? = nil
    fileprivate var style: AABlurActionStyle = AABlurActionStyle.default
    fileprivate var parent: AABlurAlertController? = nil

    public init(title: String?, style: AABlurActionStyle, handler: ((AABlurAlertAction) -> Void)?) {
        super.init(frame: CGRect.zero)

        self.style = style
        self.handler = handler

        self.addTarget(self, action: #selector(buttonTapped), for: UIControlEvents.touchUpInside)
        self.setTitle(title, for: UIControlState.normal)

        switch self.style {
        case .cancel:
            self.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            self.backgroundColor = UIColor.white
            self.layer.borderColor = UIColor.lightGray.cgColor
            self.layer.borderWidth = 1
            self.layer.cornerRadius = 8
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowRadius = 5
            self.layer.shadowOpacity = 0.1
        case .modernCancel:
            self.setTitleColor(UIColor(red:0.47, green:0.50, blue:0.56, alpha:1.00), for: UIControlState.normal)
            self.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            self.layer.cornerRadius = 8
        case .modern:
            self.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.backgroundColor = UIColor(red:0.28, green:0.56, blue:0.90, alpha:1.00)
            self.layer.cornerRadius = 8
        default:
            self.setTitleColor(UIColor.white, for: UIControlState.normal)
            self.backgroundColor = UIColor(red:2/255, green:85/255, blue:96/255, alpha:1.00)
            self.layer.borderWidth = 0.0
            self.layer.cornerRadius = 8
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
            self.layer.shadowRadius = 4
            self.layer.shadowOpacity = 0.1
        }
        
        // if font, color, and background is not nil
        if buttonFont != nil {
            self.titleLabel?.font = buttonFont!
        }
        
        
//        if buttonBackgroundColor != nil {
//            print("Goes here === 123")
//
//        }
//        else {
//            print("Goes here === 345")
//        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    @objc fileprivate func buttonTapped(_ sender: AABlurAlertAction) {
        self.parent?.dismiss(animated: true, completion: {
            self.handler?(sender)
        })
    }
}

open class AABlurAlertController: UIViewController {

    open var alertStyle: AABlurAlertStyle = AABlurAlertStyle.default
    open var blurEffectStyle: UIBlurEffectStyle = .light
    open var imageHeight: Float = 175
    open var topImageStyle: AABlurTopImageStyle = AABlurTopImageStyle.default
    open var alertViewWidth: Float?
    open var bgImage : UIImage?
    
    
//
    /**
     Set the max alert view width
     If you don't want to have a max width set this to nil.
     It will take 70% of the superview width by default
     Default : 450
     */
    open var maxAlertViewWidth: CGFloat? = 450

    public var spacing: Int = 16
    public var margin: Int = 32
    private var titleSubtitleSpacing: Int = 16
    public var bottomSpacing: Int = 32
    public var buttonWidth: CGFloat = 250
    public var buttonHeight: CGFloat = 52
    public var imageTopMargin: CGFloat = 20
    
    public var additionalView : UIView?
    
    open var buttonColor: UIColor?
    open var buttonBackgroundColor: UIColor = UIColor(red:2/255, green:85/255, blue:96/255, alpha:1.00)
    open var font: UIFont?

    fileprivate var backgroundImage : UIImageView = UIImageView()
    fileprivate(set) public var alertView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red:0.98, green:0.98, blue:0.98, alpha:1.00)
        return view
    }()
    open var alertImage : UIImageView = {
        let imgView = UIImageView()
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.contentMode = .scaleAspectFit
        return imgView
    }()
    open let alertTitle : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 17)
        lbl.textColor = UIColor(red:0.20, green:0.22, blue:0.26, alpha:1.00)
        lbl.textAlignment = .center
        return lbl
    }()
    open let alertSubtitle : UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.font = UIFont.boldSystemFont(ofSize: 14)
        lbl.textColor = UIColor(red:0.51, green:0.54, blue:0.58, alpha:1.00)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        return lbl
    }()

    fileprivate(set) public var buttonsStackView : UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.distribution = .fillEqually
        sv.spacing = 10
        return sv
    }()

    public init() {
        super.init(nibName: nil, bundle: nil)
        self.modalTransitionStyle = .crossDissolve
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setup() {
        // Clean the views
        self.view.subviews.forEach{ $0.removeFromSuperview() }
        self.backgroundImage.subviews.forEach{ $0.removeFromSuperview() }
        // Set up view
        self.view.frame = UIScreen.main.bounds
        self.view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.backgroundColor = UIColor.blue.withAlphaComponent(0.5)
        // Set up background image
        self.backgroundImage.frame = self.view.bounds
        self.backgroundImage.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(backgroundImage)
        // Set up the alert view
        self.alertView.clipsToBounds = true
        switch self.alertStyle {
        case .modern:
            self.alertView.layer.cornerRadius = 13
            self.titleSubtitleSpacing = 32
            self.bottomSpacing = 24
        default:
            self.alertView.layer.cornerRadius = 5
            self.alertView.layer.shadowColor = UIColor.black.cgColor
            self.alertView.layer.shadowOffset = CGSize(width: 0, height: 15)
            self.alertView.layer.shadowRadius = 12
            self.alertView.layer.shadowOpacity = 0.22
        }
        self.view.addSubview(alertView)
        // Set up alertImage
        self.alertView.addSubview(alertImage)
        // Set up alertTitle
        self.alertView.addSubview(alertTitle)
        // Set up alertSubtitle
        self.alertView.addSubview(alertSubtitle)
        // Set up buttonsStackView
        self.alertView.addSubview(buttonsStackView)
        
        if additionalView != nil {
            additionalView!.autoresizesSubviews = true
            self.alertView.addSubview(additionalView!)
        }
        // font
        if font != nil {
            self.alertTitle.font = font!
            self.alertSubtitle.font = UIFont(name: font!.fontName, size: font!.pointSize - 4)
        }
        
        self.alertTitle.textColor = self.buttonBackgroundColor

        // Set up background Tap
        if buttonsStackView.arrangedSubviews.count <= 0 {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapOnBackground))
            self.backgroundImage.isUserInteractionEnabled = true
            self.backgroundImage.addGestureRecognizer(tapGesture)
        }
        
        self.backgroundImage.image = bgImage

        setupConstraints()
    }

    fileprivate func setupConstraints() {
        
        alertView.translatesAutoresizingMaskIntoConstraints = false
        //alertImage.translatesAutoresizingMaskIntoConstraints = false
        alertTitle.translatesAutoresizingMaskIntoConstraints = false
        alertSubtitle.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        additionalView?.translatesAutoresizingMaskIntoConstraints = false
        
        alertView.backgroundColor = UIColor.white
        alertView.layer.borderWidth = 0
        alertView.layer.cornerRadius = 14.0
        
        var viewConstraints : [NSLayoutConstraint] = [
            alertView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 25),
            alertView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -25),
            alertView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            
            alertTitle.topAnchor.constraint(equalTo: alertView.topAnchor, constant: 15),
            alertTitle.leadingAnchor.constraint(equalTo: alertView.leadingAnchor, constant: 20),
            alertTitle.trailingAnchor.constraint(equalTo: alertView.trailingAnchor, constant: -20),
            alertTitle.bottomAnchor.constraint(equalTo: alertSubtitle.topAnchor, constant: -10),
            
            alertSubtitle.leadingAnchor.constraint(equalTo: alertTitle.leadingAnchor),
            alertSubtitle.trailingAnchor.constraint(equalTo: alertTitle.trailingAnchor)
        ]
        
        if additionalView == nil {
            viewConstraints.append(contentsOf: [
                alertSubtitle.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -25),
            ])
        }
        else {
            viewConstraints.append(contentsOf: [
                alertSubtitle.bottomAnchor.constraint(equalTo: additionalView!.topAnchor, constant: -15),
                additionalView!.heightAnchor.constraint(equalToConstant: 30),
                additionalView!.leadingAnchor.constraint(equalTo: alertTitle.leadingAnchor),
                additionalView!.trailingAnchor.constraint(equalTo: alertTitle.trailingAnchor),
                additionalView!.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor, constant: -25),
            ])
        }
        
        viewConstraints.append(contentsOf: [
            buttonsStackView.leadingAnchor.constraint(equalTo: alertTitle.leadingAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: alertTitle.trailingAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: alertView.bottomAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 45)
        ])

        NSLayoutConstraint.activate(viewConstraints)
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setup()
        self.view.backgroundColor = UIColor.black
        
        // Set up blur effect
        backgroundImage.image = snapshot()
        backgroundImage.alpha = 0.8
        let blurEffect = UIBlurEffect(style: blurEffectStyle)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = backgroundImage.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyEffectView.frame = backgroundImage.bounds
        vibrancyEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        blurEffectView.contentView.addSubview(vibrancyEffectView)
        backgroundImage.addSubview(blurEffectView)
    }

    open func addAction(action: AABlurAlertAction) {
        action.parent = self
        action.buttonColor = self.buttonColor
        action.buttonBackgroundColor = self.buttonBackgroundColor
        action.buttonFont = self.font
        
        action.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(action)
        //NSLayoutConstraint.activate([action.widthAnchor.constraint(equalToConstant: buttonWidth)])
    }

    fileprivate func snapshot() -> UIImage? {
        guard let window = UIApplication.shared.keyWindow else { return nil }
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, false, window.screen.scale)
        window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
        let snapshotImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return snapshotImage
    }

    func tapOnBackground(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
