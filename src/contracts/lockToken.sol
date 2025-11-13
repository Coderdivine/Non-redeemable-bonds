// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenLock {
    IERC20 public usdtToken;
    
    // Structure to store lock information
    struct Lock {
        uint256 amount;
        uint256 lockTime;
        uint256 unlockTime;
        uint256 dailyInterestRate; // in basis points (100 = 1%)
        uint256 lastClaimTime;
        bool active;
    }
    
    // Multiple locks per user
    mapping(address => Lock[]) public userLocks;
    
    // Savings account - 5% of daily interest goes here
    mapping(address => uint256) public savingsBalance;
    mapping(address => uint256) public savingsUnlockTime;

    constructor(address _usdtAddress) {
        usdtToken = IERC20(_usdtAddress);
    }

    // Lock tokens with custom duration and interest rate
    function lockTokens(uint256 amount, uint256 durationInDays, uint256 dailyInterestRate) external {
        require(amount > 0, "Amount must be greater than 0");
        require(durationInDays > 0, "Duration must be greater than 0");
        require(dailyInterestRate > 0 && dailyInterestRate <= 1000, "Interest rate must be between 0.01% and 10%");
        require(usdtToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        Lock memory newLock = Lock({
            amount: amount,
            lockTime: block.timestamp,
            unlockTime: block.timestamp + (durationInDays * 1 days),
            dailyInterestRate: dailyInterestRate,
            lastClaimTime: block.timestamp,
            active: true
        });
        
        userLocks[msg.sender].push(newLock);
        
        // Initialize savings unlock time if not set
        if (savingsUnlockTime[msg.sender] == 0) {
            savingsUnlockTime[msg.sender] = block.timestamp + 30 days;
        }
    }

    // Calculate pending interest for a specific lock
    function getPendingInterest(address user, uint256 lockIndex) public view returns (uint256 mainInterest, uint256 savingsInterest) {
        require(lockIndex < userLocks[user].length, "Invalid lock index");
        Lock memory lock = userLocks[user][lockIndex];
        
        if (!lock.active) {
            return (0, 0);
        }
        
        uint256 daysPassed = (block.timestamp - lock.lastClaimTime) / 1 days;
        if (daysPassed == 0) {
            return (0, 0);
        }
        
        // Calculate total daily interest
        uint256 totalInterest = (lock.amount * lock.dailyInterestRate * daysPassed) / 10000;
        
        // 5% goes to savings
        savingsInterest = (totalInterest * 5) / 100;
        mainInterest = totalInterest - savingsInterest;
        
        return (mainInterest, savingsInterest);
    }

    // Claim interest for a specific lock
    function claimInterest(uint256 lockIndex) external {
        require(lockIndex < userLocks[msg.sender].length, "Invalid lock index");
        Lock storage lock = userLocks[msg.sender][lockIndex];
        require(lock.active, "Lock is not active");
        
        (uint256 mainInterest, uint256 savingsInterest) = getPendingInterest(msg.sender, lockIndex);
        require(mainInterest > 0 || savingsInterest > 0, "No interest to claim");
        
        lock.lastClaimTime = block.timestamp;
        savingsBalance[msg.sender] += savingsInterest;
        
        if (mainInterest > 0) {
            require(usdtToken.transfer(msg.sender, mainInterest), "Transfer failed");
        }
    }

    // Withdraw tokens from a specific lock
    function withdrawTokens(uint256 lockIndex) external {
        require(lockIndex < userLocks[msg.sender].length, "Invalid lock index");
        Lock storage lock = userLocks[msg.sender][lockIndex];
        
        require(lock.active, "Lock is not active");
        require(block.timestamp >= lock.unlockTime, "Tokens are still locked");
        require(lock.amount > 0, "No tokens to withdraw");
        
        // Claim any pending interest first
        (uint256 mainInterest, uint256 savingsInterest) = getPendingInterest(msg.sender, lockIndex);
        if (mainInterest > 0 || savingsInterest > 0) {
            savingsBalance[msg.sender] += savingsInterest;
        }
        
        uint256 totalToTransfer = lock.amount + mainInterest;
        lock.active = false;
        lock.amount = 0;
        
        require(usdtToken.transfer(msg.sender, totalToTransfer), "Transfer failed");
    }

    // Withdraw savings (unlocked every 30 days)
    function withdrawSavings() external {
        require(block.timestamp >= savingsUnlockTime[msg.sender], "Savings are still locked");
        uint256 amount = savingsBalance[msg.sender];
        require(amount > 0, "No savings to withdraw");
        
        savingsBalance[msg.sender] = 0;
        savingsUnlockTime[msg.sender] = block.timestamp + 30 days;
        
        require(usdtToken.transfer(msg.sender, amount), "Transfer failed");
    }

    // Get total number of locks for a user
    function getUserLocksCount(address user) external view returns (uint256) {
        return userLocks[user].length;
    }

    // Get lock details
    function getLockDetails(address user, uint256 lockIndex) external view returns (
        uint256 amount,
        uint256 lockTime,
        uint256 unlockTime,
        uint256 dailyInterestRate,
        uint256 lastClaimTime,
        bool active
    ) {
        require(lockIndex < userLocks[user].length, "Invalid lock index");
        Lock memory lock = userLocks[user][lockIndex];
        return (
            lock.amount,
            lock.lockTime,
            lock.unlockTime,
            lock.dailyInterestRate,
            lock.lastClaimTime,
            lock.active
        );
    }
    
    // Get all active locks for a user
    function getActiveLocks(address user) external view returns (uint256[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < userLocks[user].length; i++) {
            if (userLocks[user][i].active) {
                count++;
            }
        }
        
        uint256[] memory activeLockIndices = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 0; i < userLocks[user].length; i++) {
            if (userLocks[user][i].active) {
                activeLockIndices[index] = i;
                index++;
            }
        }
        
        return activeLockIndices;
    }
}
