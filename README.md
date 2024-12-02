---

# TokenLock CLI: Interaction with Smart Contract on AssetChain

This project allows you to interact with a smart contract for locking and redeeming USDT tokens on the AssetChain network. You can approve, lock, redeem tokens, and check the status of your locked funds using simple CLI commands.

### Prerequisites

Before running the application, you need the following installed:

- Node.js (v16 or above)
- `npm` (Node Package Manager)
- `.env` file with appropriate configurations

### Step 1: Generate New Private Key and Address

To start, you’ll need to generate a new private key and wallet address. This can be done using the `generateKeys.js` script.

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
   - **lock [amount]**: Lock a specified amount of USDT for 30 days.
   - **redeem [amount]**: Redeem a specified amount of USDT (if it’s unlocked).
   - **status**: Check the locked amount and lock time status.

   Example usage:
   ```bash
   Enter command (approve, lock [amount], redeem, status): approve 100
   ```

### Example Commands

- **Approve tokens**: Approve a specified amount of USDT to be used by the TokenLock contract.
  ```bash
  Enter command (approve, lock [amount], redeem, status): approve 100
  ```
  Output:
  ```bash
  Approving 100 USDT for TokenLock contract...
  Approval transaction hash: 0xabc123...
  Approval of 100 USDT successful!
  ```

- **Lock tokens**: Lock a specified amount of USDT for 30 days.
  ```bash
  Enter command (approve, lock [amount], redeem, status): lock 100
  ```
  Output:
  ```bash
  Locking 100 USDT for 30 days...
  Locking successful!
  ```

- **Redeem tokens**: Redeem a specified amount of USDT (after the lock period expires).
  ```bash
  Enter command (approve, lock [amount], redeem, status): redeem 100
  ```
  Output:
  ```bash
  Redeeming 100 USDT...
  Redeem successful!
  ```

- **Check status**: Check the locked amount and lock time status.
  ```bash
  Enter command (approve, lock [amount], redeem, status): status
  ```
  Output:
  ```bash
  Locked Amount: 100 USDT
  Lock Time Expiry: 12/02/2024, 02:45:30 PM
  ```

### Step 5: Modify for Other EVM-Compatible Chains

To use this code with other EVM-compatible chains:

1. Change the `RPC_URL` in the `.env` file to the URL of your desired chain's RPC endpoint.
2. Ensure that the `USDT_CONTRACT_ADDRESS` and `LOCK_ADDRESS` are valid for the network you're using. You may need to deploy the `TokenLock` contract on a different chain if it’s not already deployed.

### Conclusion

You now have a fully functional CLI tool to interact with a smart contract that locks and redeems USDT tokens. Use the `approve`, `lock`, `redeem`, and `status` commands to manage your tokens on AssetChain or any compatible EVM chain.