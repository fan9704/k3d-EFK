#!/bin/bash

# 定義顏色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'    # No Color

echo "${CYAN}🚀 開始安裝 K3d${NC}"
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

echo "${CYAN}⚙️ 開始安裝 Kubectl${NC}"
# 下載最新穩定版本的 Kubectl (根據架構自動判斷)
ARCH=$(uname -m)
KUBECTL_URL="https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl"
echo "${YELLOW}📥 下載 Kubectl 從: ${BLUE}${KUBECTL_URL}${NC}"
curl -LO "${KUBECTL_URL}"

# 驗證 Kubectl
SHA256_URL="https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${ARCH}/kubectl.sha256"
echo "${YELLOW}📥 下載 Kubectl SHA256 從: ${BLUE}${SHA256_URL}${NC}"
curl -LO "${SHA256_URL}"
echo "${YELLOW}🔒 驗證 Kubectl 下載...${NC}"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
if [ $? -eq 0 ]; then
  echo "${GREEN}✅ Kubectl 驗證成功!${NC}"
else
  echo "${RED}❌ Kubectl 驗證失敗! 請檢查下載檔案。${NC}"
  exit 1
fi

# 安裝 Kubectl
echo "${YELLOW}💾 開始安裝 Kubectl 到 /usr/local/bin${NC}"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo "${GREEN}✅ Kubectl 安裝完成!${NC}"

# 檢查 Kubectl 版本
echo "${YELLOW}🔍 檢查 Kubectl 版本...${NC}"
kubectl version

# 匯出 k3d context 到 kubectl
echo "${YELLOW}✍️ 匯出 k3d context 到 kubectl...${NC}"
export KUBECONFIG="$(k3d kubeconfig write k3s-default)"
echo "${GREEN}✅ k3d context 已匯出!${NC}"

# 建立 k3d 預設叢集 [k3s-default]
echo "${YELLOW}✨ 建立 k3d 預設叢集 [k3s-default]...${NC}"
k3d cluster create
echo "${GREEN}✅ k3d 叢集建立完成!${NC}"

# 列出叢集
echo "${YELLOW}📜 列出 k3d 叢集...${NC}"
k3d cluster list

# 列出節點
echo "${YELLOW}<0xF0><0x9F><0x9B><0xA1>️ 列出 k3d 節點...${NC}"
k3d node list

# kubectl cluster-info
echo "${YELLOW}ℹ️ 取得 Kubernetes 叢集資訊...${NC}"
kubectl cluster-info

echo "${GREEN}🎉 [安裝完成] Powered By FKT${NC}"