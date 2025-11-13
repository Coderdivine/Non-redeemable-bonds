# Quick Start Guide - Enhanced TokenLock System

## What's New? 🎉

Your fund locking system has been upgraded with powerful new features while keeping it simple!

### ✅ Custom Lock Duration
**Before**: Fixed 10 minutes (or 30 days)
**Now**: You choose exactly how many days!
```bash
lock 100 30 50    # Lock 100 USDT for 30 days
lock 50 60 100    # Lock 50 USDT for 60 days
lock 200 90 30    # Lock 200 USDT for 90 days
```

### ✅ Multiple Locks
**Before**: Only one lock at a time
**Now**: Create as many locks as you want!
```bash
lock 100 30 50    # First lock
lock 50 60 100    # Second lock (doesn't affect first)
lock 200 15 25    # Third lock (all independent)
list              # View all your locks
```

### ✅ Daily Interest
**Before**: No interest
**Now**: Earn daily interest on every lock!
```bash
# Lock 100 USDT for 30 days at 0.5% daily interest
lock 100 30 50

# After 10 days: 5 USDT interest
# After 20 days: 10 USDT interest
# After 30 days: 15 USDT interest

claim 0           # Claim interest without unlocking!
```

### ✅ Automatic Savings
**Before**: No savings feature
**Now**: 5% of all interest goes to savings!
```bash
# Earn 10 USDT interest:
# - 9.5 USDT → You can claim immediately
# - 0.5 USDT → Goes to savings automatically

# After 30 days, withdraw savings:
withdraw-savings
```

## How to Use It

### Step 1: Approve USDT
```bash
node src/index.js
> approve 1000
```

### Step 2: Create Your First Lock
```bash
node src/index.js
> lock 100 30 50
```
This locks 100 USDT for 30 days with 0.5% daily interest.

**Interest Rate Guide:**
- 50 = 0.5% daily
- 100 = 1% daily
- 10 = 0.1% daily
- 200 = 2% daily

### Step 3: View Your Locks
```bash
node src/index.js
> list
```
Shows all locks with status, interest earned, and unlock times.

### Step 4: Claim Interest (Anytime!)
```bash
node src/index.js
> claim 0
```
Claims interest from lock #0 without unlocking the principal.

### Step 5: Withdraw When Unlocked
```bash
node src/index.js
> withdraw 0
```
Withdraws your principal + any remaining interest from lock #0.

### Step 6: Check Everything
```bash
node src/index.js
> status
```
Shows all locks AND your savings balance.

## Example Scenario

**Day 1**: Create 3 locks
```bash
lock 100 30 50     # Lock #0
lock 50 60 100     # Lock #1  
lock 200 15 25     # Lock #2
```

**Day 5**: Check status
```bash
status
# Shows pending interest for each lock
# Shows savings accumulating
```

**Day 10**: Claim some interest
```bash
claim 0    # Claim from first lock
claim 1    # Claim from second lock
```

**Day 15**: Lock #2 unlocks
```bash
withdraw 2    # Get principal + interest from lock #2
```

**Day 30**: Savings unlock!
```bash
withdraw-savings    # Get your accumulated savings
```

**Day 30**: Lock #0 unlocks
```bash
withdraw 0    # Get principal + any unclaimed interest
```

## Important Notes

📌 **Interest Rates**: Use basis points (100 = 1%, 50 = 0.5%)

📌 **Savings**: Automatically accumulate 5% of all interest

📌 **Multiple Locks**: Each lock is independent - manage them separately

📌 **Claim vs Withdraw**: 
   - `claim` = Get interest only (keep lock active)
   - `withdraw` = Get everything (closes the lock)

📌 **Savings Unlock**: Every 30 days from your first lock

## All Commands Reference

| Command | Description | Example |
|---------|-------------|---------|
| `approve [amt]` | Approve USDT | `approve 1000` |
| `lock [amt] [days] [rate]` | Create lock | `lock 100 30 50` |
| `list` | View all locks | `list` |
| `status` | Full status + savings | `status` |
| `claim [index]` | Claim interest | `claim 0` |
| `withdraw [index]` | Withdraw from lock | `withdraw 0` |
| `withdraw-savings` | Withdraw savings | `withdraw-savings` |
| `help` | Show help | `help` |

## Before You Start

⚠️ **Important**: You need to deploy the new contract first!

1. Deploy `src/contracts/lockToken.sol` to your blockchain
2. Update `LOCK_ADDRESS` in your `.env` file
3. Make sure you have USDT and gas tokens
4. Test with small amounts first!

## Need Help?

- Check `README.md` for detailed explanations
- Check `IMPLEMENTATION_SUMMARY.md` for technical details
- Check `SYSTEM_FLOW.md` for flow diagrams

## Ready to Go! 🚀

All your requested features are implemented and ready to use on the **agent** branch!
