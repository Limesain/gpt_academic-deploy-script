#!/bin/bash

# 显示欢迎信息
echo "=========================================================="
echo "GPT Academic Docker部署脚本"
echo "=========================================================="

# 获取用户的部署确认
read -p "是否开始部署? (Y/N): " start_choice
echo

if [[ ! $start_choice =~ ^[Yy]$ ]]; then
    echo "部署已取消,脚本终止。"
    exit 0
fi

# 更新系统软件包
echo "请选择更新软件包的方式:"
echo "1. 仅更新软件包列表"
echo "2. 更新软件包列表并升级系统软件包"
echo "3. 更新软件包列表并升级所有软件包"
echo

read -p "请输入选项编号 (1-3): " update_choice

case $update_choice in
    1)
        echo "正在更新软件包列表..."
        sudo apt update
        ;;
    2)
        echo "正在更新软件包列表并升级系统软件包..."
        sudo apt update && sudo apt upgrade -y --no-install-recommends
        ;;
    3)
        echo "正在更新软件包列表并升级所有软件包..."
        sudo apt update && sudo apt upgrade -y
        ;;
    *)
        echo "无效的选择,将继续执行脚本。"
        ;;
esac

echo "系统更新完成。"
echo

# 安装 Docker 及其依赖项
echo "正在安装 Docker 及其依赖项..."
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y

# 验证 Docker 安装
echo "正在验证 Docker 安装..."
if sudo systemctl is-active docker >/dev/null 2>&1; then
    echo "Docker 安装成功并正在运行。"
else
    echo "Docker 安装似乎出现了问题,它目前未在运行。"
    echo "请检查上述步骤的输出,以查找并解决问题。"
    exit 1
fi
echo

# 安装 Docker Compose
echo "正在安装 Docker Compose..."
sudo apt install docker-compose -y
docker-compose --version
echo

# 创建项目目录
echo "正在创建项目目录..."
mkdir -p gpt_academic
cd gpt_academic
echo

# 选择部署方案
echo "请选择您想要部署的方案:"
echo "1. 部署chatgpt,azure,星火,千帆,claude等在线大模型方案(默认方案)"
echo "2. 部署ChatGLM + Qwen + MOSS 等本地模型方案"
echo "3. 部署ChatGPT + LLAMA + 盘古 + RWKV 本地模型方案"
echo "4. 部署ChatGPT + Latex方案"
echo "5. 部署ChatGPT + 语音助手方案"
echo "0. 部署项目的全部能力（包含cuda和latex的大型镜像）方案"
echo

while true; do
    read -p "请输入方案编号 (0-5): " scheme_choice
    case $scheme_choice in
        0)
            image="ghcr.io/binary-husky/gpt_academic_with_all_capacity:master"
            cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic_full_capability:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      USE_PROXY: "False"
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      BAIDU_CLOUD_API_KEY: ""
      BAIDU_CLOUD_SECRET_KEY: ""
      BAIDU_CLOUD_QIANFAN_MODEL: "ERNIE-Bot"
      XFYUN_APPID: ""
      XFYUN_API_SECRET: ""
      XFYUN_API_KEY: ""
      ENABLE_AUDIO: "False"
      ALIYUN_APPKEY: ""
      ALIYUN_TOKEN: ""
      DEFAULT_WORKER_NUM: "3"
      WEB_PORT: "-1"
      ADD_WAIFU: "False"
      THEME: "Default"
      AVAIL_THEMES: '["Default", "Chuanhu-Small-and-Beautiful", "High-Contrast", "Gstaff/Xkcd", "NoCrypt/Miku"]'
      INIT_SYS_PROMPT: "Serve me as a writing and programming assistant."
      CHATBOT_HEIGHT: 1115
      CODE_HIGHLIGHT: "True"
      LAYOUT: "LEFT-RIGHT"
      DARK_MODE: "True"
      TIMEOUT_SECONDS: 30
      MAX_RETRY: 2
      DEFAULT_FN_GROUPS: '["对话", "编程", "学术", "智能体"]'
      MULTI_QUERY_LLM_MODELS: "gpt-3.5-turbo&chatglm3"
      QWEN_LOCAL_MODEL_SELECTION: "Qwen/Qwen-1_8B-Chat-Int8"
      LOCAL_MODEL_DEVICE: "cuda"
      LOCAL_MODEL_QUANT: "FP16"
      CONCURRENT_COUNT: 100
      AUTO_CLEAR_TXT: "False"
      API_ORG: ""
      SLACK_CLAUDE_BOT_ID: ""
      SLACK_CLAUDE_USER_TOKEN: ""
      AZURE_ENDPOINT: "https://你亲手写的api名称.openai.azure.com/"
      AZURE_API_KEY: ""
      AZURE_ENGINE: ""
      AZURE_CFG_ARRAY: '{}'
      ALIYUN_ACCESSKEY: ""
      ALIYUN_SECRET: ""
      MATHPIX_APPID: ""
      MATHPIX_APPKEY: ""
      CUSTOM_API_KEY_PATTERN: ""
      GEMINI_API_KEY: ""
      HUGGINGFACE_ACCESS_TOKEN: "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"
      GROBID_URLS: '["https://qingxu98-grobid.hf.space","https://qingxu98-grobid2.hf.space","https://qingxu98-grobid3.hf.space", "https://qingxu98-grobid4.hf.space","https://qingxu98-grobid5.hf.space", "https://qingxu98-grobid6.hf.space", "https://qingxu98-grobid7.hf.space", "https://qingxu98-grobid8.hf.space"]'
      ALLOW_RESET_CONFIG: "False"
      AUTOGEN_USE_DOCKER: "False"
      WHEN_TO_USE_PROXY: '["Download_LLM", "Download_Gradio_Theme", "Connect_Grobid", "Warmup_Modules", "Nougat_Download", "AutoGen"]'
      BLOCK_INVALID_APIKEY: "False"
      PLUGIN_HOT_RELOAD: "False"
      NUM_CUSTOM_BASIC_BTN: 4
      API_URL_REDIRECT: '{}'
      SSL_KEYFILE: ""
      SSL_CERTFILE: ""
      ZHIPUAI_API_KEY: ""
      ZHIPUAI_MODEL: ""
      ANTHROPIC_API_KEY: ""
      MOONSHOT_API_KEY: ""
      PATH_PRIVATE_UPLOAD: "private_upload"
      PATH_LOGGING: "gpt_log"
    network_mode: "host"
    command: bash -c "python3 -u main.py"
    runtime: nvidia
    devices:
      - /dev/nvidia0:/dev/nvidia0
EOL
            break
            ;;
        1)
            image="ghcr.io/binary-husky/gpt_academic_nolocal:master"
            cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      USE_PROXY: "False"
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      PROXIES: '{"http": "socks5h://localhost:11284", "https": "socks5h://localhost:11284"}'
      WEB_PORT: "-1"
      ADD_WAIFU: "False"
    network_mode: "host"
    command: bash -c "python3 -u main.py"
EOL
            break
            ;;
        2)
            image="ghcr.io/binary-husky/gpt_academic_chatglm_moss:master"
            cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic_with_chatglm:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      USE_PROXY: "False"
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      LOCAL_MODEL_DEVICE: "cuda"
      QWEN_LOCAL_MODEL_SELECTION: "Qwen/Qwen-1_8B-Chat-Int8"
    runtime: nvidia
    devices:
      - /dev/nvidia0:/dev/nvidia0
EOL
            break
            ;;
        3)
            image="ghcr.io/binary-husky/gpt_academic_jittorllms:master"
            cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic_with_rwkv:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      USE_PROXY: "False"
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      LOCAL_MODEL_DEVICE: "cuda"
      CHATGLM_PTUNING_CHECKPOINT: ""
    runtime: nvidia
    devices:
      - /dev/nvidia0:/dev/nvidia0
EOL
            break
            ;;
        4)
            image="ghcr.io/binary-husky/gpt_academic_with_latex:master"
            cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic_with_latex:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      USE_PROXY: "False"
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
    network_mode: "host"
    command: bash -c "python3 -u main.py"
EOL
            break
            ;;
        5)
            image="ghcr.io/binary-husky/gpt_academic_audio_assistant:master"
            cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic_with_audio:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      USE_PROXY: "False"
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      ENABLE_AUDIO: "True"
      ALIYUN_APPKEY: ""
      ALIYUN_TOKEN: ""
    network_mode: "host"
    command: bash -c "python3 -u main.py"
EOL
            break
            ;;
        *)
            echo "无效的选择。请输入 0 到 5 之间的数字。"
            ;;
    esac
done

echo "docker-compose.yml 文件创建完成。"
echo

# 启动 GPT Academic
echo "正在启动 GPT Academic..."
docker-compose up -d
echo "GPT Academic 已启动。"
echo

# 检查容器运行状态
echo "正在检查容器运行状态..."
docker-compose ps
echo

# 查看运行日志功能
function view_logs() {
    local rows=$(tput lines)
    local columns=$(tput cols)
    local message="按 ESC 键返回主菜单"
    local message_length=${#message}
    local message_start=$(((columns - message_length) / 2))
    
    tput cup $((rows - 1)) $message_start
    echo -n "$message"
    
    docker-compose logs --no-color gpt_academic | sed 's/^.*gpt_academic_1  | //' &
    
    while read -rsn1 key; do
        if [[ $key == $'\e' ]]; then
            kill $!
            break
        fi
    done
    
    tput cup $((rows - 1)) 0
    tput el
    echo ""
}

# 自定义配置功能
function custom_config() {
    echo "请选择要修改的配置:"
    echo "1. API 密钥"
    echo "2. 代理设置"
    echo "3. 使用的 LLM 模型"
    echo "4. 可用的 LLM 模型列表"
    echo "5. 返回主菜单"
    echo

    read -p "请输入选项编号 (1-5): " config_choice

    case $config_choice in
        1)
            read -p "请输入新的 API 密钥: " new_api_key
            sed -i "s/API_KEY:.*/API_KEY: \"$new_api_key\"/g" docker-compose.yml
            echo "API 密钥已更新。"
            ;;
        2)
            read -p "是否使用代理? (True/False): " use_proxy
            read -p "请输入代理地址和端口 (例如: socks5h://localhost:11284): " proxy_url
            sed -i "s/USE_PROXY:.*/USE_PROXY: \"$use_proxy\"/g" docker-compose.yml
            sed -i "s#PROXIES:.*#PROXIES: '{\"http\": \"$proxy_url\", \"https\": \"$proxy_url\"}'#g" docker-compose.yml
            echo "代理设置已更新。"
            ;;
        3)
            read -p "请输入要使用的 LLM 模型: " llm_model
            sed -i "s/LLM_MODEL:.*/LLM_MODEL: \"$llm_model\"/g" docker-compose.yml
            echo "LLM 模型已更新。"
            ;;
        4)
            read -p "请输入可用的 LLM 模型列表 (用引号和逗号分隔): " llm_models
            sed -i "s/AVAIL_LLM_MODELS:.*/AVAIL_LLM_MODELS: '$llm_models'/g" docker-compose.yml
            echo "可用的 LLM 模型列表已更新。"
            ;;
        5)
            return
            ;;
        *)
            echo "无效的选择。请输入 1 到 5 之间的数字。"
            ;;
    esac

    custom_config
}

# 主菜单功能
function main_menu() {
    echo "=========================================================="
    echo "GPT Academic 管理菜单"
    echo "=========================================================="
    echo "1. 重新启动 GPT Academic"
    echo "2. 修改配置"
    echo "3. 查看运行日志"
    echo "4. 退出"
    echo

    read -p "请输入选项编号 (1-4): " menu_choice

    case $menu_choice in
        1)
            echo "正在重新启动 GPT Academic..."
            docker-compose down
            docker-compose up -d
            echo "GPT Academic 已重新启动。"
            ;;
        2)
            custom_config
            echo "配置已修改,请重新启动 GPT Academic 以应用更改。"
            ;;
        3)
            view_logs
            ;;
        4)
            echo "感谢使用 GPT Academic 一键部署脚本。再见!"
            exit 0
            ;;
        *)
            echo "无效的选择。请输入 1 到 4 之间的数字。"
            ;;
    esac

    main_menu
}

main_menu
