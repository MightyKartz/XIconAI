// 演示模式的任务存储
export interface DemoTask {
  id: string
  prompt: string
  provider: string
  model: string
  status: 'processing' | 'completed' | 'failed'
  imageUrl?: string
  error?: string
  createdAt: string
  completedAt?: string
}

export interface DemoConfig {
  provider: string
  apiKey: string
  model: string
  baseUrl?: string
  maxTokens?: number
  temperature?: number
}

class DemoStore {
  private tasks: DemoTask[] = []
  private config: DemoConfig | null = null

  // 任务管理
  createTask(task: Omit<DemoTask, 'id' | 'createdAt'>): DemoTask {
    const newTask: DemoTask = {
      ...task,
      id: `demo_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
      createdAt: new Date().toISOString()
    }
    this.tasks.push(newTask)
    return newTask
  }

  getTask(taskId: string): DemoTask | undefined {
    return this.tasks.find(t => t.id === taskId)
  }

  updateTask(taskId: string, updates: Partial<DemoTask>): DemoTask | null {
    const taskIndex = this.tasks.findIndex(t => t.id === taskId)
    if (taskIndex !== -1) {
      this.tasks[taskIndex] = { ...this.tasks[taskIndex], ...updates }
      return this.tasks[taskIndex]
    }
    return null
  }

  getAllTasks(): DemoTask[] {
    return [...this.tasks]
  }

  // 配置管理
  saveConfig(config: DemoConfig): void {
    this.config = { ...config, apiKey: '***demo***' }
  }

  getConfig(): DemoConfig | null {
    return this.config
  }

  clearConfig(): void {
    this.config = null
  }

  // 清理旧任务（保留最近50个）
  cleanup(): void {
    if (this.tasks.length > 50) {
      this.tasks = this.tasks.slice(-50)
    }
  }
}

// 创建单例实例
export const demoStore = new DemoStore()

// 定期清理
setInterval(() => {
  demoStore.cleanup()
}, 60000) // 每分钟清理一次