//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Maurício Costa on 24/01/23.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order.ObservedOrder
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var alertTitle = ""
    
    func placeOrder() async {
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            let decodedOrder = try JSONDecoder().decode(Order.ObservedOrder.self, from: data)
            confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.ObservedOrder.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
            showingConfirmation = true
            alertTitle = "Thank you!"
        } catch {
            print("Checkout failed.")
            confirmationMessage = "Checkout failed."
            showingConfirmation = true
            alertTitle = "Error"
        }
    }
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string:"https://hws.dev/im/cupcakes@3x.jpg"), scale: 3) {
                    image in
                    image.resizable().scaledToFit()
                } placeholder: {
                    ProgressView()
                }.frame(height: 233).accessibilityHidden(true)
                Text("Your total is \(order.cost, format: .currency(code: Locale.current.currencyCode ?? "BRL"))").font(.title)
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }.padding()
            }
        }.navigationTitle("Check out").navigationBarTitleDisplayMode(.inline).alert(alertTitle, isPresented: $showingConfirmation) {
            Button("OK") { }
        } message: {
            Text(confirmationMessage)
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order.ObservedOrder())
    }
}
