//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateCoinPrice(price: String, currency: String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    private let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    private let apiKey = "7607C660-8704-4B8E-BF93-F918493C5912"
    
    let currencyArray = ["AUD", "BRL","CAD","CNY","EUR","GBP","HKD","IDR","ILS","INR","JPY","MXN","NOK","NZD","PLN","RON","RUB","SEK","SGD","USD","ZAR"]
    
    func getCoinPrice(for currency: String) {
        let URLString = "\(baseURL)/\(currency)?apikey=\(apiKey)"
        performRequest(with: URLString, currency: currency)
    }
    
    
    private func performRequest(with URLString: String, currency: String) {
        // 1. Create a URL
        guard let url = URL(string: URLString) else { return }
        // 2. Create a URL session.
        let session = URLSession.shared
        // 3. Give the session a task.
        let task = session.dataTask(with: url) { data, response, error in
            if error != nil {
                delegate?.didFailWithError(error: error!)
                return
            }
            
            guard let safeData = data else { return }
            
            guard let coinValue = self.parseJSON(safeData) else { return }
            
            let coinValueInString = String(format: "%.2f", coinValue)
            
            self.delegate?.didUpdateCoinPrice(price: coinValueInString, currency: currency)

            
        }
        // 4. Start the task.
        task.resume()
        
    }
    
    private func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinModel.self, from: data)
            let rate = decodedData.rate
            
            return rate
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }

    
}

