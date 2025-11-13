---

# Enhanced TokenLock CLI: Daily Withdrawal with Automatic Savings

This project allows you to interact with a smart contract for locking USDT tokens on the AssetChain network with the following features:
- **Custom lock duration** - Specify how long you want to lock your funds
- **Multiple locks** - Create and manage multiple lock instances simultaneously
- **Daily withdrawals** - Withdraw a fixed percentage of your locked funds daily
- **Automatic savings** - 5% of locked amount and all withdrawals automatically goes to savings that unlocks every 30 days

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
   - **lock [amount] [days] [withdrawal_rate]**: Lock tokens with custom duration and daily withdrawal rate.
   - **list**: List all your lock instances.
   - **withdraw-daily [lock_index]**: Withdraw daily allowance from a specific lock.
   - **withdraw [lock_index]**: Withdraw remaining tokens from a specific lock (after unlock time).
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

- **Lock tokens with custom duration and daily withdrawal rate**: Lock 100 USDT for 30 days with 7% daily withdrawal rate.
  ```bash
  Enter command: lock 100 30 700
  ```
  Note: Withdrawal rate is in basis points (100 = 1%, 700 = 7%, 1000 = 10%)
  
  Output:
  ```bash
  Locking 100 USDT for 30 days with 7% daily withdrawal rate...
  Note: 5% of locked amount (5 USDT) goes to savings immediately.
  Lock transaction hash: 0xdef456...
  Successfully locked 100 USDT!
  Locked amount available for daily withdrawals: 95 USDT
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
  Original Locked Amount: 95.0 USDT
  Total Withdrawn: 13.3 USDT
  Remaining Balance: 81.7 USDT
  Daily Withdrawal Rate: 7%
  Locked at: 11/13/2025, 3:30:00 PM
  Unlocks at: 12/13/2025, 3:30:00 PM
  Available to Withdraw Now: 6.65 USDT
    - You receive: 6.3175 USDT
    - Goes to savings (5%): 0.3325 USDT

  --- Lock #1 ---
  Status: Unlocked (Ready to withdraw)
  Original Locked Amount: 47.5 USDT
  Total Withdrawn: 14.25 USDT
  Remaining Balance: 33.25 USDT
  Daily Withdrawal Rate: 10%
  Locked at: 10/15/2025, 2:00:00 PM
  Unlocks at: 11/14/2025, 2:00:00 PM
  Available to Withdraw Now: 14.25 USDT
    - You receive: 13.5375 USDT
    - Goes to savings (5%): 0.7125 USDT
  ```

- **Withdraw daily allowance**: Withdraw daily allowance from a specific lock.
  ```bash
  Enter command: withdraw-daily 0
  ```
  Output:
  ```bash
  Withdrawing daily allowance from lock #0...
  Withdrawal transaction hash: 0xghi789...
  Daily withdrawal successful!
  Note: 5% of the withdrawal was added to your savings.
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

1. **Custom Lock Duration**: You can lock tokens for any number of days you choose.

2. **Multiple Locks**: Create multiple separate lock instances, each with its own amount, duration, and withdrawal rate.

3. **Daily Withdrawals**: Each lock allows you to withdraw a percentage of your locked funds daily based on the rate you specify when creating the lock.
   - Withdrawal rate is specified in basis points (100 = 1%, 700 = 7%)
   - You can withdraw your daily allowance at any time
   - Example: Lock $100 with 7% daily rate = withdraw $7 daily (95% to you, 5% to savings)

4. **Automatic Savings**: 
   - 5% of your locked amount goes to savings immediately when you create a lock
   - 5% of all daily withdrawals automatically goes to a savings account
   - Savings unlock every 30 days
   - After withdrawal, savings automatically lock for another 30 days

5. **Lock Management**:
   - Track all locks with the `list` command
   - Each lock shows its status, amount, withdrawal rate, and available withdrawal
   - Withdraw remaining balance from specific locks after they unlock
   - The lock period protects your principal from being fully withdrawn immediately

### Step 5: Modify for Other EVM-Compatible Chains

To use this code with other EVM-compatible chains:

1. Change the `RPC_URL` in the `.env` file to the URL of your desired chain's RPC endpoint.
2. Deploy the updated `TokenLock` contract to your target chain and update the `LOCK_ADDRESS` in your `.env` file.
3. Ensure that the `USDT_CONTRACT_ADDRESS` is valid for the network you're using.

### Smart Contract Updates

The smart contract has been enhanced with:
- Support for multiple locks per user
- Customizable lock duration
- Daily withdrawal allowance based on specified percentage
- Automatic 5% savings allocation on lock creation and every withdrawal
- 30-day savings unlock period
- Tracking of total withdrawn amounts per lock

### Conclusion

You now have a fully functional CLI tool to interact with a smart contract that locks tokens with daily withdrawal capabilities and automatic savings. The system allows you to:
- Lock funds with a specified daily withdrawal percentage (e.g., 7% daily)
- Withdraw your daily allowance as needed
- Automatically build savings from 5% of all activities
- Manage multiple locks simultaneously
