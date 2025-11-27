/*
 * This is the sample of Dynamsoft Barcode Reader.
 *
 * Copyright © Dynamsoft Corporation.  All rights reserved.
 */

import SwiftUI

struct ContentView: View {
    @State private var scanResult: String = ""
    @State private var isShowingScanner: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            Text(scanResult)
                .multilineTextAlignment(.center)
                .font(.title2)
                .foregroundColor(.primary)
                .padding()
            Spacer()
            Button(action: {
                isShowingScanner = true
            }) {
                Text("Scan a Barcode")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(width: 160, height: 48)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .padding(.bottom, 32)
        }
        .fullScreenCover(isPresented: $isShowingScanner) {
            BarcodeScannerView(
                isShowingScanner: $isShowingScanner,
                scanResult: $scanResult
            )
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ContentView()
}
