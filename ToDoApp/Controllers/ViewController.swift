//
//  ViewController.swift
//  ToDoApp
//
//  Created by Muhammed Mustafa Savar on 7.04.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var data = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        fetch()
    }
    
    @IBAction func didAddBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentAddAlert()
    }
    
    @IBAction func didRemoveAllBarButtonItemTapped(_ sender: UIBarButtonItem){
        presentRemoveAllAlert()
    }
    
    func presentRemoveAllAlert(){
        let alertController = createBasicAlertController(title: "Onayla",
                                                         message: "Her şeyi silmek istediğine emin misin?",
                                                         cancelButtonTitle: "Vazgeç")
        let removeAllButon = UIAlertAction(title: "Sil",
                                           style: .default,
                                           handler: ({ _ in
            if self.data.count == 0 {
                self.presentEmptyDataWarningAlert()
            }else{
                //self.data.removeAll()
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                
                for item in self.data {
                    managedObjectContext?.delete(item)
                }
                
                try? managedObjectContext?.save()
                
                self.fetch()
                //managedObjectContext?.delete()
                //self.tableView.reloadData()
            }
        }))
        
        alertController.addAction(removeAllButon)
        present(alertController, animated: true)
    }
    
    func presentAddAlert(){
        let alertController = createBasicAlertController(title: "Yeni Eleman Ekle", message: nil, cancelButtonTitle: "Vazgeç")
        
        let addToListButton = UIAlertAction(title: "Ekle",
                                            style: .default,
                                            handler: ({ _ in
            let inputText = alertController.textFields?.first?.text
            if inputText != ""{
                //self.data.append(inputText!)
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                let entitiy = NSEntityDescription.entity(forEntityName: "ListItem",
                                                         in: managedObjectContext!)
                
                let listItem = NSManagedObject(entity: entitiy!,
                                               insertInto: managedObjectContext)
                
                listItem.setValue(inputText,
                                  forKey: "title")
                
                try? managedObjectContext?.save()
                
                self.fetch()
            }else{
                self.presentEmptyAreaWarningAlert()
            }
        }))
        
        alertController.addTextField()
        alertController.addAction(addToListButton)
        present(alertController, animated: true)
    }
    
    func presentEmptyAreaWarningAlert(){
        presentWarningAlert(title: "Uyarı!", message: "Mesaj Alanı Boş Bırakılamaz.")
    }
    
    func presentEmptyDataWarningAlert(){
        presentWarningAlert(title: "Uyarı!", message: "Liste zaten boş")
    }
    
    func presentWarningAlert(title: String, message: String?){
        let alertController = createBasicAlertController(title: title,
                                                         message: message,
                                                         cancelButtonTitle: "Tamam")
        present(alertController, animated: true)
    }
    
    func createBasicAlertController(title: String?, message: String?, preferredStyle: UIAlertController.Style = .alert, cancelButtonTitle: String?) -> UIAlertController{
        
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: preferredStyle)
        
        let cancelButton = UIAlertAction(title: cancelButtonTitle,
                                         style: .cancel)
        
        alertController.addAction(cancelButton)
        return alertController
    }
    
    func fetch(){
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedObjectContext = appDelegate?.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ListItem")
        
        data = try! managedObjectContext!.fetch(fetchRequest)
        
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
        let listItem = data[indexPath.row]
        cell.textLabel?.text = listItem.value(forKey: "title") as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let deleteAction = UIContextualAction(style: .normal,
                                              title: "Sil") { _, _, _ in
            //self.data.remove(at: indexPath.row)
            
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
            
            let managedObjectContext = appDelegate?.persistentContainer.viewContext
            
            managedObjectContext?.delete(self.data[indexPath.row])
            
            try? managedObjectContext?.save()
            self.fetch()
            //self.tableView.reloadData()
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal,
                                            title: "Düzenle") { _, _, _ in
            self.showEditAlert(indexPath: indexPath)
        }
        
        let config = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        return config
    }
    
    func showEditAlert(indexPath: IndexPath){
        let alertController = createBasicAlertController(title: "Düzenle", message: nil, cancelButtonTitle: "Vazgeç")
        
        alertController.addTextField()
        let listItem = data[indexPath.row]
        alertController.textFields?.first?.text = listItem.value(forKey: "title") as? String
        
        let editButton = UIAlertAction(title: "Düzenle",
                                       style: .default,
                                       handler: ({ _ in
            let inputText = alertController.textFields?.first?.text
            if inputText != ""{
                //self.data[indexPath.row] = inputText!
                let appDelegate = UIApplication.shared.delegate as? AppDelegate
                
                let managedObjectContext = appDelegate?.persistentContainer.viewContext
                
                self.data[indexPath.row].setValue(inputText, forKey: "title")
                
                if managedObjectContext!.hasChanges {
                    try? managedObjectContext?.save()
                }
            }else{
                self.presentEmptyAreaWarningAlert()
            }
            self.tableView.reloadData()
        }))
        
        
        alertController.addAction(editButton)
        present(alertController, animated: true)
    }
}
