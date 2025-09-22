#!/bin/bash

# Lark Wrapper - A convenient wrapper to monitor bash scripts and commands with Lark notifications
# This script allows you to easily add Lark monitoring to existing scripts or complex commands

source "$(dirname "$0")/lark_bash_notify.sh"

# Check if the script file exists and is executable (for single script mode)
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

# Check if the first argument looks like a command (starts with common command keywords)
is_command() {
    local first_arg="$1"
    case "$first_arg" in
        bash|sh|python|python3|node|java|./*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Main wrapper function
main() {
    if [[ $# -lt 1 ]]; then
        echo "Lark Wrapper - Monitor bash scripts and commands with Lark notifications"
        echo ""
        echo "Usage:"
        echo "  # Single script mode:"
        echo "  $0 <script_path> [task_name] [webhook_url]"
        echo ""
        echo "  # Command mode:"
        echo "  $0 \"<full_command>\" [task_name] [webhook_url]"
        echo ""
        echo "Arguments:"
        echo "  script_path   - Path to the bash script to monitor"
        echo "  full_command  - Complete command to monitor (in quotes)"
        echo "  task_name     - Optional task name for notifications"
        echo "  webhook_url   - Optional webhook URL (uses LARK_HOOK env var if not provided)"
        echo ""
        echo "Environment Variables:"
        echo "  LARK_HOOK     - Default webhook URL"
        echo ""
        echo "Examples:"
        echo "  # Monitor a script file"
        echo "  $0 ./backup.sh 'Daily Backup'"
        echo ""
        echo "  # Monitor a complex command"
        echo "  $0 \"bash script.sh /path/to/data.json\" 'Data Processing'"
        echo ""
        echo "  # Monitor with environment variable"
        echo "  export LARK_HOOK='https://your-webhook-url'"
        echo "  $0 \"python train.py --config config.yaml\" 'Model Training'"
        exit 1
    fi
    
    local first_arg="$1"
    local task_name="$2"
    local webhook_url="$3"
    local command_to_execute=""
    local display_name=""
    
    # Determine if this is a command or a script file
    if is_command "$first_arg" || [[ "$first_arg" == *" "* ]]; then
        # Command mode: treat the first argument as a complete command
        command_to_execute="$first_arg"
        display_name="$first_arg"
        task_name="${task_name:-Command}"
    else
        # Script file mode: check if it's a valid file
        check_script "$first_arg"
        command_to_execute=$(realpath "$first_arg")
        display_name="$command_to_execute"
        task_name="${task_name:-$(basename "$first_arg")}"
    fi
    
    # Determine webhook URL
    if [[ -z "$webhook_url" ]]; then
        if [[ -n "$LARK_HOOK" ]]; then
            webhook_url="$LARK_HOOK"
        else
            echo "Error: No webhook URL provided. Set LARK_HOOK environment variable or pass URL as argument."
            exit 1
        fi
    fi
    
    echo "Starting monitoring for: $display_name"
    echo "Task name: $task_name"
    echo "Webhook URL: ${webhook_url:0:50}..."
    echo ""
    
    # Monitor the execution using lark_monitor function
    # Use the smart parameter parsing by calling lark_monitor with webhook_url first
    lark_monitor "$webhook_url" "$task_name" "$command_to_execute"
    local exit_code=$?
    
    echo ""
    echo "Execution finished with exit code: $exit_code"
    
    exit $exit_code
}

# Execute main function
main "$@"
