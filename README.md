UAH/USD Order Book
This Swift implementation manages a trading order book for UAH/USD pairs. It matches buy/sell orders when prices overlap, executing trades automatically.

Key Features:

Processes buy/sell orders with price/amount prioritization
Maintains separate sorted order books (buy: highest first, sell: lowest first)
Outputs balance changes for executed trades
Displays real-time order book status
Usage:

Run with swift run
Enter orders: userId amount price buy|sell (e.g., 1 100 46 buy)
View matches and balance changes
Type 'exit' to quit
Efficiency:

O(n) order insertion and matching
Simple array structure with sorting after modifications
The system automatically calculates USD amounts (UAH amount / rate) and tracks asset movements between users during trades.
