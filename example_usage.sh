#!/bin/bash

# Example usage of lark_bash_notify.sh
# Make sure to set your webhook URL first!

# Method 1: Set environment variable (recommended)
export LARK_HOOK="https://open.feishu.cn/open-apis/bot/v2/hook/your-webhook-url-here"

echo "=== Lark Bash Notification Examples ==="

# Example 1: Simple message sending
echo "1. Sending a simple message..."
./lark_bash_notify.sh send "Hello from bash script! 👋"

# Example 2: Monitor a simple command
echo "2. Monitoring a simple sleep command..."
./lark_bash_notify.sh monitor "Sleep Test" "sleep 3 && echo 'Sleep completed'"

# Example 3: Monitor a command that might fail
echo "3. Monitoring a command that will fail..."
./lark_bash_notify.sh monitor "Failure Test" "ls /nonexistent/directory"

# Example 4: Monitor a more complex script
echo "4. Monitoring a data processing simulation..."
./lark_bash_notify.sh monitor "Data Processing" "
    echo 'Starting data processing...'
    sleep 2
    echo 'Processing batch 1/3...'
    sleep 2
    echo 'Processing batch 2/3...'
    sleep 2
    echo 'Processing batch 3/3...'
    sleep 2
    echo 'Data processing completed successfully!'
"

# Example 5: Monitor with explicit webhook URL (if not using environment variable)
# ./lark_bash_notify.sh monitor "https://your-webhook-url" "Custom Task" "your-command-here"

echo "=== Examples completed ==="
