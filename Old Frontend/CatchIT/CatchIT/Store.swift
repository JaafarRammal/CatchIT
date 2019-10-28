//
//  Store.swift
//  CatchIT
//
//  Created by Jaafar Rammal on 10/26/19.
//  Copyright © 2019 Jaafar Rammal. All rights reserved.
//

import UIKit

class StoreView: UIViewController{
    
}


extension StoreView: UITableViewDelegate, UITableViewDataSource
{
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title:String = ""
        
        if (section == 0)
        {
            title = "Food"
        } else if (section == 1)
        {
            title = "Entertainment"
        } else if (section == 2)
        {
            title = "Others"
        }
        
        return title
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 230
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! itemCellDesign
        
        cell.tickOutlet.isHidden = true
        
        
        // Fill up each cell
        
        if(indexPath.section == 0)
        {
            cell.itemNameLbl?.text = awelMat3am["soups"]![indexPath.row][0]
            cell.itemPriceLbl?.text = awelMat3am["soups"]![indexPath.row][1]
            
        }
        
        if(indexPath.section == 1)
        {
            cell.itemNameLbl?.text = awelMat3am["appetizers"]![indexPath.row][0]
            cell.itemPriceLbl?.text = awelMat3am["appetizers"]![indexPath.row][1]
        }
        
        if(indexPath.section == 2)
        {
            cell.itemNameLbl?.text = awelMat3am["mains"]![indexPath.row][0]
            cell.itemPriceLbl?.text = awelMat3am["mains"]![indexPath.row][1]
        }
        
        
        
        if cell.isSelected
        {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            print("cellForRowAt 1")
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryType.none
            print("cellForRowAt 2")
        }
        
        
        return cell
        
    }
    
    
}//extension for table
