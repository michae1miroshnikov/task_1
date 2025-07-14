import Foundation

enum Side {
    case buy, sell
}

struct Order {
    let userId: Int64
    var amount: Int64
    let price: Int64
    let side: Side
}

struct BalanceChange {
    let userId: Int64
    let value: Int64
    let currency: String
}

class OrderBook {
    private var buyOrders: [Order] = []
    private var sellOrders: [Order] = []

    func processOrder(_ order: Order) {
        switch order.side {
        case .buy:
            match(order: order, against: &sellOrders, isBuyOrder: true)
        case .sell:
            match(order: order, against: &buyOrders, isBuyOrder: false)
        }
    }

    private func match(order: Order, against oppositeOrders: inout [Order], isBuyOrder: Bool) {
        var incomingOrder = order
        print("Processing: User \(order.userId) wants to \(isBuyOrder ? "BUY" : "SELL") \(order.amount) UAH @ \(order.price) UAH/USD")

        var i = 0
        while i < oppositeOrders.count && incomingOrder.amount > 0 {
            let current = oppositeOrders[i]
            let priceCondition = isBuyOrder
                ? current.price <= incomingOrder.price  // For buy: seller's price <= buyer's max price
                : current.price >= incomingOrder.price  // For sell: buyer's min price >= seller's price

            if priceCondition {
                let tradedAmount = min(incomingOrder.amount, current.amount)
                let rate = current.price

                print("Matched \(tradedAmount) UAH @ \(rate) between User \(incomingOrder.userId) and User \(current.userId)")
                
                // Calculate USD amount needed: UAH amount / exchange rate
                let usdAmount = tradedAmount / rate
                printBalanceChanges(
                    buyerId: isBuyOrder ? incomingOrder.userId : current.userId,
                    sellerId: isBuyOrder ? current.userId : incomingOrder.userId,
                    uahAmount: tradedAmount,
                    usdAmount: usdAmount
                )

                incomingOrder.amount -= tradedAmount
                oppositeOrders[i].amount -= tradedAmount

                if oppositeOrders[i].amount == 0 {
                    oppositeOrders.remove(at: i)
                } else {
                    i += 1
                }
            } else {
                i += 1
            }
        }

        if incomingOrder.amount > 0 {
            print("Remaining \(incomingOrder.amount) UAH added to \(isBuyOrder ? "buy" : "sell") orders.")
            if isBuyOrder {
                buyOrders.append(incomingOrder)
                buyOrders.sort { $0.price > $1.price }
            } else {
                sellOrders.append(incomingOrder)
                sellOrders.sort { $0.price < $1.price }
            }
        }
    }
    
    private func printBalanceChanges(buyerId: Int64, sellerId: Int64, uahAmount: Int64, usdAmount: Int64) {
        print("Balance Changes:")
        print("BalanceChange{user_id: \(buyerId), value: -\(usdAmount), currency: \"USD\"}")
        print("BalanceChange{user_id: \(buyerId), value: \(uahAmount), currency: \"UAH\"}")
        print("BalanceChange{user_id: \(sellerId), value: \(usdAmount), currency: \"USD\"}")
        print("BalanceChange{user_id: \(sellerId), value: -\(uahAmount), currency: \"UAH\"}")
    }

    func displayBook() {
        print("\n--- ORDER BOOK ---")
        print("Buy Orders:")
        for order in buyOrders {
            print("User \(order.userId): \(order.amount) UAH @ \(order.price) UAH/USD")
        }
        print("Sell Orders:")
        for order in sellOrders {
            print("User \(order.userId): \(order.amount) UAH @ \(order.price) UAH/USD")
        }
        print("------------------\n")
    }
}


let book = OrderBook()

print("UAH/USD Order Book")
print("Enter orders: userId amount(UAH) rate(UAH/USD) buy|sell")
print("Example: 1 100 46 buy means buy 100 UAH at rate 46 UAH per 1 USD")
print("Type 'exit' to quit\n")

while true {
    print("Enter order: ", terminator: "")
    guard let input = readLine(), input.lowercased() != "exit" else {
        print("Bye!")
        break
    }

    let parts = input.split(separator: " ")
    if parts.count == 4,
       let userId = Int64(parts[0]),
       let amount = Int64(parts[1]),
       let price = Int64(parts[2]),
       let side = parts[3].lowercased() == "buy" ? Side.buy : parts[3].lowercased() == "sell" ? Side.sell : nil {

        let order = Order(userId: userId, amount: amount, price: price, side: side)
        book.processOrder(order)
        book.displayBook()
    } else {
        print("Invalid format. Use: userId amount price buy|sell")
    }
}
