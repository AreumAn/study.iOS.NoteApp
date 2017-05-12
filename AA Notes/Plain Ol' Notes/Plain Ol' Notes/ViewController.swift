//
//  ViewController.swift
//  AA Notes
//
//  Created by AA Group on 2017-04-05.
//  Copyright © 2017 Todd Perkins. All rights reserved.
//
// description: List of note page

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    
    @IBOutlet weak var table: UITableView!
    
    var data:[String] = []
    var selectedRow:Int = -1
    var newRowText:String = ""
    
    var controller: NSFetchedResultsController<Note>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "AA Notes"
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        fetch()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedRow == -1 {
            return
        }
        
        
        data.removeAll()
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            let fetchedNote = try context.fetch(fetchRequest)
            for result in fetchedNote as [Note] {
                self.data.append(contentsOf: [result.details!])
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        

        
        table.reloadData()
        
    }
    
    func addNote() {
        if (table.isEditing) {
            return
        }
        
        let name:String = ""

        data.insert(name, at: 0)
        
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        table.insertRows(at: [indexPath], with: .automatic)
        table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.performSegue(withIdentifier: "detail", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        table.setEditing(editing, animated: animated)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        
        do {
            var fetchedNote = try context.fetch(fetchRequest)
            let temp = fetchedNote[indexPath.row]
            
            // delete note
            context.delete(temp)
            ad.saveContext()
            
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        data.remove(at: indexPath.row)
        table.deleteRows(at: [indexPath], with: .fade)
        

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "detail", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView:DetailViewController = segue.destination as! DetailViewController
        selectedRow = table.indexPathForSelectedRow!.row
        detailView.masterView = self
        detailView.setText(t: data[selectedRow], r:selectedRow)

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetch() {
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        do {
            let fetchedNote = try context.fetch(fetchRequest)
            for result in fetchedNote as [Note] {
                self.data.append(contentsOf: [result.details!])
            }
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        table.reloadData()
        
    }
    
    //delete all the data from the core data
    func cleanCoreData() {
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteRequest)
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
        
        let fetchImgRequest: NSFetchRequest<Image> = Image.fetchRequest()
        let deleteImgRequest = NSBatchDeleteRequest(fetchRequest: fetchImgRequest as! NSFetchRequest<NSFetchRequestResult>)
        do {
            try context.execute(deleteImgRequest)
        } catch {
            fatalError("Failed to fetch person: \(error)")
        }
    }

}

// Hide keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}

