# System Flow Diagram

## Lock Creation Flow
```
User → approve(USDT) → TokenLock Contract
         ↓
User → lock(amount, days, rate) → TokenLock Contract
         ↓
    Transfer USDT from User to Contract
         ↓
    Create Lock struct with:
      - amount
      - lockTime (now)
      - unlockTime (now + days)
      - dailyInterestRate
      - lastClaimTime (now)
      - active (true)
         ↓
    Initialize savings unlock if first lock
         ↓
    Lock stored in userLocks[user] array
```

## Interest Claim Flow
```
User → claim(lockIndex) → TokenLock Contract
         ↓
    Calculate days elapsed since lastClaimTime
         ↓
    Calculate total interest = (amount × rate × days) / 10000
         ↓
    Split interest:
      - mainInterest = 95% → Transfer to User
      - savingsInterest = 5% → Add to savingsBalance
         ↓
    Update lastClaimTime to now
```

## Withdrawal Flow
```
User → withdraw(lockIndex) → TokenLock Contract
         ↓
    Check: block.timestamp >= unlockTime?
         ↓
    Calculate any pending interest
         ↓
    Split pending interest (95%/5%)
         ↓
    Set lock.active = false
    Set lock.amount = 0
         ↓
    Transfer (original amount + 95% interest) to User
    Add 5% interest to savingsBalance
```

## Savings Flow
```
User → withdraw-savings → TokenLock Contract
         ↓
    Check: block.timestamp >= savingsUnlockTime?
         ↓
    Transfer savingsBalance to User
         ↓
    Set savingsBalance = 0
    Set savingsUnlockTime = now + 30 days
```

## Multiple Locks Example
```
User has 3 locks:

Lock #0: 100 USDT, 30 days, 0.5% daily
  Status: Active (Day 15)
  Pending Interest: 7.5 USDT (95% claimable)
  Pending Savings: 0.395 USDT (5%)

Lock #1: 50 USDT, 60 days, 1% daily  
  Status: Active (Day 45)
  Pending Interest: 22.5 USDT (95% claimable)
  Pending Savings: 1.185 USDT (5%)

Lock #2: 200 USDT, 90 days, 0.3% daily
  Status: Unlocked (Day 92)
  Total Value: 200 + 52.44 = 252.44 USDT
  Savings Accumulated: 2.76 USDT

Total Savings Balance: 4.34 USDT
Savings Unlock: In 5 days
```

## Interest Accumulation Over Time
```
Day 0:  Lock created (100 USDT, 1% daily)
Day 1:  Interest: 1 USDT (0.95 claimable, 0.05 savings)
Day 5:  Interest: 5 USDT (4.75 claimable, 0.25 savings)
Day 10: Interest: 10 USDT (9.50 claimable, 0.50 savings)
Day 30: Interest: 30 USDT (28.50 claimable, 1.50 savings) + Unlock

User can:
- Claim 28.50 USDT anytime
- Withdraw 100 USDT + 28.50 USDT after day 30
- Withdraw 1.50 USDT savings after day 30
```

## Command Reference Quick View
```
┌─────────────────────────────────────────────────────────────┐
│                    TokenLock CLI Commands                   │
├─────────────────────────────────────────────────────────────┤
│ Setup                                                       │
│   approve [amount]          - Approve USDT for contract    │
│                                                             │
│ Lock Management                                             │
│   lock [amt] [days] [rate]  - Create new lock              │
│   list                      - View all locks               │
│   status                    - Detailed status + savings    │
│                                                             │
│ Interest & Withdrawal                                       │
│   claim [index]             - Claim interest from lock     │
│   withdraw [index]          - Withdraw from lock           │
│   withdraw-savings          - Withdraw savings pool        │
│                                                             │
│ Help                                                        │
│   help                      - Show all commands            │
└─────────────────────────────────────────────────────────────┘
```

## State Transitions
```
Lock States:
  CREATED → ACTIVE → UNLOCKED → WITHDRAWN

Savings States:
  EMPTY → ACCUMULATING → UNLOCKED → WITHDRAWN → LOCKED (repeat)

Each lock independently cycles through states
Savings accumulate from all locks
```

## Key Benefits
1. **Flexibility**: Custom lock durations and interest rates
2. **Scalability**: Multiple concurrent locks per user
3. **Liquidity**: Claim interest without unlocking principal
4. **Savings**: Automatic 5% allocation builds reserve
5. **Simplicity**: Clean CLI interface for all operations
