# Lark Bash 通知工具

这是一个用于在 bash 脚本中发送飞书通知的完整工具集，让你能够像装饰器一样方便地为bash脚本添加飞书通知功能。

## 功能特性

- 🎬 脚本开始执行时发送通知
- 🎉 脚本成功完成时发送通知
- ☠️ 脚本出错时发送详细错误信息
- ⏱️ 自动计算和报告执行时间
- 🖥️ 包含主机名和任务信息
- 📝 支持自定义任务名称

## 文件说明

- `lark_bash_notify.sh` - 核心通知功能脚本
- `lark_wrapper.sh` - 便捷的包装器，用于监控现有脚本
- `example_usage.sh` - 使用示例

## 安装和设置

1. 确保脚本具有执行权限：
```bash
chmod +x lark_bash_notify.sh lark_wrapper.sh example_usage.sh
```

2. 设置飞书机器人webhook URL：
```bash
export LARK_HOOK="https://open.feishu.cn/open-apis/bot/v2/hook/your-webhook-url"
```

larknotice监听代码运行情况需要飞书创建一个群组（如果只想发给自己，可以不拉任何人来创建一个只包含自己的群组）。然后在群组设置-机器人里选择添加机器人-自定义机器人，你可以任意选定机器人的头像、名称、描述等。添加后会得到webhook URL。

## 使用方法

### 方法1：使用包装器监控现有脚本（推荐）

```bash
# 监控现有脚本
./lark_wrapper.sh ./your_script.sh "自定义任务名"

# 使用默认任务名（脚本文件名）
./lark_wrapper.sh ./backup.sh
```

**重要提示：跨路径使用**

如果 `lark_wrapper.sh` 和要监控的脚本不在同一目录下，推荐以下方法：

1. **使用绝对路径（推荐）**：
```bash
# 使用绝对路径运行工具
/path/to/lark_notice/lark_wrapper.sh /opt/scripts/backup.sh "备份任务"
```

2. **添加到系统PATH**：
```bash
# 将工具目录添加到PATH（添加到 ~/.bashrc）
export PATH="/path/to/lark_notice:$PATH"

# 然后可以在任何地方使用
lark_wrapper.sh /any/path/script.sh "任务名称"
```

3. **创建符号链接**：
```bash
# 创建到系统目录的符号链接
sudo ln -s /path/to/lark_notice/lark_wrapper.sh /usr/local/bin/lark_wrapper
# 然后就可以全局使用
lark_wrapper /path/to/your/script.sh "任务名"
```

### 方法2：直接使用核心功能

```bash
# 监控命令执行
./lark_bash_notify.sh monitor "数据处理任务" "python data_process.py"

# 发送简单消息
./lark_bash_notify.sh send "任务完成通知"
```

### 方法3：在脚本中嵌入通知功能

在你的bash脚本中添加：

```bash
#!/bin/bash

# 引入通知功能（使用绝对路径）
source /path/to/lark_notice/lark_bash_notify.sh

# 发送开始通知
lark_send "$LARK_HOOK" "数据备份开始 🎬"

# 你的业务逻辑
echo "执行备份操作..."
# ... 你的代码 ...

if [ $? -eq 0 ]; then
    # 成功通知
    lark_send "$LARK_HOOK" "数据备份完成 🎉"
else
    # 失败通知
    lark_send "$LARK_HOOK" "数据备份失败 ☠️"
fi
```

**注意**：在 `source` 命令中请使用 `lark_bash_notify.sh` 的绝对路径，以确保从任何位置运行脚本时都能正确加载通知功能。

## 高级用法

### 1. 监控长时间运行的任务

```bash
./lark_wrapper.sh ./long_running_job.sh "深度学习训练"
```

### 2. 监控数据处理流水线

```bash
# 如果在不同目录，使用绝对路径
/path/to/lark_notice/lark_bash_notify.sh monitor "ETL流水线" "
    echo '开始数据提取...'
    python extract_data.py
    echo '开始数据转换...'
    python transform_data.py
    echo '开始数据加载...'
    python load_data.py
    echo 'ETL流水线完成'
"
```

### 3. 条件通知

```bash
#!/bin/bash
source /path/to/lark_notice/lark_bash_notify.sh

# 检查磁盘空间
disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $disk_usage -gt 80 ]; then
    lark_send "$LARK_HOOK" "⚠️ 警告：磁盘使用率已达到 ${disk_usage}%"
fi
```

## 通知消息格式

### 开始通知
```
Your script has started 🎬
Task: 自定义任务名
Machine name: hostname
Command: ./your_script.sh
Starting date: 2024-01-01 10:00:00
```

### 成功通知
```
Your script is complete 🎉
Task: 自定义任务名
Machine name: hostname
Command: ./your_script.sh
Starting date: 2024-01-01 10:00:00
End date: 2024-01-01 10:05:30
Execution duration: 00:05:30
```

### 错误通知
```
Your script has crashed ☠️
Task: 自定义任务名
Machine name: hostname
Command: ./your_script.sh
Starting date: 2024-01-01 10:00:00
Crash date: 2024-01-01 10:02:15
Failed execution duration: 00:02:15

Exit code: 1

Output:
[最后20行错误输出]
```

## 环境变量

- `LARK_HOOK` - 飞书机器人webhook URL（必需）

## 依赖要求

- `curl` - 用于发送HTTP请求
- `bash` - 版本4.0或更高
- 标准Unix工具：`date`, `hostname`, `grep`, `awk`

## 跨路径使用最佳实践

当工具和要监控的脚本在不同目录时，推荐以下最佳实践：

### 1. 环境配置（推荐）

```bash
# 在 ~/.bashrc 或 ~/.profile 中添加
export PATH="/path/to/lark_notice:$PATH"
export LARK_HOOK="https://open.feishu.cn/open-apis/bot/v2/hook/your-webhook-url"

# 重新加载配置
source ~/.bashrc
```

配置后可以在任何位置使用：
```bash
# 监控任意路径的脚本
lark_wrapper.sh /opt/scripts/backup.sh "备份任务"
lark_wrapper.sh ~/projects/data_processing.sh "数据处理"
```

### 2. Crontab 定时任务

```bash
# 编辑 crontab
crontab -e

# 添加定时任务（使用绝对路径）
0 2 * * * /path/to/lark_notice/lark_wrapper.sh /opt/scripts/daily_backup.sh "每日备份"
0 */6 * * * /path/to/lark_notice/lark_wrapper.sh /home/user/health_check.sh "系统健康检查"
```

### 3. CI/CD 集成

```bash
# 在 CI/CD 脚本中使用
#!/bin/bash
LARK_TOOL="/path/to/lark_notice/lark_wrapper.sh"
export LARK_HOOK="https://your-webhook-url"

# 监控构建过程
$LARK_TOOL /ci/scripts/build.sh "项目构建"
$LARK_TOOL /ci/scripts/test.sh "单元测试"
$LARK_TOOL /ci/scripts/deploy.sh "部署"
```

## 故障排除

1. **权限问题**：确保脚本有执行权限
2. **网络问题**：检查是否能访问飞书webhook URL
3. **URL问题**：确认webhook URL格式正确
4. **环境变量**：确认 `LARK_HOOK` 已正确设置
5. **路径问题**：使用绝对路径或确保PATH配置正确

## 核心功能特性

| 功能 | 支持状态 | 说明 |
|------|---------|------|
| 脚本监控 | ✅ | 使用包装器监控任意bash脚本 |
| 错误捕获 | ✅ | 自动捕获并报告脚本错误 |
| 执行时间统计 | ✅ | 精确计算和报告执行时间 |
| 主机信息 | ✅ | 包含主机名和执行环境信息 |
| 自定义消息 | ✅ | 支持发送自定义通知消息 |
| 跨平台支持 | ✅ | 支持所有标准Unix/Linux环境 |
| 零依赖 | ✅ | 仅依赖标准bash和curl |

## 示例场景

1. **定时任务监控**：在crontab中使用wrapper监控定时脚本
2. **CI/CD流水线**：在构建脚本中集成通知
3. **系统维护**：监控备份、清理等维护脚本
4. **数据处理**：监控ETL、批处理任务
5. **服务器监控**：定期检查系统状态并通知

这个工具让你能够像使用装饰器一样方便地为bash脚本添加飞书通知功能！无论是定时任务、CI/CD流水线还是日常运维脚本，都能轻松集成飞书通知。
