

import UIKit

class PlantDetailsViewController: UIViewController {

    // MARK: Variables
    
    var plant:Plant!
    
    // MARK: Outlets
    
    @IBOutlet weak var circlerView: UIView!
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var plantNameLabel: UILabel!
    @IBOutlet weak var plantCategoryLabel: UILabel!
    @IBOutlet weak var plantDescriptionLabel: UILabel!
    @IBOutlet weak var plantingTimeLabel: UILabel!
    @IBOutlet weak var fertilizerDescriptionLabel: UILabel!
    @IBOutlet weak var fertalizerButton: UIButton!
    @IBOutlet weak var plantStorageInfoLabel: UILabel!
    @IBOutlet weak var plantDiasesCollectionView: UICollectionView!
    
    
   // MARK: Life Cycle Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        configurePlantInformations(plant: plant)
        setupViews()
        setupCollectionView()
        
        
    }
    
    
    // MARK: Actions
    
    @IBAction func fertalizerButtonTapped(_ sender: UIButton) {
        
         let fertilizerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FertlizerCalculatorViewController") as? FertlizerCalculatorViewController

             fertilizerVC!.plant = self.plant!
        navigationController?.pushViewController(fertilizerVC!, animated: true)
         
    }
    

}

// MARK: Private Methods
extension PlantDetailsViewController{
    func setupNavigationBar(){
        //Show the Navigation Bar
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.tintColor = UIColor.plantieGreen
        
    }
    
    
    func configurePlantInformations(plant:Plant){
        self.plantImageView.image = UIImage(named: plant.imageName)
        self.plantNameLabel.text = plant.name
        self.plantCategoryLabel.text = plant.category
        self.plantDescriptionLabel.text = plant.description
        self.plantingTimeLabel.text = plant.plantingTime
        self.fertilizerDescriptionLabel.text = plant.fertilizer
        self.plantStorageInfoLabel.text = "\(plant.storageInfo.humidity) \n \(plant.storageInfo.temperature)"
    }
    
    func setupViews(){
        
        self.circlerView.layer.cornerRadius = self.circlerView.frame.width / 2
        
        self.circlerView.clipsToBounds = true
        self.circlerView.layer.shadowColor = UIColor.black.cgColor
        self.circlerView.layer.shadowOpacity = 1
        self.circlerView.layer.shadowOffset = CGSize.zero
        self.circlerView.layer.shadowRadius = 10
        self.circlerView.clipsToBounds = false

        
        self.fertalizerButton.layer.cornerRadius = 15
        
        
    }
    
    
    func setupCollectionView(){
        self.plantDiasesCollectionView.delegate = self
        self.plantDiasesCollectionView.dataSource = self
        let nib = UINib(nibName: "PlantCollectionViewCell", bundle: nil)
        plantDiasesCollectionView.register(nib, forCellWithReuseIdentifier: "plantCell")
    }
}


// MARK: Plant Disease Collection Protocols

extension PlantDetailsViewController: UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        plant.diseaseAndPestControl.commonDiseases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "plantCell", for: indexPath) as! PlantCollectionViewCell

        
        let data = plant.diseaseAndPestControl.commonDiseases[indexPath.row]
        
        cell.configureCell(imageName:plant.imageName  , diseaseName: data.name)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let plant = plant.diseaseAndPestControl.commonDiseases[indexPath.row]
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "DiseaseDetailsViewController") as DiseaseDetailsViewController
        vc.diseaseImageURL = plant.imageURL
        vc.diseaseName = plant.name
        vc.diseaseDescription = plant.description
        vc.diseasePrevention = plant.prevention
        
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 80, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        30
    }
}
