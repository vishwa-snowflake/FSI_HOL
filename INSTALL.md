# Quick Install Guide

**Time Required**: 20 minutes  
**Cost**: Free (works with Snowflake free trial)

---

## Step 1: Get Snowflake Free Trial

1. Visit https://signup.snowflake.com/
2. Fill out the form
3. Choose **Enterprise** edition
4. Pick any cloud region (AWS/Azure/GCP)
5. Verify your email
6. Log in to Snowflake

**✅ You now have a Snowflake account!**

---

## Step 2: Install Tools

Open your terminal and run:

```bash
# Install Snowflake CLI
pip install snowflake-cli-labs

# Verify installation
snow --version
```

**Expected output**: `Snowflake CLI version X.X.X`

**✅ SnowCLI installed!**

---

## Step 3: Download This Project

```bash
# Clone the repository
git clone https://github.com/Snowflake-Labs/sfguide-build-ai-assistant-fsi-cortex.git

# Enter the directory
cd sfguide-build-ai-assistant-fsi-cortex
```

**✅ Project downloaded!**

---

## Step 4: Connect to Snowflake

Configure SnowCLI with your account:

```bash
snow connection add
```

**You'll be asked for**:

| Question | Answer | Example |
|----------|--------|---------|
| Connection name? | Any name you want | `my_snowflake` |
| Account? | Your account URL | `abc12345.us-east-1.aws.snowflakecomputing.com` |
| Username? | Your Snowflake username | `john_doe` |
| Password? | Your password | `•••••••••` |
| Role? | `ACCOUNTADMIN` | `ACCOUNTADMIN` |
| Warehouse? | Default warehouse | `COMPUTE_WH` |

**Find your account URL**:
- In Snowflake UI, look at the browser address bar
- Format: `<account>.snowflakecomputing.com`
- Or: Click your name (top right) → **Account**

**Test the connection**:

```bash
snow connection test -c my_snowflake
```

**Expected**: `Connection successful!`

**✅ Connected to Snowflake!**

---

## Step 5: Deploy Everything

Run the deployment script:

```bash
./quickstart_deploy.sh
```

**What it will ask**:

1. **"Enter connection name to use:"** → Type `my_snowflake` (or whatever you named it)
2. **"Continue with deployment? (y/N):"** → Type `y`

**What happens next** (automatically):

```
[1/5] Configure Account... ✓
[2/5] Deploy Data Foundation... ✓ (this takes ~10 minutes)
[3/5] Deploy Cortex Analyst... ✓
[4/5] Deploy Streamlit... ✓
[5/5] Deploy Notebooks... ✓
```

**Total time**: 15-20 minutes

**✅ Everything deployed!**

---

## Step 6: Open StockOne App

1. **Open Snowflake UI** in your browser
2. Click **AI & ML Studio** in left navigation
3. Click **Streamlit**
4. Click **STOCKONE_AGENT**

**You should see**: A chat interface with a snowflake emoji

**Try asking**:
```
What is the latest closing price of Snowflake stock?
```

**✅ Your AI assistant is working!**

---

## What You Just Deployed

- ✅ **20+ tables** with financial data (earnings calls, reports, emails, stock prices)
- ✅ **5 search services** for semantic search
- ✅ **2 semantic views** for natural language SQL
- ✅ **1 AI agent** (One Ticker) with 8 tools
- ✅ **1 Streamlit app** (StockOne) with chat interface
- ✅ **4 Snowflake notebooks** for data processing

---

## Next Steps

### Try More Features

**Search Services**:
- Navigate to **AI & ML Studio** → **Cortex Search**
- Try searching emails, reports, transcripts

**Cortex Analyst**:
- Navigate to **AI & ML Studio** → **Cortex Analyst**  
- Ask: "What is the revenue for Snowflake?"

**One Ticker Agent**:
- Navigate to **AI & ML Studio** → **Snowflake Intelligence** → **One Ticker**
- Ask: "Show me revenue trend for Snowflake"

**Notebooks**:
- Navigate to **AI & ML Studio** → **Notebooks**
- Open and run: **1_EXTRACT_DATA_FROM_DOCUMENTS**

### Learn More

- **Detailed Guide**: See [quickstart.md](quickstart.md) for complete walkthrough
- **Technical Docs**: See [DEPLOYMENT_README.md](DEPLOYMENT_README.md)
- **Snowflake Docs**: https://docs.snowflake.com/cortex

---

## Troubleshooting

### "SnowCLI not found"

```bash
pip install snowflake-cli-labs
```

### "Connection test failed"

Double-check:
- Account URL is correct (include region)
- Username and password are correct
- Using ACCOUNTADMIN role
- Warehouse exists (COMPUTE_WH is default in free trial)

### "Deployment failed"

Check the error log:
```bash
tail -50 /tmp/deploy_*.log
```

Common issues:
- Warehouse not started (wait 30 seconds and retry)
- Insufficient privileges (ensure using ACCOUNTADMIN)
- Network timeout (retry the command)

### "Object not found" in Streamlit

This usually means deployment didn't complete. Re-run:
```bash
./quickstart_deploy.sh
```

---

## Need Help?

- **Documentation**: See [quickstart.md](quickstart.md) for detailed guide
- **Community**: Ask on [Snowflake Community](https://community.snowflake.com)
- **Issues**: Report problems on GitHub
- **Snowflake Support**: For account-specific issues

---

## Summary

You've just deployed a **production-ready AI assistant** in under 20 minutes! 🎉

**What's next?**
- Explore the features
- Customize with your data
- Share with your team
- Deploy to production

**Happy building with Snowflake Cortex AI!** ❄️

