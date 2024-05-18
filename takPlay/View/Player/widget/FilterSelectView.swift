//
//  File.swift
//  takPlay
//
//  Created by 탁제원 on 4/29/24.
//

import UIKit

enum FilterType: Int {
    case standard
    case filter1
    case filter2
    case filter3
    case filter4
    case filter5
    
    var displayName: String {
        switch self {
        case .standard:
            return "원본"
        case .filter1:
            return "따뜻하게"
        case .filter2:
            return "선명하게"
        case .filter3:
            return "흑백"
        case .filter4:
            return "필름"
        case .filter5:
            return "차갑게"
        }
    }}

protocol FilterSelectDelegate {
    func didSelectFilter(by type: FilterType)
}

class FilterSelectView: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    @IBOutlet weak var filterNameLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var filterCellImage: UIImage?
    
    var delegate: FilterSelectDelegate?
    
    // MARK: - override
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.collectionView.backgroundColor = .black
        self.filterNameLabel.text = "gray"
        
        self.collectionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "FilterCollectionViewCell")
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let firstIndexPath = IndexPath(item: 0, section: 0)
        collectionView.selectItem(at: firstIndexPath, animated: false, scrollPosition: .centeredHorizontally)
        self.collectionView.reloadData()

    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    
    // cell size
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: 50)
    }
    
    // 그리드 줄 간격
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToCenterForItem(at: indexPath, animated: true)
        
        // 선택된 셀에 테두리를 추가합니다.
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 2.0
            cell.layer.borderColor = UIColor.white.cgColor
        }
        self.filterNameLabel.text = String(describing: FilterType(rawValue: indexPath.row)?.displayName ?? "unknown filter")
        
        self.delegate?.didSelectFilter(by: FilterType(rawValue: indexPath.row) ?? FilterType.standard)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        // 선택이 해제된 셀의 테두리를 제거합니다.
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderWidth = 0.0
        }
    }
    
    
    //MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell", for: indexPath) as? FilterCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        
        cell.filterImageView.contentMode = .scaleToFill
        
        switch indexPath.row {
        case 0:
            cell.filterImageView.image = filterCellImage
        case 1:
            cell.filterImageView.image = filterCellImage?.sepiaFilter(intensity: 0.2)
        case 2:
            cell.filterImageView.image = filterCellImage?.luminanceFilter(sharpness: 4.0)
        case 3:
            cell.filterImageView.image = filterCellImage?.noirFilter()
        case 4:
            cell.filterImageView.image = filterCellImage?.instantFilter()
        case 5:
            cell.filterImageView.image = filterCellImage?.coldFilter()
        default: break
        }
        
        return cell
    }
}
