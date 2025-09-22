#!/bin/bash

# Bash version of lark notification tool
# Usage: ./lark_bash_notify.sh [webhook_url] [message]
# Environment variable: LARK_HOOK

# Date format
DATE_FORMAT="%Y-%m-%d %H:%M:%S"

# Function to send message to Lark
send_lark_message() {
    local webhook_url="$1"
    local content="$2"
    
    # Check if webhook URL is provided
    if [[ -z "$webhook_url" ]]; then
        if [[ -n "$LARK_HOOK" ]]; then
            webhook_url="$LARK_HOOK"
        else
            echo "Error: No webhook URL provided. Set LARK_HOOK environment variable or pass URL as argument."
            return 1
        fi
    fi
    
    # Get current timestamp
    local timestamp=$(date +%s)
    
    # Prepare JSON payload
    local json_payload=$(cat <<EOF
{
    "timestamp": $timestamp,
    "msg_type": "text",
    "content": {
        "text": "$content"
    }
}
EOF
)
    
    # Send POST request to Lark webhook
    local response=$(curl -s -X POST "$webhook_url" \
        -H "Content-Type: application/json" \
        -d "$json_payload")
    
    # Check response
    local code=$(echo "$response" | grep -o '"code":[^,}]*' | cut -d':' -f2 | tr -d ' ')
    if [[ "$code" != "0" && -n "$code" ]]; then
        local msg=$(echo "$response" | grep -o '"msg":"[^"]*"' | cut -d'"' -f4)
        echo "Lark notification failed: $msg"
        return 1
    fi
    
    echo "Lark notification sent successfully"
    return 0
}

# Function to wrap script execution with notifications
lark_monitor() {
    local webhook_url=""
    local task_name=""
    local script_command=""
    
    # Smart parameter parsing - check if first argument looks like a URL
    if [[ $# -ge 3 && "$1" =~ ^https?:// ]]; then
        # Format: webhook_url task_name command...
        webhook_url="$1"
        task_name="$2"
        script_command="${@:3}"
    elif [[ $# -ge 2 ]]; then
        # Format: task_name command... (use LARK_HOOK)
        webhook_url=""
        task_name="$1"
        script_command="${@:2}"
    else
        echo "Usage: lark_monitor [webhook_url] [task_name] [command...]"
        echo "       lark_monitor [task_name] [command...]  (uses LARK_HOOK environment variable)"
        echo "Example: lark_monitor 'https://...' 'Data Processing' './my_script.sh'"
        echo "         lark_monitor 'Data Processing' './my_script.sh'  (with LARK_HOOK set)"
        return 1
    fi
    
    # Set default task name if empty
    task_name="${task_name:-Default}"
    
    if [[ -z "$script_command" ]]; then
        echo "Error: No command specified to monitor"
        return 1
    fi
    
    # Get system information
    local start_time=$(date +"$DATE_FORMAT")
    local start_timestamp=$(date +%s)
    local hostname=$(hostname)
    
    # Send start notification
    local start_content="Your script has started 🎬
Task: $task_name
Machine name: $hostname
Command: $script_command
Starting date: $start_time"
    
    send_lark_message "$webhook_url" "$start_content"
    
    # Execute the command and capture output and exit code
    local temp_output=$(mktemp)
    local exit_code=0
    
    echo "Executing: $script_command"
    if eval "$script_command" > "$temp_output" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # Calculate execution time
    local end_time=$(date +"$DATE_FORMAT")
    local end_timestamp=$(date +%s)
    local duration=$((end_timestamp - start_timestamp))
    local duration_formatted=$(printf "%02d:%02d:%02d" $((duration/3600)) $((duration%3600/60)) $((duration%60)))
    
    # Send completion or error notification
    if [[ $exit_code -eq 0 ]]; then
        local success_content="Your script is complete 🎉
Task: $task_name
Machine name: $hostname
Command: $script_command
Starting date: $start_time
End date: $end_time
Execution duration: ${duration_formatted}"
        
        send_lark_message "$webhook_url" "$success_content"
    else
        local error_content="Your script has crashed ☠️
Task: $task_name
Machine name: $hostname
Command: $script_command
Starting date: $start_time
Crash date: $end_time
Failed execution duration: ${duration_formatted}

Exit code: $exit_code

Output:
$(cat "$temp_output" | tail -20)"
        
        send_lark_message "$webhook_url" "$error_content"
    fi
    
    # Clean up
    rm -f "$temp_output"
    
    return $exit_code
}

# Function to send simple message
lark_send() {
    local webhook_url="$1"
    local message="$2"
    
    # If only one argument is provided, treat it as message and use LARK_HOOK
    if [[ $# -eq 1 && -n "$1" ]]; then
        message="$1"
        webhook_url=""
    fi
    
    if [[ -z "$message" ]]; then
        echo "Usage: lark_send [webhook_url] [message]"
        echo "       lark_send [message]  (uses LARK_HOOK environment variable)"
        echo "Example: lark_send 'https://...' 'Hello from bash!'"
        echo "         lark_send 'Hello from bash!'  (with LARK_HOOK set)"
        return 1
    fi
    
    send_lark_message "$webhook_url" "$message"
}

# Main execution
case "${1:-help}" in
    "monitor")
        shift
        lark_monitor "$@"
        ;;
    "send")
        shift
        lark_send "$@"
        ;;
    "help"|"-h"|"--help")
        echo "Lark Bash Notification Tool"
        echo ""
        echo "Usage:"
        echo "  $0 monitor [webhook_url] [task_name] [command...]"
        echo "  $0 monitor [task_name] [command...]  (uses LARK_HOOK environment variable)"
        echo "  $0 send [webhook_url] [message]"
        echo "  $0 send [message]  (uses LARK_HOOK environment variable)"
        echo ""
        echo "Environment Variables:"
        echo "  LARK_HOOK - Default webhook URL"
        echo ""
        echo "Examples:"
        echo "  # Monitor with webhook URL"
        echo "  $0 monitor 'https://your-webhook-url' 'My Backup Task' './backup.sh'"
        echo ""
        echo "  # Monitor using environment variable (recommended)"
        echo "  export LARK_HOOK='https://open.feishu.cn/open-apis/bot/v2/hook/your-webhook-url'"
        echo "  $0 monitor 'Data Processing' 'python process.py'"
        echo ""
        echo "  # Send simple message"
        echo "  $0 send 'Task completed successfully!'"
        ;;
    *)
        # Default behavior: treat first argument as webhook_url and second as message
        if [[ $# -eq 2 ]]; then
            lark_send "$1" "$2"
        else
            echo "Invalid usage. Use '$0 help' for usage information."
            exit 1
        fi
        ;;
esac
