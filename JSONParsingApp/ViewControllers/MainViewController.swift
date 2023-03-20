//
//  MainViewController.swift
//  JSONParsingApp
//
//  Created by Alexey Manokhin on 19.03.2023.
//

import UIKit

final class MainViewController: UIViewController {
    
    @IBOutlet var dogImageView: UIImageView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var urlAddressLabel: UILabel!
    
    enum Link: String {
        case dog = "https://dog.ceo/api/breeds/image/random"
    }
    
    @IBAction func showDogButtonTapped() {
        activityIndicator.startAnimating()
        fetchDog()
    }
}

extension MainViewController {
    private func fetchDog() {
        guard let url = URL(string: Link.dog.rawValue) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data, let response else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            print(response)
            
            let decoder = JSONDecoder()
            
            do {
                let dog = try decoder.decode(Dog.self, from: data)
                
                print("Dog photo URL address: \(dog.message)\nStatus: " + dog.status.uppercased())
                
                guard let apiImage = URL(string: dog.message.absoluteString) else { return }
                URLSession.shared.dataTask(with: apiImage) { [weak self] data, _, error in
                    guard let data else {
                        print(error?.localizedDescription ?? "No error description")
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self?.dogImageView.image = UIImage(data: data)
                        self?.activityIndicator.stopAnimating()
                        self?.urlAddressLabel.isHidden = false
                        self?.urlAddressLabel.text = """
                        URL-адрес фотографии:
                        
                        \(dog.message.absoluteString)
                        """
                    }
                }.resume()
                
                print("Dog is showed")
                
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
