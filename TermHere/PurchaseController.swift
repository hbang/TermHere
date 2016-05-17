//
//  PurchaseController.swift
//  TermHere
//
//  Created by Adam Demasi on 16/05/2016.
//  Copyright © 2016 HASHBANG Productions. All rights reserved.
//

import Cocoa
import StoreKit

let PurchaseControllerReceivedProductsNotification = "PurchaseControllerReceivedProductsNotification"
let PurchaseControllerDonationProductIdentifier = "au.com.hbang.TermHere.DonationTier5"

class PurchaseController: NSObject, SKPaymentTransactionObserver, SKProductsRequestDelegate {

	var products: [SKProduct] = []

	override init() {
		super.init()

		// add ourselves as an observer and get the list of products
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
		getProducts()
	}

	deinit {
		SKPaymentQueue.defaultQueue().removeTransactionObserver(self)
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
		let payment = SKMutablePayment.paymentWithProduct(product) as! SKMutablePayment
		SKPaymentQueue.defaultQueue().addPayment(payment)
	}

	// MARK: - SKProductsRequestDelegate

	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
		// as long as we have something
		if response.products != nil && response.products!.count > 0 {
			// set our variable
			products = response.products!

			// send a notification
			NSNotificationCenter.defaultCenter().postNotification(NSNotification(name: PurchaseControllerReceivedProductsNotification, object: products))
		}
	}
	
	func request(request: SKRequest, didFailWithError error: NSError?) {
		if error != nil {
			NSLog("loading products failed? %@", error!)
		}
	}

	// MARK: - SKPaymentTransactionObserver

	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
		// TODO: NSAlert stuff should not be here
		let transaction = transactions[0]

		switch transaction.transactionState {
		case SKPaymentTransactionStatePurchasing:
			break

		case SKPaymentTransactionStatePurchased, SKPaymentTransactionStateRestored, SKPaymentTransactionStateDeferred:
			let alert = NSAlert()
			alert.messageText = NSLocalizedString("DONATION_SUCCEEDED", comment: "Message displayed when a donation has successfully been made.")
			alert.runModal()

		case SKPaymentTransactionStateFailed:
			let alert = NSAlert(error: transaction.error!)
			alert.runModal()

		default:
			// stupid anonymous enums
			break
		}
	}

}
