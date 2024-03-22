#!/bin/bash

# 定义颜色变量
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 显示GPT Academic的ASCII艺术字
function display_logo() {
    echo -e "${PURPLE}=========================================================="
    echo -e "               GPT Academic Docker 部署脚本"
    echo -e "==========================================================${NC}"
    echo -e "${CYAN}GPT 学术优化 (GPT Academic)${NC}"
    echo -e "${BLUE}项目地址:${NC}https://github.com/binary-husky/gpt_academic"
    echo "---"
    echo "脚本项目地址 https://github.com/Limesain/gpt_academic-deploy-script"
    echo "当前部署脚本为 1.0 适用GPT Academic项目版本为 3.73  测试平台为 ubuntu 20.04"
    echo
}

# 检查是否已部署GPT Academic
function check_existing_deployment() {
    if docker ps -a --format '{{.Names}}' | grep -Eq "^gpt_academic"; then
        echo -e "${YELLOW}检测到已有的 GPT Academic 部署,直接进入主菜单...${NC}"
        main_menu
        exit 0
    fi
}

# 更新系统软件包
function update_system_packages() {
    echo -e "${BLUE}请选择更新软件包的方式:${NC}"
    echo "1. 仅更新软件包列表"
    echo "2. 更新软件包列表并升级系统软件包"
    echo "3. 更新软件包列表并升级所有软件包"
    echo

    while true; do
        read -p "请输入选项编号 (1-3): " update_choice
        case $update_choice in
            1)
                echo -e "${GREEN}正在更新软件包列表...${NC}"
                sudo apt update
                break
                ;;
            2)
                echo -e "${GREEN}正在更新软件包列表并升级系统软件包...${NC}"
                sudo apt update && sudo apt upgrade -y --no-install-recommends
                break
                ;;
            3)
                echo -e "${GREEN}正在更新软件包列表并升级所有软件包...${NC}"
                sudo apt update && sudo apt upgrade -y
                break
                ;;
            *)
                echo -e "${RED}无效的选择。请输入 1 到 3 之间的数字。${NC}"
                ;;
        esac
    done

    echo -e "${GREEN}系统更新完成。${NC}"
    echo
}

# 安装Docker及其依赖项
function install_docker() {
    echo -e "${BLUE}正在安装 Docker 及其依赖项...${NC}"
    sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update
    sudo apt install docker-ce docker-ce-cli containerd.io -y
}

# 验证Docker安装
function verify_docker_installation() {
    echo -e "${BLUE}正在验证 Docker 安装...${NC}"
    if ! sudo systemctl is-active docker >/dev/null 2>&1; then
        echo -e "${BLUE}正在启动 Docker 服务...${NC}"
        sudo systemctl start docker
    fi
    if sudo systemctl is-active docker >/dev/null 2>&1; then
        echo -e "${GREEN}Docker 安装成功并正在运行。${NC}"
    else
        echo -e "${RED}Docker 安装似乎出现了问题,它目前未在运行。${NC}"
        echo -e "${RED}请检查上述步骤的输出,以查找并解决问题。${NC}"
        exit 1
    fi
    echo
}

# 安装Docker Compose
function install_docker_compose() {
    echo -e "${BLUE}正在安装 Docker Compose...${NC}"
    sudo apt install docker-compose -y
    docker-compose --version
    echo
}

# 创建项目目录并进入
function create_and_enter_project_directory() {
    echo -e "${BLUE}正在创建项目目录...${NC}"
    mkdir -p gpt_academic
    cd gpt_academic
    echo -e "${GREEN}已进入项目目录: $(pwd)${NC}"
    echo
}

# 选择部署方案
function select_deployment_scheme() {
    echo -e "${BLUE}请选择您想要部署的方案:${NC}"
    echo "1. 部署 chatgpt,azure,星火,千帆,claude 等在线大模型方案(默认方案)"
    echo "2. 部署 ChatGLM、Qwen、MOSS 等本地模型方案"
    echo "3. 部署 ChatGPT、LLAMA、盘古、RWKV 本地模型方案"
    echo "4. 部署 ChatGPT + Latex 方案"
    echo "5. 部署 ChatGPT + 语音助手方案"
    echo "0. 部署项目的全部能力（包含 cuda 和 latex 的大型镜像）方案"
    echo

    while true; do
        read -p "请输入方案编号 (0-5): " scheme_choice
        case $scheme_choice in
            0|1|2|3|4|5)
                generate_compose_file $scheme_choice
                break
                ;;
            *)
                echo -e "${RED}无效的选择。请输入 0 到 5 之间的数字。${NC}"
                ;;
        esac
    done

    echo -e "${GREEN}docker-compose.yml 文件创建完成。${NC}"
    echo
}

# 生成docker-compose.yml文件
function generate_compose_file() {
    case $1 in
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
      AVAIL_LLM_MODELS: '["gpt4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      LOCAL_MODEL_DEVICE: "cuda"
      QWEN_LOCAL_MODEL_SELECTION: "Qwen/Qwen-1_8B-Chat-Int8"
    runtime: nvidia
    devices:
      - /dev/nvidia0:/dev/nvidia0
EOL
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
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
      LOCAL_MODEL_DEVICE: "cuda"
      CHATGLM_PTUNING_CHECKPOINT: ""
    runtime: nvidia
    devices:
      - /dev/nvidia0:/dev/nvidia0
EOL
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
            ;;
    esac
}

# 添加API_KEY
function add_api_key() {
    read -p "是否添加 API_KEY? [y/n]: " add_api_key
    if [[ $add_api_key =~ ^[Yy]$ ]]; then
        read -p "请输入 API KEY（多个 API KEY 请用英文字符 , 分开）: " api_key
        sed -i "s/API_KEY:.*/API_KEY: \"$api_key\"/g" docker-compose.yml
    fi
}

# 重定向URL链接
function redirect_url() {
    read -p "是否重定向 URL 链接? [y/n]: " redirect_url
    if [[ $redirect_url =~ ^[Yy]$ ]]; then
        read -p "请输入重定向链接（https://reverse-proxy-url/v1/chat/completions）: " redirect_link
        sed -i "/environment:/a \ \ \ \ \ \ API_URL_REDIRECT: '{\"https://api.openai.com/v1/chat/completions\": \"$redirect_link\"}'" docker-compose.yml
    fi
}

# 启动GPT Academic
function start_gpt_academic() {
    echo -e "${BLUE}正在启动 GPT Academic...${NC}"
    docker-compose up -d
    sleep 5
    check_container_status
    echo
}

# 检查容器运行状态
function check_container_status() {
    echo -e "${BLUE}正在检查容器运行状态...${NC}"
    if docker-compose ps | grep -q "Up"; then
        echo -e "${GREEN}GPT Academic 已成功启动。${NC}"
    else
        echo -e "${RED}GPT Academic 启动失败。请检查日志以查找问题。${NC}"
    fi
    echo
}

# 查看运行日志
function view_logs() {
    echo -e "${BLUE}正在查看 GPT Academic 的运行日志,按 Ctrl+C 退出...${NC}"
    echo -e "${YELLOW}注意: 如果日志显示不完整,请尝试调整终端窗口大小。${NC}"
    echo -e "${CYAN}========== GPT Academic 运行日志 ==========${NC}"
    docker-compose logs -f --tail 100
    echo -e "${CYAN}========== 日志查看结束 ==========${NC}"
    echo -e "${BLUE}按任意键返回主菜单...${NC}"
    read -n 1
    echo
}

# 备份配置文件
function backup_config() {
    local backup_file="docker-compose.yml.bak"
    cp docker-compose.yml $backup_file
    echo -e "${GREEN}docker-compose.yml 已备份为 $backup_file。${NC}"
}

# 还原配置文件
function restore_config() {
    local backup_file="docker-compose.yml.bak"
    if [ -f "$backup_file" ]; then
        mv $backup_file docker-compose.yml
        echo -e "${GREEN}docker-compose.yml 已从备份中还原。${NC}"
    else
        echo -e "${YELLOW}未找到 docker-compose.yml 的备份文件。${NC}"
    fi
}

# 修改API密钥
function modify_api_key() {
    echo -e "${BLUE}API 密钥修改选项:${NC}"
    echo "1. 查看已添加的 API KEY"
    echo "2. 添加 API KEY（增量添加）"
    echo "3. 添加 API KEY（覆盖添加）"
    echo "4. 删除所有 API KEY"
    echo "0. 返回上一级菜单"
    echo

    while true; do
        read -p "请输入选项编号 (0-4): " api_key_choice
        case $api_key_choice in
            1)
                echo -e "${BLUE}已添加的 API KEY:${NC}"
                grep -oP 'API_KEY: "\K[^"]+' docker-compose.yml
                ;;
            2)
                read -p "请输入要添加的 API KEY: " new_api_key
                current_api_key=$(grep -oP 'API_KEY: "\K[^"]+' docker-compose.yml)
                updated_api_key="$current_api_key,$new_api_key"
                sed -i "s/API_KEY:.*/API_KEY: \"$updated_api_key\"/g" docker-compose.yml
                echo -e "${GREEN}API KEY 已添加。${NC}"
                ;;
            3)
                read -p "请输入新的 API KEY（多个 API KEY 请用英文字符 , 分开）: " new_api_key
                sed -i "s/API_KEY:.*/API_KEY: \"$new_api_key\"/g" docker-compose.yml
                echo -e "${GREEN}API KEY 已更新。${NC}"
                ;;
            4)
                sed -i "s/API_KEY:.*/API_KEY: \"\"/g" docker-compose.yml
                echo -e "${GREEN}所有 API KEY 已删除。${NC}"
                ;;
            0)
                config_menu
                break
                ;;
            *)
                echo -e "${RED}无效的选择。请输入 0 到 4 之间的数字。${NC}"
                ;;
        esac
    done
}

# 修改多线程或请求速率
function modify_worker_num() {
    current_worker_num=$(grep -oP 'DEFAULT_WORKER_NUM: \K\d+' docker-compose.yml)
    echo -e "${BLUE}当前多线程数量: $current_worker_num${NC}"
    read -p "请输入新的多线程数量: " new_worker_num
    if [[ $new_worker_num =~ ^[0-9]+$ ]]; then
        sed -i "s/DEFAULT_WORKER_NUM:.*/DEFAULT_WORKER_NUM: $new_worker_num/g" docker-compose.yml
        echo -e "${GREEN}多线程数量已更新为 $new_worker_num。${NC}"
    else
        echo -e "${RED}无效的输入。请输入一个数字。${NC}"
    fi
}

# 修改其他配置
function modify_other_config() {
    echo -e "${BLUE}请选择要修改的其他配置:${NC}"
    echo "1. 代理设置"
    echo "2. 使用的 LLM 模型"
    echo "3. 可用的 LLM 模型列表"
    echo "0. 返回上一级菜单"
    echo

    while true; do
        read -p "请输入选项编号 (0-3): " other_config_choice
        case $other_config_choice in
            1)
                read -p "是否使用代理? (True/False): " use_proxy
                read -p "请输入代理地址和端口 (例如: socks5h://localhost:11284): " proxy_url
                sed -i "s/USE_PROXY:.*/USE_PROXY: \"$use_proxy\"/g" docker-compose.yml
                sed -i "s#PROXIES:.*#PROXIES: '{\"http\": \"$proxy_url\", \"https\": \"$proxy_url\"}'#g" docker-compose.yml
                echo -e "${GREEN}代理设置已更新。${NC}"
                ;;
            2)
                read -p "请输入要使用的 LLM 模型: " llm_model
                sed -i "s/LLM_MODEL:.*/LLM_MODEL: \"$llm_model\"/g" docker-compose.yml
                echo -e "${GREEN}LLM 模型已更新。${NC}"
                ;;
            3)
                echo -e "${BLUE}可用的 LLM 模型列表:${NC}"
                echo '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)", "moss", "qwen-turbo", "qwen-plus", "qwen-max", "zhipuai", "qianfan", "deepseekcoder", "llama2", "qwen-local", "gpt-3.5-turbo-0613", "gpt-3.5-turbo-16k-0613",  "gpt-3.5-random", "api2d-gpt-3.5-turbo", "api2d-gpt-3.5-turbo-16k", "spark", "sparkv2", "sparkv3", "chatglm_onnx", "claude-1-100k", "claude-2", "internlm", "jittorllms_pangualpha", "jittorllms_llama"]'
                read -p "请输入要使用的 LLM 模型列表（用引号和逗号分隔）: " llm_models
                sed -i "s/AVAIL_LLM_MODELS:.*/AVAIL_LLM_MODELS: '$llm_models'/g" docker-compose.yml
                echo -e "${GREEN}可用的 LLM 模型列表已更新。${NC}"
                ;;
            0)
                config_menu
                break
                ;;
            *)
                echo -e "${RED}无效的选择。请输入 0 到 3 之间的数字。${NC}"
                ;;
        esac
    done
}

# 配置菜单
function config_menu() {
    echo -e "${BLUE}请选择要修改的配置:${NC}"
    echo "1. API 密钥"
    echo "2. 多线程或请求速率"
    echo "3. 其他配置"
    echo "0. 返回主菜单"
    echo

    while true; do
        read -p "请输入选项编号 (0-3): " config_choice
        case $config_choice in
            1)
                modify_api_key
                break
                ;;
            2)
                modify_worker_num
                break
                ;;
            3)
                modify_other_config
                break
                ;;
            0)
                main_menu
                break
                ;;
            *)
                echo -e "${RED}无效的选择。请输入 0 到 3 之间的数字。${NC}"
                ;;
        esac
    done
}

# 主菜单
function main_menu() {
    echo -e "${PURPLE}=========================================================="
    echo -e "                  GPT Academic 管理菜单"
    echo -e "==========================================================${NC}"
    echo -e "${BLUE}请选择一个选项:${NC}"
    echo "1. 重新启动 GPT Academic"
    echo "2. 修改配置"
    echo "3. 查看运行日志"
    echo "4. 备份配置文件"
    echo "5. 还原配置文件"
    echo "0. 退出"
    echo

    while true; do
        read -p "请输入选项编号 (0-5): " menu_choice
        case $menu_choice in
            1)
                echo -e "${GREEN}正在重新启动 GPT Academic...${NC}"
                docker-compose down
                start_gpt_academic
                break
                ;;
            2)
                echo -e "${BLUE}进入配置修改菜单...${NC}"
                backup_config
                config_menu
                read -p "配置已修改,是否立即重启 GPT Academic 以应用更改? [y/n]: " restart_choice
                if [[ $restart_choice =~ ^[Yy]$ ]]; then
                    echo -e "${GREEN}正在重新启动 GPT Academic...${NC}"
                    docker-compose down
                    start_gpt_academic
                else
                    echo -e "${YELLOW}配置已修改,但 GPT Academic 尚未重启。下次重启时更改将生效。${NC}"
                fi
                break
                ;;
            3)
                view_logs
                break
                ;;
            4)
                backup_config
                break
                ;;
            5)
                restore_config
                read -p "配置已还原,是否立即重启 GPT Academic 以应用更改? [y/n]: " restart_choice
                if [[ $restart_choice =~ ^[Yy]$ ]]; then
                    echo -e "${GREEN}正在重新启动 GPT Academic...${NC}"
                    docker-compose down
                    start_gpt_academic
                else
                    echo -e "${YELLOW}配置已还原,但 GPT Academic 尚未重启。下次重启时更改将生效。${NC}"
                fi
                break
                ;;
            0)
                echo -e "${PURPLE}感谢您使用 GPT Academic 管理脚本,再见!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}无效的选择。请输入 0 到 5 之间的数字。${NC}"
                ;;
        esac
    done
}

# 主程序
function main() {
    display_logo
    create_and_enter_project_directory
    check_docker_compose
    if [ $? -eq 0 ]; then
        update_system_packages
        install_docker
        verify_docker_installation
        install_docker_compose
        select_deployment_scheme
        add_api_key
        redirect_url
        start_gpt_academic
    fi
    main_menu
}

main

# 添加快捷命令
script_path=$(realpath "$0")
script_dir=$(dirname "$script_path")
echo "alias gptadmin='cd $script_dir/gpt_academic && bash $script_path'" >> ~/.bashrc
source ~/.bashrc
echo -e "${GREEN}快捷命令 'gptadmin' 已添加,可以在终端输入 'gptadmin' 快速打开管理菜单。${NC}"