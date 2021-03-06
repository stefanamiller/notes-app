//
//  NotesListViewController.swift
//  NotesApp
//
//  Created by Stefan Miller on 2015-08-15.
//  Copyright (c) 2015 Stefan Miller. All rights reserved.
//

import UIKit
import ReactiveCocoa

class NoteListTableViewCell: UITableViewCell {
   lazy var noteTitle: DynamicProperty! = DynamicProperty(object: self.textLabel, keyPath: "text")
   lazy var updatedTime: DynamicProperty! = DynamicProperty(object: self.detailTextLabel, keyPath: "text")
   
   func bindViewModel(viewModel: NoteViewModel) {
      noteTitle <~ viewModel.title.producer |> map { $0 as AnyObject? }
      updatedTime <~ viewModel.dateStamp.producer |> map { $0 as AnyObject }
   }
}

class NotesListViewController: UITableViewController {

   var detailViewController: NoteEditingViewController? = nil
   var lastIndexPath: NSIndexPath?

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
          self.detailViewController = controllers[controllers.count-1].topViewController as? NoteEditingViewController
      }
      
   }
   
   func setupBindings() {
      listViewModel.insertSignal
         |> mapIndexes
         |> observe(next: insertRowsForIndexes)
      listViewModel.removeSignal
         |> mapIndexes
         |> observe(next: deleteRowsForIndexes)
      listViewModel.updateSignal
         |> mapIndexPair
         |> observe(next: moveRowsBetweenIndexPaths)
   }
   
   private lazy var mapIndexes: (Signal<Int, NoError> -> Signal<[NSIndexPath], NoError>)! = map { indexes in
      return [self.indexPathForNoteIndex(indexes)]
   }
   
   private lazy var mapIndexPair: (ReactiveCocoa.Signal<(Int,Int), NoError> -> ReactiveCocoa.Signal<(NSIndexPath,NSIndexPath), NoError>)! = map { indexPairs in
      let fromIndexPath = self.indexPathForNoteIndex(indexPairs.0)
      let toIndexPath   = self.indexPathForNoteIndex(indexPairs.1)
      return (fromIndexPath, toIndexPath)
   }
   
   func indexPathForNoteIndex(noteIndex: Int) -> NSIndexPath {
      return NSIndexPath(forRow: noteIndex, inSection: 0)
   }
   
   func insertRowsForIndexes(indexPaths: [NSIndexPath]) {
      tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Automatic)
   }
   
   func deleteRowsForIndexes(indexPaths: [NSIndexPath]) {
      tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
   }
   
   func moveRowsBetweenIndexPaths(indexPathPair: (NSIndexPath,NSIndexPath)) {
      tableView.moveRowAtIndexPath(indexPathPair.0, toIndexPath: indexPathPair.1)
   }

   // MARK: - Segues

   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
      if segue.identifier == "showDetail" {
          if let indexPath = self.tableView.indexPathForSelectedRow() {
              let noteModel = listViewModel.noteViewModelAtIndex(indexPath.row)
              let controller = (segue.destinationViewController as! UINavigationController).topViewController as! NoteEditingViewController

              self.detailViewController = controller
              lastIndexPath = indexPath

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
      cell.bindViewModel(noteModel)
      return cell
   }

   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
      return true
   }

   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
      if editingStyle == .Delete {
         listViewModel.deleteNoteAtIndex(indexPath.row)
         self.selectNextNoteIfAvailable(indexPath)
      }
   }

   func selectNextNoteIfAvailable(indexPath: NSIndexPath) {
      if let oldIndexPath = self.lastIndexPath {
         if indexPath.isEqual(oldIndexPath) && detailViewController != nil {
            self.lastIndexPath = self.nextIndexPathForNoteAfter(indexPath)
            self.selectNewNoteRowAtIndexPath(self.lastIndexPath)
         }
      }
   }
   
   func nextIndexPathForNoteAfter(indexPath: NSIndexPath) -> NSIndexPath? {
      if (indexPath.row < tableView.numberOfRowsInSection(0)) {
         return NSIndexPath(forRow: indexPath.row, inSection: 0)
      }
      else {
         return nil
      }
   }
   
   func selectNewNoteRowAtIndexPath(indexPath: NSIndexPath?) {
      var nextViewModel: NoteViewModel? = nil
      if let newIndexPath = indexPath {
         nextViewModel = listViewModel.noteViewModelAtIndex(newIndexPath.row)
         tableView.selectRowAtIndexPath(newIndexPath, animated: true, scrollPosition: .Bottom)
      }
      
      let viewModel = nextViewModel ?? NoteViewModel()
      detailViewController?.bindViewModel(viewModel)
   }
}

