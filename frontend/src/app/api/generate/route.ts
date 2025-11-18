import { NextRequest, NextResponse } from 'next/server'
import { demoStore } from '@/lib/demo-store'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8787'
const IS_DEMO_MODE = process.env.NEXT_PUBLIC_DEMO_MODE === 'true'

export async function POST(request: NextRequest) {
  const body = await request.json()

  // 演示模式
  if (IS_DEMO_MODE) {
    const { prompt, provider, model, size = '1024x1024' } = body

    // 创建任务
    const task = demoStore.createTask({
      prompt,
      provider,
      model,
      status: 'processing'
    })

    // 模拟异步处理
    setTimeout(async () => {
      // 使用随机图片作为演示结果
      const imageUrl = `https://picsum.photos/seed/${encodeURIComponent(prompt)}/1024/1024.jpg`

      demoStore.updateTask(task.id, {
        status: 'completed',
        imageUrl,
        completedAt: new Date().toISOString()
      })
    }, 2000 + Math.random() * 3000) // 2-5秒随机延迟

    return NextResponse.json({
      success: true,
      task_id: task.id,
      message: '图像生成任务已创建（演示模式）'
    })
  }

  // 正常模式调用后端API
  try {
    const response = await fetch(`${API_BASE_URL}/v1/generate`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    })

    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}))
      return NextResponse.json(
        { error: errorData.detail || '创建生成任务失败' },
        { status: response.status }
      )
    }

    const data = await response.json()
    return NextResponse.json(data)
  } catch (error) {
    console.error('创建生成任务时出错:', error)
    return NextResponse.json(
      { error: '服务器错误' },
      { status: 500 }
    )
  }
}