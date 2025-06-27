# Submon - Subdomain Monitoring Script

Submon is a simple Bash script designed to monitor live subdomains across multiple target domains.  
It uses passive discovery tools and filters the results through `httpx`, then sends a notification via **Discord** or **Slack** when new live subdomains are detected.

---

## 🚀 Features

- Collects subdomains using:
  - `subfinder`
  - `assetfinder`
  - `sublist3r`
- Filters only live subdomains using `httpx`
- Tracks newly discovered live subdomains
- Sends alerts via **a single `WEBHOOK`** (compatible with Discord or Slack)

---

## 🔧 Requirements

Ensure the following tools are installed and accessible from your terminal:

```bash
subfinder
assetfinder
sublist3r
httpx
curl

You can install them via package managers like `apt`, `brew`, or from their GitHub repositories.

---

## 📁 File Structure

- `submon.sh` → The main script
- `domains.txt` → A text file with one root domain per line
- `submon_data/` → Output directory (auto-created)

---

## 📥 Setup

1. **Edit `submon.sh` and set your webhook:**

WEBHOOK="https://discord.com/api/webhooks/..."

or

WEBHOOK="https://hooks.slack.com/services/..."
```

2. **Make the script executable:**

```bash
chmod +x submon.sh
```

3. **Add your target domains to `domains.txt`:**

```
example.com
target.org
anotherdomain.net
```

---

## ▶️ Usage

Run the script manually:

```bash
./submon.sh
```

The script will:

- Discover subdomains from multiple tools
- Check which ones are alive using `httpx`
- Compare results with previous executions
- Notify you only if new live subdomains are detected

---

## 🔁 Automation

To run it daily, you can create a cronjob:

```bash
crontab -e
```

Add:

```bash
@daily /path/to/submon.sh
```

---

## 📬 Example Notification

> 📡 New live subdomains detected for **example.com**

---

## ❗ Notes

- Slack and Discord support is mutually exclusive. You can switch between them by modifying the `WEBHOOK` variable.

---

## 🧠 Author

**Marcos Suárez (@n31ux)**  
Security Researcher

---
