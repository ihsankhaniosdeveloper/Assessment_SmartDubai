//
//  ViewModel.swift
//  NY Times
//
//  Created by Ihsan on 21/01/2022.
//

import SwiftUI
import Combine

class ViewModel: ObservableObject {
    @Published var results = [DocsNYTIME]()
    var pub: AnyPublisher<(data: Data, response: URLResponse), URLError>? = nil
    var sub: Cancellable? = nil
    @Published var loading = false

    init() {
        
        guard let url = URL(string: "https://api.nytimes.com/svc/search/v2/articlesearch.json?q=election&api-key=fhU1UA6O1biwfizeI9ecMQAZAYDu12v2") else {return}
        pub = URLSession.shared.dataTaskPublisher(for: url)
                .eraseToAnyPublisher()
        sub = pub?.sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    fatalError(error.localizedDescription)
                }
            },
            receiveValue: { item in
                do {
                    let item = try JSONDecoder().decode(NYTime.self , from: item.data)
                    DispatchQueue.main.async {
                        self.results = item.response?.docs  ?? []
                        self.loading = true
                    }
                } catch {
                      print("Failed to decode \(error)")
                  }
                }
            )
        }
}
