import { NextRequest, NextResponse } from 'next/server'

// 模拟的演示数据
const mockProviders = [
  {
    id: "openai",
    name: "OpenAI",
    models: ["dall-e-3", "dall-e-2"],
    description: "高质量的AI图像生成",
    pricing: "付费"
  },
  {
    id: "anthropic",
    name: "Anthropic",
    models: ["claude-3-opus-20240229", "claude-3-sonnet-20240229"],
    description: "强大的多模态AI",
    pricing: "付费"
  },
  {
    id: "stability",
    name: "Stability AI",
    models: ["stable-diffusion-xl", "stable-diffusion-3"],
    description: "开源图像生成模型",
    pricing: "付费"
  }
]

// 存储演示配置的内存存储
let demoConfigs: Array<{provider: string, apiKey: string, model: string}> = []
let demoTasks: Array<{id: string, status: string, prompt: string, imageUrl?: string}> = []

export async function GET(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const type = searchParams.get('type')

  if (type === 'providers') {
    return NextResponse.json({ providers: mockProviders })
  }

  if (type === 'config') {
    const config = demoConfigs[demoConfigs.length - 1]
    if (config) {
      return NextResponse.json({ success: true, config })
    }
    return NextResponse.json({ success: false, error: '未找到配置' })
  }

  if (type === 'tasks') {
    return NextResponse.json({ tasks: demoTasks })
  }

  return NextResponse.json({ message: 'Demo API is running' })
}

export async function POST(request: NextRequest) {
  const { searchParams } = new URL(request.url)
  const type = searchParams.get('type')

  try {
    const body = await request.json()

    if (type === 'config') {
      // 保存配置
      demoConfigs.push(body)
      return NextResponse.json({ success: true })
    }

    if (type === 'test') {
      // 模拟连接测试
      const { provider } = body
      const isValidProvider = mockProviders.some(p => p.id === provider)

      if (isValidProvider) {
        return NextResponse.json({
          success: true,
          message: `${provider} 连接测试成功（演示模式）`
        })
      } else {
        return NextResponse.json({
          success: false,
          message: '不支持的提供商'
        })
      }
    }

    if (type === 'generate') {
      // 模拟图像生成
      const taskId = `demo_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`
      const { prompt, provider, model } = body

      demoTasks.push({
        id: taskId,
        status: 'processing',
        prompt,
        imageUrl: undefined
      })

      // 模拟异步处理
      setTimeout(() => {
        const taskIndex = demoTasks.findIndex(t => t.id === taskId)
        if (taskIndex !== -1) {
          demoTasks[taskIndex] = {
            ...demoTasks[taskIndex],
            status: 'completed',
            imageUrl: `https://picsum.photos/seed/${encodeURIComponent(prompt)}/512/512.jpg`
          }
        }
      }, 2000 + Math.random() * 2000)

      return NextResponse.json({
        success: true,
        task_id: taskId,
        message: '图像生成任务已创建（演示模式）'
      })
    }

    return NextResponse.json({ error: '未知的请求类型' }, { status: 400 })

  } catch (error) {
    console.error('Demo API error:', error)
    return NextResponse.json({ error: '服务器错误' }, { status: 500 })
  }
}