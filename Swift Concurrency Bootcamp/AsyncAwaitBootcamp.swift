//
//  AsyncAwaitBootcamp.swift
//  Swift Concurrency Bootcamp
//
//  Created by John Guerrero on 9/30/24.
//

import SwiftUI

class AsyncAwaitBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []

    func addTitle1() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            self.dataArray.append("Title 1: \(Thread.current)")
        }
    }

    func addTitle2() {
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(2)) {
            let title = "Title 2: \(Thread.current)"
            self.dataArray.append(title)
        }
    }

    func addAuthor() async {
        let author = "Author1 : \(Thread.current)"
        self.dataArray.append(author)

        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let author2 = "Author2 : \(Thread.current)"

        await MainActor.run {
            self.dataArray.append(author2)

            let author3 = "Author3 : \(Thread.current)"
            self.dataArray.append(author3)
        }

        await addSomething()
    }

    func addSomething() async {
        try? await Task.sleep(nanoseconds: 2_000_000_000)

        let something = "Something1 : \(Thread.current)"
        await MainActor.run {
            self.dataArray.append(something)

            let something2 = "Something2 : \(Thread.current)"
            self.dataArray.append(something2)
        }
    }
}

struct AsyncAwaitBootcamp: View {

    @StateObject var viewModel: AsyncAwaitBootcampViewModel = AsyncAwaitBootcampViewModel()

    var body: some View {
        List {
            ForEach(viewModel.dataArray, id: \.self) { title in
                Text(title)
            }
        }
        .onAppear {
            Task {
                await viewModel.addAuthor()

                let finaltText = "FINAL TEXT: \(Thread.current)"
                viewModel.dataArray.append(finaltText)
            }
            /*
            viewModel.addTitle1()
            viewModel.addTitle2()
             */
        }
    }
}

#Preview {
    AsyncAwaitBootcamp()
}

