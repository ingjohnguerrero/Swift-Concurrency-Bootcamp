//
//  TaskBootcamp.swift
//  Swift Concurrency Bootcamp
//
//  Created by John Guerrero on 9/30/24.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil

    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200/300") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            let image = UIImage(data: data)
            await MainActor.run {
                self.image = image
                print("Image fetched successfully!")
            }
        } catch {
            print(error)
        }
    }

    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/1000") else { return }
            let (data, _) = try await URLSession.shared.data(from: url, delegate: nil)
            let image = UIImage(data: data)
            await MainActor.run {
                self.image2 = image
            }
        } catch {
            print(error)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click me!") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @StateObject var viewModel: TaskBootcampViewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<Void, Never>? = nil

    var body: some View {
        VStack{
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }

            if let image2 = viewModel.image2 {
                Image(uiImage: image2)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            print(Thread.current)
            print(Task.currentPriority)
            await viewModel.fetchImage()
        }
//        .onDisappear() {
//            fetchImageTask?.cancel()
//        }
//        .onAppear() {
//            self.fetchImageTask = Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
//
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
//        }
    }
}

#Preview {
    TaskBootcamp()
}
