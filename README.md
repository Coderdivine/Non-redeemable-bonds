---

# Enhanced TokenLock CLI: Advanced Fund Locking with Interest and Savings

This project allows you to interact with an enhanced smart contract for locking USDT tokens on the AssetChain network with advanced features including:
- **Custom lock duration** - Specify how long you want to lock your funds
- **Multiple locks** - Create and manage multiple lock instances simultaneously
- **Daily interest** - Earn daily interest on locked funds
- **Automatic savings** - 5% of earned interest goes to a savings account that unlocks every 30 days

### Prerequisites

Before running the application, you need the following installed:

- Node.js (v16 or above)
- `npm` (Node Package Manager)
- `.env` file with appropriate configurations

### Step 1: Generate New Private Key and Address

To start, you'll need to generate a new private key and wallet address. This can be done using the `generateKeys.js` script.

1. Create a new wallet by running the following command in your terminal:
   ```bash
   node src/utils/generateKeys.js
   ```

2. This will output a new wallet address and private key. Example output:
   ```bash
   Address: 0x6a1c8295c6b27d2d7d2ba4de7c2f31bb5f3f56a2
   Private Key: 0x54acb619a71d9284d1200739b7d4cbf0b6c41f7c8df1b9c332e4e4b84b396ba5a
   ```

3. **Store the generated private key and address** in your `.env` file.

### Step 2: Configure the `.env` File

1. Rename the `.env.example` file to `.env`.
2. Open the `.env` file and replace the following placeholders with the generated wallet details:
   ```bash
   PRIVATE_KEY="your-wallet-private-key"
   WALLET_ADDRESS="your-wallet-address"
   RPC_URL="https://enugu-rpc.assetchain.org"
   USDT_CONTRACT_ADDRESS="0x6fcD081acf6B44334345A56DE1Bd566B0F57d966"   # USDT contract address on AssetChain
   LOCK_ADDRESS="0x05B518e2b19623dc3147d225DE517D918d40ce3b"        # TokenLock contract address
   ```

   Example:
   ```bash
   PRIVATE_KEY="0x54acb619a71d9284d1200739b7d4cbf0b6c41f7c8df1b9c332e4e4b84b396ba5a"
   WALLET_ADDRESS="0x6a1c8295c6b27d2d7d2ba4de7c2f31bb5f3f56a2"
   RPC_URL="https://enugu-rpc.assetchain.org"
   USDT_CONTRACT_ADDRESS="0x6fcD081acf6B44334345A56DE1Bd566B0F57d966"
   LOCK_ADDRESS="0x05B518e2b19623dc3147d225DE517D918d40ce3b"
   ```

3. Ensure your wallet is connected to the AssetChain network or other compatible EVM chains by modifying the `RPC_URL` in the `.env` file.

### Step 3: Install Dependencies

1. Install all necessary dependencies for your project:
   ```bash
   npm install
   ```

### Step 4: Running the CLI Application

1. Once everything is set up, you can interact with the smart contract via the command line using `src/index.js`.

2. To run the application, use the following command:
   ```bash
   node src/index.js
   ```

   You will be prompted to enter one of the following commands:

   - **approve [amount]**: Approve a specified amount of USDT for locking.
   - **lock [amount] [days] [interest_rate]**: Lock tokens with custom duration and interest rate.
   - **list**: List all your lock instances.
   - **claim [lock_index]**: Claim accumulated interest from a specific lock.
   - **withdraw [lock_index]**: Withdraw tokens from a specific lock (after unlock time).
   - **withdraw-savings**: Withdraw accumulated savings (unlocks every 30 days).
   - **status**: Check detailed status of all locks and savings.
   - **help**: Display all available commands.

### Example Commands

- **Approve tokens**: Approve a specified amount of USDT to be used by the TokenLock contract.
  ```bash
  Enter command: approve 1000
  ```
  Output:
  ```bash
  Approving 1000 USDT for TokenLock contract...
  Approval transaction hash: 0xabc123...
  Approval successful!
  ```

- **Lock tokens with custom duration and interest**: Lock 100 USDT for 30 days with 0.5% daily interest.
  ```bash
  Enter command: lock 100 30 50
  ```
  Note: Interest rate is in basis points (100 = 1%, 50 = 0.5%, 10 = 0.1%)
  
  Output:
  ```bash
  Locking 100 USDT for 30 days with 0.5% daily interest...
  Lock transaction hash: 0xdef456...
  Successfully locked 100 USDT!
  ```

- **List all locks**: View all your lock instances.
  ```bash
  Enter command: list
  ```
  Output:
  ```bash
  Total locks: 2

  --- Lock #0 ---
  Status: Active (Locked)
  Amount: 100.0 USDT
  Daily Interest Rate: 0.5%
  Locked at: 11/13/2025, 3:30:00 PM
  Unlocks at: 12/13/2025, 3:30:00 PM
  Pending Interest (claimable): 2.5 USDT
  Pending Savings (5%): 0.125 USDT

  --- Lock #1 ---
  Status: Unlocked (Ready to withdraw)
  Amount: 50.0 USDT
  Daily Interest Rate: 1.0%
  Locked at: 10/15/2025, 2:00:00 PM
  Unlocks at: 11/14/2025, 2:00:00 PM
  Pending Interest (claimable): 15.0 USDT
  Pending Savings (5%): 0.75 USDT
  ```

- **Claim interest**: Claim accumulated interest from a specific lock.
  ```bash
  Enter command: claim 0
  ```
  Output:
  ```bash
  Claiming interest from lock #0...
  Claim transaction hash: 0xghi789...
  Interest successfully claimed!
  ```

- **Withdraw tokens**: Withdraw tokens from a specific lock (after unlock time expires).
  ```bash
  Enter command: withdraw 1
  ```
  Output:
  ```bash
  Withdrawing tokens from lock #1...
  Withdraw transaction hash: 0xjkl012...
  Tokens successfully withdrawn!
  ```

- **Check status**: Check comprehensive status of all locks and savings.
  ```bash
  Enter command: status
  ```
  Output shows all locks plus savings account information:
  ```bash
  Total locks: 2
  [Lock details...]

  === Savings Account ===
  Savings Balance: 5.25 USDT
  Savings Unlock Time: 12/13/2025, 3:30:00 PM
  Savings Status: Locked
  ```

- **Withdraw savings**: Withdraw your accumulated savings (available every 30 days).
  ```bash
  Enter command: withdraw-savings
  ```
  Output:
  ```bash
  Withdrawing savings...
  Withdraw transaction hash: 0xmno345...
  Savings successfully withdrawn!
  ```

### Key Features Explained

1. **Custom Lock Duration**: You can now lock tokens for any number of days you choose, not just a fixed 30 days.

2. **Multiple Locks**: Create multiple separate lock instances, each with its own amount, duration, and interest rate.

3. **Daily Interest**: Each lock generates interest daily based on the rate you specify when creating the lock.
   - Interest is calculated in basis points (100 = 1%)
   - You can claim interest at any time without unlocking your principal

4. **Automatic Savings**: 
   - 5% of all earned interest automatically goes to a savings account
   - Savings unlock every 30 days
   - After withdrawal, savings automatically lock for another 30 days
   - You can re-lock withdrawn savings by creating a new lock

5. **Lock Management**:
   - Track all locks with the `list` command
   - Each lock shows its status, amount, interest rate, and pending interest
   - Withdraw from specific locks after they unlock

### Step 5: Modify for Other EVM-Compatible Chains

To use this code with other EVM-compatible chains:

1. Change the `RPC_URL` in the `.env` file to the URL of your desired chain's RPC endpoint.
2. Deploy the updated `TokenLock` contract to your target chain and update the `LOCK_ADDRESS` in your `.env` file.
3. Ensure that the `USDT_CONTRACT_ADDRESS` is valid for the network you're using.

### Smart Contract Updates

The smart contract has been enhanced with:
- Support for multiple locks per user
- Customizable lock duration
- Daily interest calculation and claiming
- Automatic 5% savings allocation
- 30-day savings unlock period

### Conclusion

You now have a fully functional CLI tool with advanced features to interact with a smart contract that locks tokens, generates daily interest, and manages savings. The system provides flexibility to manage multiple locks simultaneously while automatically building a savings reserve.
