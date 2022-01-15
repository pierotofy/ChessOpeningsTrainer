//
//  StoreManager.swift
//  chessopeningstrainer (iOS)
//
//  Created by Piero on 1/15/22.
//

import Foundation
import StoreKit

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    @Published var isPro : Bool = AppSettings.shared.isPro
    @Published var transactionState: SKPaymentTransactionState?

    var isProKey = "com.masseranolabs.chessopeningstrainer.IAP.pro"
    
    func setPurchased(){
        isPro = true
        AppSettings.shared.isPro = true
    }
    
    override init (){
        super.init()
        SKPaymentQueue.default().add(self)
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Received products response")
        
        var found = false
        if !response.products.isEmpty {
            for p in response.products{
                if p.productIdentifier == isProKey {
                    found = true
                    print("Found Pro product")
                    
                    if SKPaymentQueue.canMakePayments() {
                        let payment = SKPayment(product: p)
                        SKPaymentQueue.default().add(payment)
                    } else {
                        print("You cannot make payments.")
                        transactionState = .failed
                    }
                }
            }
        }
        
        if !found {
            print("Product not found")
            transactionState = .failed
        }

        for invalidIdentifier in response.invalidProductIdentifiers {
            print("Invalid identifiers found: \(invalidIdentifier)")
        }
    }
    
    func purchase(){
        print("Start requesting products ...")
        let request = SKProductsRequest(productIdentifiers: Set([isProKey]))
        request.delegate = self
        request.start()
    }
    
    func restore() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing
            case .purchased:
                transactionState = .purchased
                setPurchased()
            case .restored:
                transactionState = .restored
                setPurchased()
            case .failed, .deferred:
                print("Payment Queue Error: \(String(describing: transaction.error))")
                transactionState = .failed
            default:
                queue.finishTransaction(transaction)
            }
        }
    }
    
}

