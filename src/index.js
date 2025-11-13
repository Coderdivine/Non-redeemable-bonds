require('dotenv').config();
const readline = require('readline-sync');
const { ethers } = require('ethers');
const { rpcUrl, privateKey, usdtContractAddress, usdtAbi, lockAbi, lockAddress } = require('./configs');
const provider = new ethers.JsonRpcProvider(rpcUrl);
const wallet = new ethers.Wallet(privateKey, provider);
const contractAddress = lockAddress;
const usdtAddress = usdtContractAddress;
const tokenLockABI = lockAbi;
const usdtABI = usdtAbi;

const tokenLockContract = new ethers.Contract(contractAddress, tokenLockABI, wallet);
const usdtContract = new ethers.Contract(usdtAddress, usdtABI, wallet);


async function getDecimals(contract) {
    const dec = await contract.decimals();
    return dec;
}

async function approveTokens(amount) {
    try {
        const dec = await getDecimals(usdtContract);
        const approveAmount = ethers.parseUnits(amount, dec);
        console.log(`Approving ${amount} USDT for TokenLock contract...`);
        const tx = await usdtContract.approve(contractAddress, approveAmount);
        console.log("Approval transaction hash:", tx.hash);
        await tx.wait();
        console.log("Approval successful!");
    } catch (error) {
        console.error("Error approving tokens:", error.message);
    }
}

async function lockTokens(amount, days, withdrawalRate) {
    try {
        const dec = await getDecimals(usdtContract);
        const lockAmount = ethers.parseUnits(amount, dec);
        console.log(`Locking ${amount} USDT for ${days} days with ${withdrawalRate/100}% daily withdrawal rate...`);
        console.log(`Note: 5% of locked amount (${amount * 0.05} USDT) goes to savings immediately.`);
        const tx = await tokenLockContract.lockTokens(lockAmount, days, withdrawalRate);
        console.log("Lock transaction hash:", tx.hash);
        await tx.wait();
        console.log(`Successfully locked ${amount} USDT!`);
        console.log(`Locked amount available for daily withdrawals: ${amount * 0.95} USDT`);
    } catch (error) {
        console.error("Error locking tokens:", error.message);
    }
}

async function withdrawTokens(lockIndex) {
    try {
        console.log(`Withdrawing tokens from lock #${lockIndex}...`);
        const tx = await tokenLockContract.withdrawTokens(lockIndex);
        console.log("Withdraw transaction hash:", tx.hash);
        await tx.wait();
        console.log("Tokens successfully withdrawn!");
    } catch (error) {
        console.error("Error withdrawing tokens:", error.message);
    }
}

async function withdrawDaily(lockIndex) {
    try {
        console.log(`Withdrawing daily allowance from lock #${lockIndex}...`);
        const tx = await tokenLockContract.withdrawDaily(lockIndex);
        console.log("Withdrawal transaction hash:", tx.hash);
        await tx.wait();
        console.log("Daily withdrawal successful!");
        console.log("Note: 5% of the withdrawal was added to your savings.");
    } catch (error) {
        console.error("Error withdrawing daily allowance:", error.message);
    }
}

async function withdrawSavings() {
    try {
        console.log("Withdrawing savings...");
        const tx = await tokenLockContract.withdrawSavings();
        console.log("Withdraw transaction hash:", tx.hash);
        await tx.wait();
        console.log("Savings successfully withdrawn!");
    } catch (error) {
        console.error("Error withdrawing savings:", error.message);
    }
}

async function listLocks() {
    try {
        const locksCount = await tokenLockContract.getUserLocksCount(wallet.address);
        console.log(`\nTotal locks: ${locksCount}`);
        
        if (locksCount == 0) {
            console.log("No locks found.");
            return;
        }

        const decimals = await getDecimals(usdtContract);
        
        for (let i = 0; i < locksCount; i++) {
            const [amount, lockTime, unlockTime, dailyWithdrawalRate, lastWithdrawTime, totalWithdrawn, active] = 
                await tokenLockContract.getLockDetails(wallet.address, i);
            
            const lockTimeDate = new Date(Number(lockTime) * 1000);
            const unlockTimeDate = new Date(Number(unlockTime) * 1000);
            const now = Date.now();
            const isUnlocked = now >= Number(unlockTime) * 1000;
            
            console.log(`\n--- Lock #${i} ---`);
            console.log(`Status: ${active ? (isUnlocked ? 'Unlocked (Ready to withdraw)' : 'Active (Locked)') : 'Fully Withdrawn'}`);
            console.log(`Original Locked Amount: ${ethers.formatUnits(amount, decimals)} USDT`);
            console.log(`Total Withdrawn: ${ethers.formatUnits(totalWithdrawn, decimals)} USDT`);
            console.log(`Remaining Balance: ${ethers.formatUnits(amount - totalWithdrawn, decimals)} USDT`);
            console.log(`Daily Withdrawal Rate: ${Number(dailyWithdrawalRate)/100}%`);
            console.log(`Locked at: ${lockTimeDate.toLocaleString()}`);
            console.log(`Unlocks at: ${unlockTimeDate.toLocaleString()}`);
            
            if (active) {
                const [mainWithdrawal, savingsWithdrawal] = await tokenLockContract.getAvailableWithdrawal(wallet.address, i);
                const totalAvailable = mainWithdrawal + savingsWithdrawal;
                console.log(`Available to Withdraw Now: ${ethers.formatUnits(totalAvailable, decimals)} USDT`);
                console.log(`  - You receive: ${ethers.formatUnits(mainWithdrawal, decimals)} USDT`);
                console.log(`  - Goes to savings (5%): ${ethers.formatUnits(savingsWithdrawal, decimals)} USDT`);
            }
        }
    } catch (error) {
        console.error("Error listing locks:", error.message);
    }
}

async function checkStatus() {
    try {
        await listLocks();
        
        // Show savings status
        console.log("\n=== Savings Account ===");
        const savingsBalance = await tokenLockContract.savingsBalance(wallet.address);
        const savingsUnlockTime = await tokenLockContract.savingsUnlockTime(wallet.address);
        const decimals = await getDecimals(usdtContract);
        
        console.log(`Savings Balance: ${ethers.formatUnits(savingsBalance, decimals)} USDT`);
        
        if (Number(savingsUnlockTime) > 0) {
            const savingsUnlockDate = new Date(Number(savingsUnlockTime) * 1000);
            const now = Date.now();
            const isUnlocked = now >= Number(savingsUnlockTime) * 1000;
            console.log(`Savings Unlock Time: ${savingsUnlockDate.toLocaleString()}`);
            console.log(`Savings Status: ${isUnlocked ? 'Unlocked (Ready to withdraw)' : 'Locked'}`);
        } else {
            console.log("Savings unlock time: Not set (will be set when first lock is created)");
        }
    } catch (error) {
        console.error("Error checking status:", error.message);
    }
}

async function showHelp() {
    console.log("\n=== Available Commands ===");
    console.log("approve [amount] - Approve USDT for the TokenLock contract");
    console.log("lock [amount] [days] [withdrawal_rate] - Lock tokens with custom duration and daily withdrawal rate");
    console.log("  Example: lock 100 30 700 (lock 100 USDT for 30 days with 7% daily withdrawal rate)");
    console.log("  Withdrawal rate is in basis points (100 = 1%, 700 = 7%)");
    console.log("  Note: 5% of locked amount goes to savings immediately");
    console.log("list - List all your locks");
    console.log("withdraw-daily [lock_index] - Withdraw daily allowance from a specific lock");
    console.log("withdraw [lock_index] - Withdraw remaining tokens from a specific lock (after unlock time)");
    console.log("withdraw-savings - Withdraw your savings (unlocked every 30 days)");
    console.log("status - Check status of all locks and savings");
    console.log("help - Show this help message");
    console.log("==========================\n");
}


const command = readline.question("Enter command: ").trim().toLowerCase();

(async () => {
    const parts = command.split(" ");
    const cmd = parts[0];
    
    if (cmd === "approve") {
        const amount = parts[1];
        if (!amount) {
            console.log("Please specify an amount to approve.");
            console.log("Usage: approve [amount]");
            return;
        }
        await approveTokens(amount);
    } else if (cmd === "lock") {
        const amount = parts[1];
        const days = parts[2];
        const withdrawalRate = parts[3];
        if (!amount || !days || !withdrawalRate) {
            console.log("Please specify amount, duration (days), and daily withdrawal rate.");
            console.log("Usage: lock [amount] [days] [withdrawal_rate]");
            console.log("Example: lock 100 30 700 (lock 100 USDT for 30 days with 7% daily withdrawal rate)");
            console.log("Withdrawal rate is in basis points (100 = 1%, 700 = 7%)");
            return;
        }
        await lockTokens(amount, days, withdrawalRate);
    } else if (cmd === "withdraw") {
        const lockIndex = parts[1];
        if (lockIndex === undefined) {
            console.log("Please specify the lock index to withdraw from.");
            console.log("Usage: withdraw [lock_index]");
            console.log("Use 'list' command to see your locks and their indices.");
            return;
        }
        await withdrawTokens(lockIndex);
    } else if (cmd === "withdraw-daily") {
        const lockIndex = parts[1];
        if (lockIndex === undefined) {
            console.log("Please specify the lock index to withdraw daily allowance from.");
            console.log("Usage: withdraw-daily [lock_index]");
            return;
        }
        await withdrawDaily(lockIndex);
    } else if (cmd === "withdraw-savings") {
        await withdrawSavings();
    } else if (cmd === "list") {
        await listLocks();
    } else if (cmd === "status") {
        await checkStatus();
    } else if (cmd === "help") {
        await showHelp();
    } else {
        console.log("Invalid command. Type 'help' to see available commands.");
    }
})();
