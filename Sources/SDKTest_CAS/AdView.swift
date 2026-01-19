
import SwiftUI
import WebKit
import UIKit

@MainActor
public struct AdView: View {
    public let url: URL
    public let onClose: () -> Void
    public let onLoad: () -> Void
    
    public let adDuration: TimeInterval = 10
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var progress: Double = 0.0
    @State private var isCloseButtonVisible = false
    @State private var timer: Timer?
    
    // ------ If need set app product, you must get data from server ------//
    @State public var appProduct: AppProduct?
    
    public init(url: URL, onClose: @escaping () -> Void, onLoad: @escaping () -> Void, appProduct: AppProduct? = nil) {
        self.url = url
        self.onClose = onClose
        self.onLoad = onLoad
        self._appProduct = State(initialValue: appProduct)
    }
  
    public var body: some View {
        VStack(spacing: 10) {
            HStack(alignment: .bottom,spacing: 0) {
                if let appProduct {
                    ProductView(appProduct: appProduct)
                }
                
                if isCloseButtonVisible {
                    Spacer()
                    CloseButton
                }
                
                if !isCloseButtonVisible {
                    ProgressLine
                }
            }
            .frame(minHeight: 24)
            .padding(.horizontal, 10)
            
            WebViewWrapper(url: url, onLoad: {
                startTimer()
                onLoad()
            })
            .edgesIgnoringSafeArea(.all)
            .clipShape(.rect(cornerRadius: 20))
        }
        .background(colorScheme == .dark ? Color.black.opacity(0.93) : Color.white)
        .edgesIgnoringSafeArea([.leading, .trailing, .bottom])
    }
   
    //MARK: - Product View
    @ViewBuilder
    private func ProductView(appProduct: AppProduct) -> some View {
        Button {
            if let url = URL(string: "https://apps.apple.com/app/\(appProduct.appID)") {
                UIApplication.shared.open(url)
            }
        } label: {
            HStack {
                // Note: Image(appProduct.iconApp) assumes the image is in the bundle. 
                // Since this is now in a package, loading images by name requires .module bundle if assets are in package.
                // Assuming currently we just use system name or logic from host app. 
                // If 'iconApp' is a system name:
                if UIImage(systemName: appProduct.iconApp) != nil {
                     Image(systemName: appProduct.iconApp)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(.rect(cornerRadius: 12))
                } else {
                    // Placeholder or from bundle logic. Simplifying for now.
                    Image(systemName: "app.fill") 
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(.rect(cornerRadius: 12))
                }
 
// ------------ if need get image url from server ----------------------//
                
//                if let url = appProduct.iconApp, !url.isEmpty {
//                    AsyncImage(url: URL(string: url)) { image in
//                        image
//                            .resizable()
//                            .scaledToFill()
//                            .frame(width: 40, height: 40)
//                            .clipShape(.rect(cornerRadius: 12))
//                    } placeholder: {
//                        RoundedRectangle(cornerRadius: 14)
//                            .fill(Color.gray.opacity(0.2))
//                            .overlay(
//                                ProgressView()
//                                    .scaleEffect(0.7)
//                            )
//                    }
//                    .frame(width: 40, height: 40)
//                    .clipShape(.rect(cornerRadius: 12))
//                } else {
//                    Image("nologo")
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 40, height: 40)
//                        .clipShape(.rect(cornerRadius: 12))
//                }
// -------------------------------------------------------------------//
                
                VStack(alignment: .leading) {
                    Text(appProduct.nameApp)
                        .foregroundStyle(Color.primary)
                        .font(Font.system(size: 12, weight: .bold))
                        .multilineTextAlignment(.leading)
                    
                    Text("install")
                        .foregroundStyle(Color.white)
                        .font(Font.system(size: 12, weight: .medium))
                        .padding(.vertical, 2)
                        .padding(.horizontal, 10)
                        .background(Color.blue)
                        .clipShape(.rect(cornerRadius: 20))
                }
            }
            .frame(minWidth: 130, minHeight: 40, alignment: .leading)
        }
        Spacer(minLength: 0)
    }
    
    //MARK: - Close button
    @ViewBuilder
    private var CloseButton: some View {
        Button(action: onClose) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 24, height: 24)
                    .overlay {
                        Circle()
                            .stroke(Color.gray, lineWidth: 1)
                    }
                
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 12, height: 12)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.gray)
            }
        }
    }
    
    //MARK: - Progress view
    @ViewBuilder
    private var ProgressLine: some View {
        ProgressView(value: min(progress, 1.0), total: 1.0)
            .progressViewStyle(.linear)
            .frame(height: 4)
            .background(Color.white.opacity(0.5))
            .clipShape(.rect(cornerRadius: 20))
    }
    
    //MARK: - Start timer
    private func startTimer() {
        let step = 0.1
        timer = Timer.scheduledTimer(withTimeInterval: step, repeats: true) { _ in
            Task { @MainActor in
                if progress < 1.0 {
                    withAnimation(.linear(duration: 0.5)) {
                        progress += step / adDuration
                    }
                } else {
                    timer?.invalidate()
                    withAnimation(.linear(duration: 0.1)) {
                        isCloseButtonVisible = true
                    }
                }
            }
        }
    }
}
