//
//  PurchaseController.swift
//  TermHere
//
//  Created by Adam Demasi on 16/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import StoreKit

let PurchaseControllerReceivedProductsNotification = Notification.Name(rawValue: "PurchaseControllerReceivedProductsNotification")
let PurchaseControllerDonationProductIdentifier = "au.com.hbang.TermHere.DonationTier5"

class PurchaseController: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

	var products: [SKProduct] = []

	override init() {
		super.init()

		// add ourselves as an observer and get the list of products
		SKPaymentQueue.default().add(self)
		getProducts()
	}

	deinit {
		SKPaymentQueue.default().remove(self)
	}

	// MARK: - Purchase

	func getProducts() {
		// grab the product in question
		let request = SKProductsRequest(productIdentifiers: [PurchaseControllerDonationProductIdentifier])
		request.delegate = self
		request.start()
	}

	func purchase() {
		// get the donation product
		let product = products.filter { $0.productIdentifier == PurchaseControllerDonationProductIdentifier }.first!

		// make the payment
		let payment = SKMutablePayment(product: product)
		SKPaymentQueue.default().add(payment)
	}

	// MARK: - SKProductsRequestDelegate

	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
		// as long as we have something
		if response.products.count > 0 {
			// set our variable
			products = response.products

			// send a notification
			NotificationCenter.default.post(Notification(name: PurchaseControllerReceivedProductsNotification, object: products))
		}
	}
	
	func request(_ request: SKRequest, didFailWithError error: Error) {
		NSLog("loading products failed? \(error)")
	}

	// MARK: - SKPaymentTransactionObserver

	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		// TODO: NSAlert stuff should not be here
		let transaction = transactions[0]

		switch transaction.transactionState {
		case .purchasing:
			break

		case .purchased, .restored, .deferred:
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("DONATION_SUCCEEDED", tableName: "About", comment: "Message displayed when a donation has successfully been made.")
			alert.runModal()

		case .failed:
			// it seems we have to cast to NSError to get the code? that doesn’t
			// sound right…
			let error = transaction.error! as NSError
			if error.code != SKError.paymentCancelled.rawValue {
				let alert = NSAlert(error: transaction.error!)
				alert.runModal()
			}
		}
	}

}
