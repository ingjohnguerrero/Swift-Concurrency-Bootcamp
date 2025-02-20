//
//  TaskGroupBootcamp.swift
//  Swift Concurrency Bootcamp
//
//  Created by John Guerrero on 10/1/24.
//

import SwiftUI

class TaskGroupBootcampDataManager {

    func fetchImagesWithAsyncLet() async throws -> [UIImage] {
        async let fetchImage1 = try await fetchImages(urlString: "https://picsum.photos/300")
        async let fetchImage2 = try await fetchImages(urlString: "https://picsum.photos/300")
        async let fetchImage3 = try await fetchImages(urlString: "https://picsum.photos/300")
        async let fetchImage4 = try await fetchImages(urlString: "https://picsum.photos/300")
        let (image1, image2, image3, image4) = await (try fetchImage1, try fetchImage2, try fetchImage3, try fetchImage4)
        return [image1, image2, image3, image4]
    }

    func fetchImages(urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString) else { throw URLError(.badURL) }
        do {
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            if let image = UIImage(data: data) {
                return image
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }

    func fetchImagesWithTaskGroup() async throws -> [UIImage] {

        let urlStrings = Array(repeating: "https://picsum.photos/300", count: 5)

        return try await withThrowingTaskGroup(of: UIImage.self) { group in
            var images: [UIImage] = []

            images.reserveCapacity(urlStrings.count )

            for url in urlStrings {
                group.addTask {
                    try await self.fetchImages(urlString: url)
                }
            }

//            group.addTask {
//                try await self.fetchImages(urlString: "https://picsum.photos/300")
//            }
//
//            group.addTask {
//                try await self.fetchImages(urlString: "https://picsum.photos/300")
//            }
//
//            group.addTask {
//                try await self.fetchImages(urlString: "https://picsum.photos/300")
//            }
//
//            group.addTask {
//                try await self.fetchImages(urlString: "https://picsum.photos/300")
//            }

            for try await image in group {
                images.append(image)
            }
            return images
        }
    }
}

class TaskGroupBootcampViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let manager = TaskGroupBootcampDataManager()
    let url = URL(string: "https://picsum.photos/300")

    func getImages() async {
        if let images = try? await manager.fetchImagesWithTaskGroup() {
            self.images.append(contentsOf: images)
        }
    }
}

struct TaskGroupBootcamp: View {

    @StateObject private var viewModel: TaskGroupBootcampViewModel = TaskGroupBootcampViewModel()
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.images, id:\.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Async Let")
            .task {
                await viewModel.getImages()
            }
        }
    }
}

#Preview {
    TaskGroupBootcamp()
}
