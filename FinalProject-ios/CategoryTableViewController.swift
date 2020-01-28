//
//  CategoryTableViewController.swift
//  FinalProject-ios
//
//  Created by Simran Chakkal on 2020-01-27.
//  Copyright © 2020 simran. All rights reserved.
//

import UIKit
import CoreData
class CategoryTableViewController: UITableViewController {
   
    // Variables
     var notebooks:[Notebook] = []
  
    // MARK:  CoreData variables
       var context:NSManagedObjectContext!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // initialize CoreData variables
              guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
              context = appDelegate.persistentContainer.viewContext
              
              // setup array of notebooks
              getAllNotebooks()


    }
    
    @IBAction func btnSortCategory(_ sender: UIBarButtonItem) {
        let alertBox = UIAlertController(title: "Sort", message: "Choose Criteria", preferredStyle: .alert)
        
        
        // 2. Add Save and Cancel buttons
        alertBox.addAction(UIAlertAction(title: "Date Created", style: .default, handler: { alert -> Void in
            self.getAllNotebooks()
            self.tableView.reloadData()
        }))
        alertBox.addAction(UIAlertAction(title: "Title(Asc)", style: .default, handler: { alert -> Void in
            self.getAllNotebooksByTitle()
            self.tableView.reloadData()
        }))
        alertBox.addAction(UIAlertAction(title: "Title(Desc)", style: .default, handler: { alert -> Void in
            self.getAllNotebooksByTitleDesc()
            self.tableView.reloadData()
        }))
        
        alertBox.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        
        
        
        // 4. show the alertbox
        self.present(alertBox, animated: true, completion: nil)
    }
    @IBAction func addNotesName(_ sender: UIBarButtonItem) {
        // 1. Create a popup
               let alertBox = UIAlertController(title: "Add a Category", message: "Enter the name of new category", preferredStyle: .alert)
               
               
               // 2. Add Save and Cancel buttons
               alertBox.addAction(UIAlertAction(title: "Save", style: .default, handler: { alert -> Void in
                   let textField = alertBox.textFields![0] as UITextField
                   
                   
                   if (textField.text?.isEmpty == false) {
                       let notebookSaved = self.addNotebook(notebookName: textField.text!)
                       if (notebookSaved == true) {
                           // reload the table
                           self.getAllNotebooks()
                           self.tableView.reloadData()
                       }
                   }
               }))
               alertBox.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
               
               // 3. Add a textbox
               alertBox.addTextField(configurationHandler: {(textField : UITextField!) -> Void in
                   textField.placeholder = "Enter category name"
               })
               
               
               // 4. show the alertbox
               self.present(alertBox, animated: true, completion: nil)
               
    }
      // MARK: database helper functions
    func getAllNotebooks() {
        // setup array of notebooks
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        
        // Uncomment if you want to sort the list by name
        // let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        // notebookFetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            
            self.notebooks = try context.fetch(fetchRequest)
        }
        catch {
            print("Error fetching notebooks from database")
        }
    }
    func getAllNotebooksByTitle() {
        //fetchRequest.predicate = NSPredicate(format: "notebook.name = %@", notebook.name)
        // setup array of notebooks
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        // Uncomment if you want to sort the list by name
        // let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        // notebookFetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            
            self.notebooks = try context.fetch(fetchRequest)
        }
        catch {
            print("Error fetching notebooks from database")
        }
    }
    func getAllNotebooksByTitleDesc() {
        // setup array of notebooks
        let fetchRequest:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: false)]
        
        // Uncomment if you want to sort the list by name
        // let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        // notebookFetchRequest.sortDescriptors = [sortDescriptor]
        
        
        do {
            
            self.notebooks = try context.fetch(fetchRequest)
        }
        catch {
            print("Error fetching notebooks from database")
        }
    }
    func addNotebook(notebookName:String) -> Bool {
        let notebook = Notebook(context: self.context)
        notebook.name = notebookName
        notebook.setValue(Date(), forKey:"dateCreated")
        
        //notebook.dateCreated = Date()
        
        do {
            try self.context.save()
            print("notebook saved!")
            return true
            
        }
        catch {
            print("error while trying to save a new notebook")
        }
        
        return false
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notebooks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Configure the cell...
        cell.textLabel?.text = notebooks[indexPath.row].name!

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            let i = indexPath.row
                     let notebookToDelete = notebooks[i]
                     print(notebookToDelete.name!)
                     
                     // remove from array
                     notebooks.remove(at: i)
                     
                     // remove from databas
                     self.context.delete(notebookToDelete)
                     
                     
                     do {
                         try self.context.save()
                         print("Deleted!")
                     }
                     catch {
                         print("error while commiting notebook delete")
                     }
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "showNotesSegue") {

                  print("calling PREPARE function")
                  
                  
                  let notesVC = segue.destination as! NotesTableViewController
                  
                  let i = (self.tableView.indexPathForSelectedRow?.row)!
                  notesVC.notebook = notebooks[i]

                  
              }
    }


}
