import Foundation

protocol NewTransactionDelegate: class {
    func dataReloadNeeded(sender: TransactionViewController)
}