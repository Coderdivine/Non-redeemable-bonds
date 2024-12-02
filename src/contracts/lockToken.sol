// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}

contract TokenLock {
    IERC20 public usdtToken;
    mapping(address => uint256) public lockTime;
    mapping(address => uint256) public lockedAmount;

    constructor(address _usdtAddress) {
        usdtToken = IERC20(_usdtAddress);
    }

    function lockTokens(uint256 amount) external {
        require(amount > 0, "Amount must be greater than 0");
        require(usdtToken.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        lockedAmount[msg.sender] += amount;
        lockTime[msg.sender] = block.timestamp + 10 minutes;
        // block.timestamp + 30 days;
    }

    function withdrawTokens() external {
        require(block.timestamp >= lockTime[msg.sender], "Tokens are still locked");
        uint256 amount = lockedAmount[msg.sender];
        require(amount > 0, "No tokens to withdraw");

        lockedAmount[msg.sender] = 0;
        lockTime[msg.sender] = 0;

        require(usdtToken.transfer(msg.sender, amount), "Transfer failed");
    }
}
