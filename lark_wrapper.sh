#!/bin/bash

# Lark Wrapper - A convenient wrapper to monitor any bash script with Lark notifications
# This script allows you to easily add Lark monitoring to existing scripts without modification

source "$(dirname "$0")/lark_bash_notify.sh"

# Check if the script file exists and is executable
check_script() {
    local script_path="$1"
    
    if [[ ! -f "$script_path" ]]; then
        echo "Error: Script file '$script_path' not found."
        exit 1
    fi
    
    if [[ ! -x "$script_path" ]]; then
        echo "Warning: Script file '$script_path' is not executable. Making it executable..."
        chmod +x "$script_path"
    fi
}

# Main wrapper function
main() {
    if [[ $# -lt 1 ]]; then
        echo "Lark Wrapper - Monitor bash scripts with Lark notifications"
        echo ""
        echo "Usage:"
        echo "  $0 <script_path> [task_name] [webhook_url]"
        echo ""
        echo "Arguments:"
        echo "  script_path  - Path to the bash script to monitor"
        echo "  task_name    - Optional task name for notifications (default: script filename)"
        echo "  webhook_url  - Optional webhook URL (uses LARK_HOOK env var if not provided)"
        echo ""
        echo "Environment Variables:"
        echo "  LARK_HOOK    - Default webhook URL"
        echo ""
        echo "Examples:"
        echo "  # Monitor a backup script"
        echo "  $0 ./backup.sh 'Daily Backup'"
        echo ""
        echo "  # Monitor with custom webhook"
        echo "  $0 ./data_process.py 'Data Processing' 'https://your-webhook-url'"
        echo ""
        echo "  # Monitor with environment variable"
        echo "  export LARK_HOOK='https://your-webhook-url'"
        echo "  $0 ./my_script.sh"
        exit 1
    fi
    
    local script_path="$1"
    local task_name="${2:-$(basename "$script_path")}"
    local webhook_url="$3"
    
    # Check if script exists and is executable
    check_script "$script_path"
    
    # Determine webhook URL
    if [[ -z "$webhook_url" ]]; then
        if [[ -n "$LARK_HOOK" ]]; then
            webhook_url="$LARK_HOOK"
        else
            echo "Error: No webhook URL provided. Set LARK_HOOK environment variable or pass URL as argument."
            exit 1
        fi
    fi
    
    # Get absolute path of script
    local abs_script_path=$(realpath "$script_path")
    
    echo "Starting monitoring for: $abs_script_path"
    echo "Task name: $task_name"
    echo "Webhook URL: ${webhook_url:0:50}..."
    echo ""
    
    # Monitor the script execution
    lark_monitor "$webhook_url" "$task_name" "$abs_script_path"
    local exit_code=$?
    
    echo ""
    echo "Script execution finished with exit code: $exit_code"
    
    exit $exit_code
}

# Execute main function
main "$@"
