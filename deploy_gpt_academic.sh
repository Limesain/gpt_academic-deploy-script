#!/bin/bash

echo "欢迎使用GPT Academic一键部署脚本!"
read -p "是否开始部署? (Y/N): " start_choice

if [[ ! $start_choice =~ ^[Yy]$ ]]; then
    echo "部署已取消,脚本终止。"
    exit 0
fi

echo "请选择更新软件包的方式:"
echo "1. 仅更新软件包列表"
echo "2. 更新软件包列表并升级系统软件包"
echo "3. 更新软件包列表并升级所有软件包"

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

echo "正在安装Docker依赖项..."
sudo apt install apt-transport-https ca-certificates curl gnupg lsb-release -y
echo "Docker依赖项安装完成。"

echo "正在添加Docker GPG密钥..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "Docker GPG密钥添加完成。"

echo "正在添加Docker稳定版仓库..."
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo "Docker稳定版仓库添加完成。"

echo "正在安装Docker..."
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
echo "Docker安装完成。"

echo "正在验证Docker安装..."
if sudo systemctl is-active docker >/dev/null 2>&1; then
    echo "Docker安装成功并正在运行。"
else
    echo "Docker安装似乎出现了问题,它目前未在运行。"
    echo "请检查上述步骤的输出,以查找并解决问题。"
    exit 1
fi

echo "正在安装Docker Compose..."
sudo apt install docker-compose -y
echo "Docker Compose安装完成。"

echo "正在验证Docker Compose版本..."
docker-compose --version
echo "Docker Compose验证完成。"

echo "正在创建项目目录..."
mkdir -p gpt_academic
cd gpt_academic
echo "项目目录创建完成。"

echo "请选择您想要部署的方案:"
echo "0. 部署项目的全部能力（包含cuda和latex的大型镜像）"
echo "1. 如果不需要运行本地模型（仅 chatgpt, azure, 星火, 千帆, claude 等在线大模型服务）"
echo "2. 如果需要运行ChatGLM + Qwen + MOSS等本地模型"
echo "3. 如果需要运行ChatGPT + LLAMA + 盘古 + RWKV本地模型"
echo "4. ChatGPT + Latex"
echo "5. ChatGPT + 语音助手"

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

echo "docker-compose.yml文件创建完成。"

echo "正在启动GPT Academic项目..."
docker-compose up -d
echo "GPT Academic项目已启动。"

echo "正在检查容器运行状态..."
docker-compose ps
docker-compose logs
echo "容器运行状态检查完成。"