#!/bin/bash

# Icons 免费版本部署脚本
# 支持一键部署到 Vercel (前端) + Railway (后端)

set -e

echo "🚀 开始部署 Icons 免费版本..."

# 检查必要工具
command -v vercel >/dev/null 2>&1 || { echo "❌ 需要安装 Vercel CLI: npm i -g vercel"; exit 1; }
command -v railway >/dev/null 2>&1 || { echo "❌ 需要安装 Railway CLI: npm i -g @railway/cli"; exit 1; }

# 检查环境变量
if [ -z "$MODELSCOPE_API_KEY" ]; then
    echo "⚠️  警告: 未设置 MODELSCOPE_API_KEY 环境变量"
    echo "   请设置环境变量: export MODELSCOPE_API_KEY=your_key"
fi

if [ -z "$DASHSCOPE_API_KEY" ]; then
    echo "⚠️  警告: 未设置 DASHSCOPE_API_KEY 环境变量"
    echo "   请设置环境变量: export DASHSCOPE_API_KEY=your_key"
fi

echo ""
echo "📦 部署后端服务到 Railway..."

# 部署后端到 Railway
cd backend
railway login
railway init
railway up

# 获取后端URL
BACKEND_URL=$(railway domain)
echo "✅ 后端部署完成: $BACKEND_URL"

cd ..

echo ""
echo "🎨 部署前端服务到 Vercel..."

# 更新前端环境变量
echo "NEXT_PUBLIC_API_BASE_URL=https://$BACKEND_URL/v1" > frontend/.env.local

# 部署前端到 Vercel
cd frontend
vercel --prod

# 获取前端URL
FRONTEND_URL=$(vercel alias ls | grep icons-free | awk '{print $2}')
echo "✅ 前端部署完成: $FRONTEND_URL"

cd ..

echo ""
echo "🎉 部署完成！"
echo ""
echo "📱 前端地址: $FRONTEND_URL"
echo "🔧 后端地址: https://$BACKEND_URL"
echo ""
echo "📋 下一步操作:"
echo "1. 访问前端地址测试应用"
echo "2. 在设置中配置 AI 提供商 API 密钥"
echo "3. 开始生成图标！"
echo ""
echo "💡 提示:"
echo "- OpenAI、Anthropic、Stability AI 等需要付费 API 密钥"
echo "- 可以在 Railway 控制台监控后端服务状态"