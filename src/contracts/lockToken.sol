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
        uint256 dailyWithdrawalRate; // in basis points (100 = 1%)
        uint256 lastWithdrawTime;
        uint256 totalWithdrawn;
        bool active;
    }
    
    // Multiple locks per user
    mapping(address => Lock[]) public userLocks;
    
    // Savings account - 5% of withdrawals go here
    mapping(address => uint256) public savingsBalance;
    mapping(address => uint256) public savingsUnlockTime;

    constructor(address _usdtAddress) {
        usdtToken = IERC20(_usdtAddress);
    }

    // Lock tokens with custom duration and daily withdrawal percentage
    function lockTokens(uint256 amount, uint256 durationInDays, uint256 dailyWithdrawalRate) external {
        require(amount > 0, "Amount must be greater than 0");
        require(durationInDays > 0, "Duration must be greater than 0");
        require(dailyWithdrawalRate > 0 && dailyWithdrawalRate <= 10000, "Withdrawal rate must be between 0.01% and 100%");
        require(usdtToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        // Automatically deduct 5% for savings on lock
        uint256 savingsAmount = (amount * 5) / 100;
        uint256 lockedAmount = amount - savingsAmount;
        
        Lock memory newLock = Lock({
            amount: lockedAmount,
            lockTime: block.timestamp,
            unlockTime: block.timestamp + (durationInDays * 1 days),
            dailyWithdrawalRate: dailyWithdrawalRate,
            lastWithdrawTime: block.timestamp,
            totalWithdrawn: 0,
            active: true
        });
        
        userLocks[msg.sender].push(newLock);
        savingsBalance[msg.sender] += savingsAmount;
        
        // Initialize savings unlock time if not set
        if (savingsUnlockTime[msg.sender] == 0) {
            savingsUnlockTime[msg.sender] = block.timestamp + 30 days;
        }
    }

    // Calculate available daily withdrawal for a specific lock
    function getAvailableWithdrawal(address user, uint256 lockIndex) public view returns (uint256 mainWithdrawal, uint256 savingsWithdrawal) {
        require(lockIndex < userLocks[user].length, "Invalid lock index");
        Lock memory lock = userLocks[user][lockIndex];
        
        if (!lock.active) {
            return (0, 0);
        }
        
        uint256 daysPassed = (block.timestamp - lock.lastWithdrawTime) / 1 days;
        if (daysPassed == 0) {
            return (0, 0);
        }
        
        // Calculate total withdrawable amount based on days passed
        uint256 totalWithdrawable = (lock.amount * lock.dailyWithdrawalRate * daysPassed) / 10000;
        
        // Ensure we don't withdraw more than remaining balance
        uint256 remainingBalance = lock.amount - lock.totalWithdrawn;
        if (totalWithdrawable > remainingBalance) {
            totalWithdrawable = remainingBalance;
        }
        
        // 5% goes to savings
        savingsWithdrawal = (totalWithdrawable * 5) / 100;
        mainWithdrawal = totalWithdrawable - savingsWithdrawal;
        
        return (mainWithdrawal, savingsWithdrawal);
    }

    // Withdraw daily allowance from a specific lock
    function withdrawDaily(uint256 lockIndex) external {
        require(lockIndex < userLocks[msg.sender].length, "Invalid lock index");
        Lock storage lock = userLocks[msg.sender][lockIndex];
        require(lock.active, "Lock is not active");
        
        (uint256 mainWithdrawal, uint256 savingsWithdrawal) = getAvailableWithdrawal(msg.sender, lockIndex);
        require(mainWithdrawal > 0 || savingsWithdrawal > 0, "No withdrawal available yet");
        
        lock.lastWithdrawTime = block.timestamp;
        lock.totalWithdrawn += mainWithdrawal + savingsWithdrawal;
        savingsBalance[msg.sender] += savingsWithdrawal;
        
        // Check if lock is fully withdrawn
        if (lock.totalWithdrawn >= lock.amount) {
            lock.active = false;
        }
        
        if (mainWithdrawal > 0) {
            require(usdtToken.transfer(msg.sender, mainWithdrawal), "Transfer failed");
        }
    }

    // Withdraw remaining tokens from a specific lock after unlock time
    function withdrawTokens(uint256 lockIndex) external {
        require(lockIndex < userLocks[msg.sender].length, "Invalid lock index");
        Lock storage lock = userLocks[msg.sender][lockIndex];
        
        require(lock.active, "Lock is not active");
        require(block.timestamp >= lock.unlockTime, "Tokens are still locked");
        
        uint256 remainingAmount = lock.amount - lock.totalWithdrawn;
        require(remainingAmount > 0, "No tokens to withdraw");
        
        // Calculate any pending daily withdrawals first
        (uint256 mainWithdrawal, uint256 savingsWithdrawal) = getAvailableWithdrawal(msg.sender, lockIndex);
        savingsBalance[msg.sender] += savingsWithdrawal;
        
        // Deduct the 5% savings from remaining amount
        uint256 savingsFromRemaining = (remainingAmount * 5) / 100;
        uint256 toTransfer = remainingAmount - savingsFromRemaining + mainWithdrawal;
        
        savingsBalance[msg.sender] += savingsFromRemaining;
        lock.active = false;
        lock.totalWithdrawn = lock.amount;
        
        require(usdtToken.transfer(msg.sender, toTransfer), "Transfer failed");
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
        uint256 dailyWithdrawalRate,
        uint256 lastWithdrawTime,
        uint256 totalWithdrawn,
        bool active
    ) {
        require(lockIndex < userLocks[user].length, "Invalid lock index");
        Lock memory lock = userLocks[user][lockIndex];
        return (
            lock.amount,
            lock.lockTime,
            lock.unlockTime,
            lock.dailyWithdrawalRate,
            lock.lastWithdrawTime,
            lock.totalWithdrawn,
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
