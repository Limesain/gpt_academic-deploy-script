cat > deploy_gpt_academic.sh <<'EOL'
#!/bin/bash

echo "正在更新软件包列表并升级系统..."
sudo apt update && sudo apt upgrade -y --no-install-recommends
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

read -p "请输入方案编号 (0-5): " scheme_choice

case $scheme_choice in
  0)
    image="ghcr.io/binary-husky/gpt_academic_with_all_capacity:master"
    ;;
  1)
    image="ghcr.io/binary-husky/gpt_academic_nolocal:master"
    ;;
  2)
    image="ghcr.io/binary-husky/gpt_academic_chatglm_moss:master"
    ;;
  3)
    image="ghcr.io/binary-husky/gpt_academic_jittorllms:master"
    ;;
  4)
    image="ghcr.io/binary-husky/gpt_academic_with_latex:master"
    ;;
  5)
    image="ghcr.io/binary-husky/gpt_academic_audio_assistant:master"
    ;;
  *)
    echo "无效的选择。请输入 0 到 5 之间的数字。"
    exit 1
    ;;
esac

echo "正在创建docker-compose.yml文件..."
cat > docker-compose.yml <<EOL
version: '3'
services:
  gpt_academic:
    image: $image
    environment:
      API_KEY: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx,sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"      
      USE_PROXY: "False"  
      LLM_MODEL: "gpt-3.5-turbo-0125"
      AVAIL_LLM_MODELS: '["gpt-4-0125-preview", "gpt-4-turbo-preview", "gpt-4-vision-preview", "gpt-3.5-turbo-0125", "gpt-3.5-turbo-16k", "gpt-3.5-turbo", "azure-gpt-3.5", "gpt-4", "gpt-4-32k", "azure-gpt-4", "glm-4", "glm-3-turbo", "gemini-pro", "chatglm3", "one-api-claude-3-sonnet-20240229(max_token=100000)"]'
      WEB_PORT: "-1"
      ADD_WAIFU: "False"
EOL

# ... 根据用户选择的方案,添加特定的配置 ...

echo "是否需要配置URL重定向? (Y/N): "
read redirect_choice

if [[ $redirect_choice =~ ^[Yy]$ ]]; then
    echo "请输入要重定向的URL: "
    read redirect_url
    echo "API_URL_REDIRECT = {\"https://api.openai.com/v1/chat/completions\": \"$redirect_url\"}" >> docker-compose.yml
fi

echo "docker-compose.yml文件创建完成。"

echo "正在启动GPT Academic项目..."
docker-compose up -d
echo "GPT Academic项目已启动。"

echo "正在检查容器运行状态..."
docker-compose ps
docker-compose logs gpt_academic
echo "容器运行状态检查完成。"