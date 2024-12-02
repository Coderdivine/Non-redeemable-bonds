require("dotenv").config();
const privateKey = process.env.PRIVATE_KEY;
const walletAddress = process.env.WALLET_ADDRESS;
const rpcUrl = process.env.RPC_URL;
const usdtContractAddress = process.env.USDT_CONTRACT_ADDRESS;
const lockAddress = process.env.LOCK_ADDRESS;
const usdtAbi = require("./abi.json");
const lockAbi =  require("./lock-abi.json");



module.exports = {
    privateKey,
    walletAddress,
    rpcUrl,
    usdtContractAddress,
    usdtAbi,
    lockAddress,
    lockAbi
}