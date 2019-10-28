//
//  Store.swift
//  CatchIT
//
//  Created by Jaafar Rammal on 10/26/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

//
//  ViewController.swift


import UIKit

struct CustomData {
    var title: String
    var backgroundImage: UIImage
    var points: Int
    var description: String
}

class Store: UIViewController {
    
     fileprivate let data = [
           CustomData(title: "Vue Cinema", backgroundImage: #imageLiteral(resourceName: "vue"), points: 30, description: "Free popcorn"),
           CustomData(title: "Topshop", backgroundImage: #imageLiteral(resourceName: "topshop"), points: 40, description: "£10 voucher"),
           CustomData(title: "Cafe Nero",backgroundImage: #imageLiteral(resourceName: "nero"), points: 100, description: "Free coffee"),
           CustomData(title: "Google UK", backgroundImage: #imageLiteral(resourceName: "google"), points: 20, description: "£5 voucher"),
           CustomData(title: "Everyman", backgroundImage: #imageLiteral(resourceName: "everyman"), points: 40, description: "Free popcorn"),
           CustomData(title: "Asos", backgroundImage: #imageLiteral(resourceName: "asos"), points: 50, description: "£10 voucher"),
           CustomData(title: "Domino's", backgroundImage: #imageLiteral(resourceName: "dominos"), points: 60, description: "2 for 1"),
           CustomData(title: "Costa",backgroundImage: #imageLiteral(resourceName: "costa"), points: 70, description: "Half-off"),
           CustomData(title: "Nike Store", backgroundImage: #imageLiteral(resourceName: "nike"), points: 20, description: "£5 off")
       ]
    
    fileprivate let collectionView:UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(CustomCell.self, forCellWithReuseIdentifier: "cell")
        return cv
    }()

    let defaults = UserDefaults.standard
    var userScore: Int!
    var pointsToRemove = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userScore = Int(defaults.string(forKey: "UserScore")!)!
        
//        view.backgroundColor = hexStringToUIColor(hex:"42B45B")
        view.addSubview(collectionView)
        collectionView.backgroundColor = view.backgroundColor
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        collectionView.heightAnchor.constraint(equalToConstant: view.frame.height-170 ).isActive = true
    }
    
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
 
    @IBOutlet var VoucherPop: UIView!
    @IBAction func confirmVoucher(_ sender: Any) {
        // API post call
        userScore -= pointsToRemove
        defaults.set(userScore, forKey: "UserScore")
        VoucherPop.removeFromSuperview()
        dimView.removeFromSuperview()
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    @IBAction func cancelVoucher(_ sender: Any) {
        VoucherPop.removeFromSuperview()
        dimView.removeFromSuperview()
    }
    @IBOutlet weak var confirmAction: UIButton!
    
    @IBOutlet weak var catchMore: UIButton!
    @IBOutlet weak var cancelVoucher: UIButton!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var titleConfirm: UILabel!
    @IBOutlet weak var descriptionConfirm: UILabel!
    @IBOutlet var dimView: UIView!
    @IBOutlet var noEnoughView: UIView!
    @IBAction func hideNotEnough(_ sender: Any) {
        noEnoughView.removeFromSuperview()
        dimView.removeFromSuperview()
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refresh"), object:nil, userInfo: nil)
    }
}

extension Store: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width/2.08, height: collectionView.frame.width/1.3)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.data = self.data[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view.addSubview(dimView)
        dimView.center = self.view.center
        dimView.frame = CGRect(x: 0,y: 0, width: self.view.frame.width, height: self.view.frame.height)
        
        if(data[indexPath[1]].points <= userScore){
            self.view.addSubview(VoucherPop)
            VoucherPop.center = self.view.center
            VoucherPop.layer.cornerRadius = 20
            confirmAction.layer.cornerRadius = 30
            descriptionConfirm.text = data[indexPath[1]].description
            titleConfirm.text = data[indexPath[1]].title
            price.text = "\(data[indexPath[1]].points) points"
            pointsToRemove = data[indexPath[1]].points
        }else{
            self.view.addSubview(noEnoughView)
            noEnoughView.layer.cornerRadius = 20
            noEnoughView.center = self.view.center
            catchMore.layer.cornerRadius = 20
        }
    }
}


class CustomCell: UICollectionViewCell {
    
    var data: CustomData? {
        didSet {
            guard let data = data else { return }
            
            bg.image = data.backgroundImage
            
            shopName.text = data.title
            shopName.textColor = UIColor.white
            shopName.font = UIFont (name: "HelveticaNeue-Bold", size: 25)
            
            numPoints.text = String(format: "%i Points", data.points)
            numPoints.textColor = UIColor.white
            numPoints.font = UIFont (name: "HelveticaNeue-Bold", size: 20)
            
            offerDescription.text = data.description
            offerDescription.textColor = UIColor.white
            offerDescription.font = UIFont (name: "HelveticaNeue-Bold", size: 20)
           
        }
    }
    
    fileprivate let bg: UIImageView = {
       let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
                iv.layer.cornerRadius = 10
        return iv
    }()
    
    fileprivate let shopName: UILabel = {
        let lv = UILabel()
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.contentMode = .scaleAspectFill
        lv.clipsToBounds = true
        lv.layer.cornerRadius = 5
        return lv
    }()
    
    fileprivate let numPoints: UILabel = {
        let lv = UILabel()
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.contentMode = .scaleAspectFill
        lv.clipsToBounds = true
        lv.layer.cornerRadius = 5
        return lv
    }()
    
    fileprivate let offerDescription: UILabel = {
        let lv = UILabel()
        lv.translatesAutoresizingMaskIntoConstraints = false
        lv.contentMode = .scaleAspectFill
        lv.clipsToBounds = true
        lv.layer.cornerRadius = 5
        return lv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        
        contentView.addSubview(bg)
        contentView.addSubview(shopName)
        contentView.addSubview(numPoints)
        contentView.addSubview(offerDescription)

        bg.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        bg.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        bg.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -30).isActive = true
        
        
        shopName.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        shopName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        shopName.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        shopName.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -230).isActive = true
        
        numPoints.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 140).isActive = true
        numPoints.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        numPoints.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        numPoints.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        
        offerDescription.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 190).isActive = true
        offerDescription.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10).isActive = true
        offerDescription.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive = true
        offerDescription.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

