import Foundation
import SwiftUI

struct BreatheEntryScreen: View {
    @StateObject private var loader: BreatheWebLoader

    init(loader: BreatheWebLoader) {
        _loader = StateObject(wrappedValue: loader)
    }

    var body: some View {
        ZStack {
            BreatheWebViewBox(loader: loader)
                .opacity(loader.state == .finished ? 1 : 0.5)
            switch loader.state {
            case .progressing(let percent):
                BreatheProgressIndicator(value: percent)
            case .failure(let err):
                BreatheErrorIndicator(err: err)  // err теперь String
            case .noConnection:
                BreatheOfflineIndicator()
            default:
                EmptyView()
            }
        }
    }
}

private struct BreatheProgressIndicator: View {
    let value: Double
    var body: some View {
        GeometryReader { geo in
            BreatheLoadingOverlay(progress: value)
                .frame(width: geo.size.width, height: geo.size.height)
                .background(Color.black)
        }
    }
}

private struct BreatheErrorIndicator: View {
    let err: String  // было Error, стало String
    var body: some View {
        Text("Ошибка: \(err)").foregroundColor(.red)
    }
}

private struct BreatheOfflineIndicator: View {
    var body: some View {
        Text("Нет соединения").foregroundColor(.gray)
    }
}
