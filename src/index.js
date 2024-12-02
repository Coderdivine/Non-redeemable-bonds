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

async function lockTokens(amount) {
    try {
        const dec = await getDecimals(usdtContract);
        const lockAmount = ethers.parseUnits(amount, dec);
        console.log(`Locking ${amount} USDT in the TokenLock contract...`);
        const tx = await tokenLockContract.lockTokens(lockAmount);
        console.log("Lock transaction hash:", tx.hash);
        await tx.wait();
        console.log(`Successfully locked ${amount} USDT!`);
    } catch (error) {
        console.error("Error locking tokens:", error.message);
    }
}

async function redeemTokens(amount) {
    try {
        if (amount) {
            console.error("Partial withdrawal is not supported in the contract. Ignoring amount...");
        }
        console.log("Redeeming all locked USDT...");
        const tx = await tokenLockContract.withdrawTokens();
        console.log("Redeem transaction hash:", tx.hash);
        await tx.wait();
        console.log("Tokens successfully redeemed!");
    } catch (error) {
        console.error("Error redeeming tokens:", error.message);
    }
}

async function checkStatus() {
    try {
        const lockedAmount = await tokenLockContract.lockedAmount(wallet.address);
        const lockTime = await tokenLockContract.lockTime(wallet.address);

        const decimals = await getDecimals(usdtContract);

        // Format the locked amount using the token's decimals
        console.log(`Locked Amount: ${ethers.formatUnits(lockedAmount, decimals)} USDT`);

        // Convert lockTime to a number for use with Date
        const lockTimeInMillis = Number(lockTime) * 1000;
        console.log(`Lock Time Expiry: ${new Date(lockTimeInMillis).toLocaleString()}`);
    } catch (error) {
        console.error("Error checking status:", error.message);
    }
}


const command = readline.question("Enter command (approve, lock [amount], redeem, status): ").trim().toLowerCase();

(async () => {
    if (command.startsWith("approve")) {
        const amount = command.split(" ")[1];
        if (!amount) {
            console.log("Please specify an amount to approve.");
            return;
        }
        await approveTokens(amount);
    } else if (command.startsWith("lock")) {
        const amount = command.split(" ")[1];
        if (!amount) {
            console.log("Please specify an amount to lock.");
            return;
        }
        await lockTokens(amount);
    } else if (command.startsWith("redeem")) {
        await redeemTokens();
    } else if (command.startsWith("status")) {
        await checkStatus();
    } else {
        console.log("Invalid command. Available commands: approve [amount], lock [amount], redeem, status");
    }
})();
