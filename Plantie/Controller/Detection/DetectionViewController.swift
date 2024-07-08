import UIKit
import CoreData
import Vision
import CoreML

class DetectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var plantImageView: UIImageView!
    @IBOutlet weak var diseaseNameLabel: UILabel!
    @IBOutlet weak var treatmentNameLabel: UILabel!
    @IBOutlet weak var tipsLabel: UILabel!
    @IBOutlet weak var getPlantStoreButton: UIButton!
    @IBOutlet weak var plantImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var resultsStackLabelsConstraint: NSLayoutConstraint!
    @IBOutlet weak var tipsStackTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var historyTableView: UITableView!
    
    // MARK: - Variables
    var imageClassifier: ImageClassifier = MLImageClassifier(model: try! VNCoreMLModel(for: PlantieML().model))
    var selectedImage: UIImage? {
        didSet {
            if let image = selectedImage {
                classifyImage(image: image)
            }
        }
    }
    var diseasesInfo: [DiseaseInfo] = []
    let backButton = UIBarButtonItem()
    
    let lightGreen = UIColor(red: 0.88, green: 1.0, blue: 0.88, alpha: 1.0) // Light green
    let darkGreen = UIColor(red: 0.76, green: 0.88, blue: 0.76, alpha: 1.0) // Dark green
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        setupTableView()
        retrieveDataFromCoreData()
    }
    
    // MARK: - Actions
    @IBAction func getPlantStoreButtonTapped(_ sender: UIButton) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // MARK: - Image Classification
    private func classifyImage(image: UIImage) {
        imageClassifier.classify(image: image) { [weak self] identifier in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.updateUIForClassification()
                self.updateDetectionUI(disease: identifier ?? "unknown")
            }
        }
    }
    
  

    private func updateDetectionUI(disease: String) {
        self.plantImageView.image = self.selectedImage

        if let info = DiseaseInfo.data[disease] {
            diseaseNameLabel.text = info.name
            treatmentNameLabel.text = info.treatment.isEmpty ? "لا تحتاج الى مبيدات" : info.treatment
            tipsLabel.text = "الوصف: " + info.tips
        } else {
            diseaseNameLabel.text = "غير معروف"
            treatmentNameLabel.text = "غير معروف"
            tipsLabel.text = "الوصف: غير معروف"
        }
        
        let imageData = selectedImage?.jpegData(compressionQuality: 1.0)
        let disease = DiseaseInfo(arabicName: diseaseNameLabel.text ?? "", treatment: treatmentNameLabel.text ?? "", tips: tipsLabel.text ?? "", imageData: imageData)
        addDiseaseInfoToArray(disease: disease)
    }
    
}

// MARK: - UI Setup
private extension DetectionViewController {
    func setupViews() {
        getPlantStoreButton.layer.cornerRadius = 17
    }
    
    func setupNavigationBar() {
        backButton.title = "رجوع"
        backButton.tintColor = .plantieGreen
        navigationItem.backBarButtonItem = backButton
    }
    
    private func updateUIForClassification() {
        self.tipsLabel.isHidden = false
        self.plantImageViewHeightConstraint.constant = 250
        self.resultsStackLabelsConstraint.constant = 110
        self.tipsStackTopConstraint.constant = 10
    }
}

// MARK: - Core Data Operations
extension DetectionViewController {
    func addDiseaseInfoToArray(disease: DiseaseInfo) {
        diseasesInfo.append(disease)
        historyTableView.reloadData()
        saveToCoreData(disease: disease)
    }
    
    func saveToCoreData(disease: DiseaseInfo) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        guard let diseaseInfoEntity = NSEntityDescription.entity(forEntityName: "DiseasesInfo", in: managedContext) else { return }
        
        let diseaseInfo = NSManagedObject(entity: diseaseInfoEntity, insertInto: managedContext)
        diseaseInfo.setValue(disease.arabicName, forKey: "arabicName")
        diseaseInfo.setValue(disease.treatment, forKey: "treatment")
        diseaseInfo.setValue(disease.tips, forKey: "tips")
        diseaseInfo.setValue(disease.imageData, forKey: "imageData")
        
        do {
            try managedContext.save()
            debugPrint("Data saved")
        } catch let error as NSError {
            debugPrint("Failed to save data: \(error), \(error.userInfo)")
        }
    }
    
    func retrieveDataFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiseasesInfo")
        
        do {
            guard let result = try managedContext.fetch(fetchRequest) as? [NSManagedObject] else { return }
            for data in result {
                let diseaseName = data.value(forKey: "arabicName") as! String
                let treatment = data.value(forKey: "treatment") as! String
                let tips = data.value(forKey: "tips") as! String
                let imageData = data.value(forKey: "imageData") as? Data
                let disease = DiseaseInfo(arabicName: diseaseName, treatment: treatment, tips: tips, imageData: imageData)
                diseasesInfo.append(disease)
            }
        } catch let error as NSError {
            debugPrint("Failed to fetch data: \(error), \(error.userInfo)")
        }
    }
    
    func deleteFromCoreData(disease: DiseaseInfo) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "DiseasesInfo")
        fetchRequest.predicate = NSPredicate(format: "arabicName == %@ AND treatment == %@", disease.arabicName, disease.treatment)
        
        do {
            let fetchResults = try managedContext.fetch(fetchRequest)
            for result in fetchResults {
                guard let objectToDelete = result as? NSManagedObject else { continue }
                managedContext.delete(objectToDelete)
            }
            try managedContext.save()
            debugPrint("Data deleted from Core Data")
        } catch let error as NSError {
            debugPrint("Failed to delete data from Core Data: \(error), \(error.userInfo)")
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension DetectionViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        historyTableView.delegate = self
        historyTableView.dataSource = self
        historyTableView.rowHeight = UITableView.automaticDimension
        historyTableView.estimatedRowHeight = 100
        historyTableView.register(UINib(nibName: "PlantTableViewCell", bundle: nil), forCellReuseIdentifier: "PlantTableViewCell")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return diseasesInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlantTableViewCell", for: indexPath) as! PlantTableViewCell
        let disease = diseasesInfo[indexPath.row]
        cell.plantNameLabel.text = disease.arabicName
        if let imageData = disease.imageData {
            cell.plantImageView.image = UIImage(data: imageData)
        }
        
        cell.backgroundColor = indexPath.row % 2 == 0 ? lightGreen : darkGreen
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.historyTableView.deselectRow(at: indexPath, animated: true)
        self.updateUIForClassification()
        let diseaseInfo = diseasesInfo[indexPath.row]
        self.plantImageView.image = UIImage(data: diseaseInfo.imageData!)
        self.treatmentNameLabel.text = diseaseInfo.treatment
        self.diseaseNameLabel.text = diseaseInfo.arabicName
        self.tipsLabel.text = diseaseInfo.tips
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true // Enable swipe to delete
    }
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "حذف" // Customize delete button text
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDisease(at: indexPath)
        }
    }
    
    private func deleteDisease(at indexPath: IndexPath) {
        let diseaseToRemove = diseasesInfo[indexPath.row]
        diseasesInfo.remove(at: indexPath.row)
        historyTableView.deleteRows(at: [indexPath], with: .fade)
        deleteFromCoreData(disease: diseaseToRemove)
    }
}
