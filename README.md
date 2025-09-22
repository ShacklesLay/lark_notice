# Lark Bash 通知工具

这是一个用于在 bash 脚本中发送飞书通知的工具集，类似于你现有的 Python 版本 `larknotice.py`。

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

# 引入通知功能
source /path/to/lark_bash_notify.sh

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

## 高级用法

### 1. 监控长时间运行的任务

```bash
./lark_wrapper.sh ./long_running_job.sh "深度学习训练"
```

### 2. 监控数据处理流水线

```bash
./lark_bash_notify.sh monitor "ETL流水线" "
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
source lark_bash_notify.sh

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

## 故障排除

1. **权限问题**：确保脚本有执行权限
2. **网络问题**：检查是否能访问飞书webhook URL
3. **URL问题**：确认webhook URL格式正确
4. **环境变量**：确认 `LARK_HOOK` 已正确设置

## 与Python版本的对比

| 功能 | Python版本 | Bash版本 |
|------|-----------|----------|
| 装饰器支持 | ✅ | ❌（使用包装器代替） |
| 函数监控 | ✅ | ✅（脚本/命令监控） |
| 错误捕获 | ✅ | ✅ |
| 执行时间统计 | ✅ | ✅ |
| 分布式训练支持 | ✅ | ❌ |
| 主机信息 | ✅ | ✅ |
| 自定义消息 | ✅ | ✅ |

## 示例场景

1. **定时任务监控**：在crontab中使用wrapper监控定时脚本
2. **CI/CD流水线**：在构建脚本中集成通知
3. **系统维护**：监控备份、清理等维护脚本
4. **数据处理**：监控ETL、批处理任务
5. **服务器监控**：定期检查系统状态并通知

这个工具让你能够像使用Python装饰器一样方便地为bash脚本添加飞书通知功能！
