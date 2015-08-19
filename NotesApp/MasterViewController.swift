//
//  MasterViewController.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-15.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NoteListTableViewCell: UITableViewCell {
   lazy var updatedTime: DynamicProperty! = DynamicProperty(object: self.textLabel, keyPath: "text")
}

class MasterViewController: UITableViewController {

   var detailViewController: DetailViewController? = nil

   let listViewModel: NoteListViewModel! = NoteListViewModel()

   override func awakeFromNib() {
      super.awakeFromNib()
      
      if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
          self.clearsSelectionOnViewWillAppear = false
          self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
      }
   }

   override func viewDidLoad() {
      super.viewDidLoad()
      
      self.setupBindings()
      self.navigationItem.leftBarButtonItem = self.editButtonItem()
      
      let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: listViewModel.addAction, action: CocoaAction.selector)
      self.navigationItem.rightBarButtonItem = addButton
      if let split = self.splitViewController {
          let controllers = split.viewControllers
          self.detailViewController = controllers[controllers.count-1].topViewController as? DetailViewController
      }
      
   }
   
   func setupBindings() {
      listViewModel.insertSignal |> observe(next: insertRowsForIndexes)
      listViewModel.removeSignal |> observe(next: deleteRowsForIndexes)
   }
   
   func insertRowsForIndexes(indexes: NSIndexSet) {
      var indexPaths = [NSIndexPath]()
      for index in indexes {
         indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
      }
      tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
   }
   
   func deleteRowsForIndexes(indexes: NSIndexSet) {
      var indexPaths = [NSIndexPath]()
      for index in indexes {
         indexPaths.append(NSIndexPath(forRow: index, inSection: 0))
      }
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
   }

   // MARK: - Segues

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "showDetail" {
          if let indexPath = self.tableView.indexPathForSelectedRow() {
              let noteModel = listViewModel.noteViewModelAtIndex(indexPath.row)
              let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController

              controller.bindViewModel(noteModel)
              controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
              controller.navigationItem.leftItemsSupplementBackButton = true
          }
      }
   }

   // MARK: - Table View

   override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
      return 1
   }

   override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return listViewModel.countOfNotes()
   }

   override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! NoteListTableViewCell

      let noteModel = listViewModel.noteViewModelAtIndex(indexPath.row)
      cell.updatedTime <~ noteModel.dateStamp.producer |> map { $0 as AnyObject }
      return cell
   }

   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      return true
   }

   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle == .Delete {
         listViewModel.deleteNoteAtIndex(indexPath.row)
      }
   }

}

