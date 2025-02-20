//
//  DownloadImageAsync.swift
//  Swift Concurrency Bootcamp
//
//  Created by John Guerrero on 9/27/24.
//

import SwiftUI
import Combine

class DownloadImageAsyncImageLoader {

    let url = URL(string: "https://picsum.photos/200/")!

    func handleResponse(data: Data?, response: URLResponse?) -> UIImage?{
        guard
            let data,
            let image = UIImage(data: data),
            let response = response as? HTTPURLResponse, response.statusCode >= 200 && response.statusCode < 300 else {
            return nil
        }
        return image
    }

    func downloadWithEscaping(completionHandler: @escaping (_ image: UIImage?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            completionHandler(self?.handleResponse(data: data, response: response), nil)
        }
        .resume()
    }

    func downloadWithCombine() -> AnyPublisher<UIImage?, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(handleResponse)
            .mapError({ $0 })
            .eraseToAnyPublisher()
    }

    func downloadWithAsync() async throws -> UIImage? {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            let image = handleResponse(data: data, response: response)
            return image
        } catch {
            throw error
        }
    }
}

class DownloadImageViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let loader = DownloadImageAsyncImageLoader()
    var cancellables = Set<AnyCancellable>()

    func fetchImage() async {
        /*
        loader.downloadWithEscaping { [weak self] image, error in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
         */

        /*
        loader.downloadWithCombine()
            .receive(on: DispatchQueue.main)
            .sink { _ in

            } receiveValue: { [weak self] image in
                self?.image = image
            }

        .store(in: &cancellables)
         */

        let image = try? await loader.downloadWithAsync()
        await MainActor.run {
            self.image = image
        }
    }
}

struct DownloadImageAsync: View {
    @StateObject var viewModel = DownloadImageViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 250
                    )
            } else {
                Text("No image yet")
            }
        }.onAppear {
            Task {
                await viewModel.fetchImage()
            }
        }
    }
}

#Preview {
    DownloadImageAsync()
}
