//
//  DoCatchTryThrowsBootcamp.swift
//  Swift Concurrency Bootcamp
//
//  Created by John Guerrero on 9/27/24.
//

import SwiftUI

// do-catch
// try
// throws

class DoCatchTryThrowsBootcampDataManager {

    let isActive: Bool = false

    func getTitle() -> (title: String?, error: Error?) {
        if isActive {
            return ("New title...", nil)
        } else {
            return (nil, URLError(.badURL))
        }
    }

    func getTitle2() -> Result<String, Error> {
        if isActive {
            return .success("New title...")
        } else {
            return .failure(URLError(.badURL))
        }
    }

    func getTitle3() throws -> String? {
        if isActive {
            return "New title..."
        } else {
            throw URLError(.badURL)
        }
    }

    func getTitle4() throws -> String {
        if isActive {
            return "Final title..."
        } else {
            throw URLError(.badServerResponse)
        }
    }
}

class DoCatchTryThrowsBootcampViewModel: ObservableObject {

    @Published var title = "Starting text..."
    let manager = DoCatchTryThrowsBootcampDataManager()

    func fetchTitle() {
        /*
                let returnedValue = manager.getTitle()
        
                if let newTitle = returnedValue.title {
                    self.title = newTitle
                } else if let error = returnedValue.error {
                    self.title = "Error: \(error)"
                }
         */
        /*
        let result = manager.getTitle2()

        switch result {
            case .success(let newTitle):
                self.title = newTitle
            case .failure(let error):
                self.title = "Error: \(error)"
        }
*/

        do {
            // This will avoid catch statement
            let newTitle = try? manager.getTitle3()
            if let newTitle {
                self.title = newTitle
            }

            let finalTitle = try manager.getTitle4()
            self.title = finalTitle
        } catch {
            self.title = "Error: \(error)"
        }

        // To avoid using errors and just validate the try statement
//        let newTitle = try? manager.getTitle3()
//        if let newTitle {
//            self.title = newTitle
//        }

    }
}

struct DoCatchTryThrowsBootcamp: View {

    @StateObject private var viewModel = DoCatchTryThrowsBootcampViewModel()

    var body: some View {
        Text(viewModel.title)
            .frame(width: 300, height: 300)
            .background(Color.blue)
            .onTapGesture {
                viewModel.fetchTitle()
            }
    }
}

#Preview {
    DoCatchTryThrowsBootcamp()
}
