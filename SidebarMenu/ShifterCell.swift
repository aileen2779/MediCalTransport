//
//  PokeCell.swift


import UIKit

class PokeCell: UICollectionViewCell {
    
    @IBOutlet weak var thumbImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    
    var shifter: ShifterClass!
    
    required init?(coder aDecoder: NSCoder){
        super.init(coder: aDecoder)
        
        layer.cornerRadius = 7.0
    }
    
    
    func configureCell(_ shifter: ShifterClass) {
        
        self.shifter = shifter
        
        nameLbl.text = shifter.name.capitalized
        thumbImg.image = UIImage(named: "\(shifter.userId)")
      
        // Change the color of the background label is member has not paid yet
        if (shifter.membership == "None" ) {
            nameLbl.backgroundColor = UIColor(red:0.50, green:0.50, blue:0.50, alpha:1.0)
        } else {
            nameLbl.backgroundColor  = UIColor(red:0.56, green:0.00, blue:0.13, alpha:1.0)
      }
  }
  
  
    
}
