import Foundation

protocol DropDownDelegate: class {
    func usersPicked(sender: DropDownTable, users: [String])
}