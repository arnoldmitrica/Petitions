//
//  ViewController.swift
//  project7
//
//  Created by Arnold Mitricã on 23/10/2020.
//

import UIKit

class ViewController: UITableViewController {
    
    
    var petitions = [Petition]()
    var filter = [String]()
    var petitionsfiltered = [Petition]()
    var urlString = ""

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filter.isEmpty {
            return petitions.count
        }
        else{
            return petitionsfiltered.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        //let petitionfiltered = petitionsfiltered[indexPath.row]
        if filter.isEmpty {
            cell.textLabel?.text = petition.title
            cell.detailTextLabel?.text = petition.body
            //print(indexPath.row)
        }
        else{
            cell.textLabel?.text = petitionsfiltered[indexPath.row].title
            cell.detailTextLabel?.text = petitionsfiltered[indexPath.row].body
        }
        return cell
    }
    
    func filtering(){
       // let petitionsfilterednew
        for word in filter{
            self.petitionsfiltered = petitionsfiltered.filter { $0.body.contains(word)}
        }
//        DispatchQueue.main.async {
//            [weak self] in
//            self?.petitionsfiltered = petitionsfilterednew
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(alerta))
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(alerta)), UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(addfilter))]
        // let urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?limit=100"
        } else {
            urlString = "https://api.whitehouse.gov/v1/petitions.json?signatureCountFloor=10000&limit=100"
        }
        
        performSelector(inBackground: #selector(fetchJSON), with: nil)
        //fetchJSON()
    }

    @objc func fetchJSON() {
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        
    }

    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    @objc func alerta(){
        let ac = UIAlertController(title: "Info", message: "We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    @objc func addfilter() {
        // title = "Add filter"
        let ac = UIAlertController(title: "Enter filter", message:nil, preferredStyle: .alert)
        ac.addTextField()
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self, weak ac] _ in
            guard let answer = ac?.textFields?[0].text else { return }
            self?.submit(answer)
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    func submit(_ answer: String)
    {
        filter.append(answer)
        print(filter)
        if filter.count == 1 {
            navigationItem.rightBarButtonItems?.append(UIBarButtonItem(barButtonSystemItem: .redo, target: self, action: #selector(removefilter)))
            petitionsfiltered = petitions
        }
        filtering()
        
        tableView.reloadData()
    }
    func submitremove(){
        filter.removeAll()
        navigationItem.rightBarButtonItems?.removeLast()
        tableView.reloadData()
    }
    @objc func removefilter() {
        var filters = String()
        for word in filter{
            filters.append(word)
            filters.append(" ")
        }
        let ac = UIAlertController(title: "Remove filter", message: "You removed filters: '\(filters)'.", preferredStyle: .alert)
        let submitAction = UIAlertAction(title: "Submit", style: .default){
            [weak self] _ in
            self?.submitremove()
        }
        ac.addAction(submitAction)
        present(ac, animated: true)
    }
    @objc func showError() {
        
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        if filter.isEmpty{
            vc.detailItem = petitions[indexPath.row]
        }
        else{
            vc.detailItem = petitionsfiltered[indexPath.row]
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

