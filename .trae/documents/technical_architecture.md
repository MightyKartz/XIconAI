# Icons - 技术架构设计文档

## 1. 架构概览

### 1.1 整体架构
```
┌─────────────────────────────────────────────────────────────┐
│                    macOS Client (SwiftUI)                  │
├─────────────────────────────────────────────────────────────┤
│  UI Layer    │  Business Logic  │  Data Layer  │  Services │
│  - Views     │  - ViewModels    │  - Core Data │  - Network│
│  - Controls  │  - Managers      │  - UserDef.  │  - Image  │
│  - Modifiers │  - Coordinators  │  - FileSystem│  - Export │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API Layer                       │
├─────────────────────────────────────────────────────────────┤
│  Gateway     │  Auth Service   │  Generation  │  Storage   │
│  - Rate Limit│  - StoreKit     │  - AI Proxy  │  - Temp    │
│  - Validation│  - Subscription │  - Queue     │  - Cache   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   External AI Services                     │
├─────────────────────────────────────────────────────────────┤
│  ModelScope API          │  Alibaba Cloud Qwen-Image      │
│  - Qwen/Qwen-Image      │  - Commercial License          │
│  - Free Tier            │  - Higher Quality               │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 技术栈选择

#### 客户端技术栈
- **开发语言**：Swift 5.9+
- **UI框架**：SwiftUI + 部分 AppKit
- **架构模式**：MVVM + Coordinator
- **状态管理**：ObservableObject + @StateObject
- **数据持久化**：Core Data + UserDefaults
- **网络层**：URLSession + Combine
- **图像处理**：Core Image + vImage
- **支付系统**：StoreKit 2

#### 后端技术栈
- **开发语言**：Node.js + TypeScript
- **Web框架**：Express.js
- **数据库**：PostgreSQL + Redis
- **认证授权**：JWT + App Store Receipt Validation
- **API文档**：OpenAPI 3.0 + Swagger
- **部署方式**：Docker + Kubernetes

## 2. 客户端架构设计

### 2.1 项目结构
```
Icons/
├── App/
│   ├── IconsApp.swift              # 应用入口
│   ├── AppDelegate.swift           # 应用代理
│   └── SceneDelegate.swift         # 场景代理
├── Core/
│   ├── Managers/
│   │   ├── NetworkManager.swift    # 网络管理
│   │   ├── ImageManager.swift      # 图像处理
│   │   ├── ExportManager.swift     # 导出管理
│   │   ├── SubscriptionManager.swift # 订阅管理
│   │   └── TemplateManager.swift   # 模板管理
│   ├── Services/
│   │   ├── AIService.swift         # AI生成服务
│   │   ├── SFSymbolService.swift   # SF符号服务
│   │   └── AnalyticsService.swift  # 分析服务
│   └── Utils/
│       ├── Extensions/             # 扩展
│       ├── Constants.swift         # 常量
│       └── Helpers.swift          # 辅助函数
├── Features/
│   ├── Onboarding/                # 引导页
│   ├── ProjectCreation/           # 项目创建
│   ├── TemplateSelection/         # 模板选择
│   ├── PromptEditor/              # Prompt编辑
│   ├── SFSymbolBrowser/           # SF符号浏览
│   ├── IconGeneration/            # 图标生成
│   ├── IconEditor/                # 图标编辑
│   ├── Export/                    # 导出功能
│   ├── History/                   # 历史记录
│   ├── Subscription/              # 订阅管理
│   └── Settings/                  # 设置页面
├── Models/
│   ├── Project.swift             # 项目模型
│   ├── Template.swift            # 模板模型
│   ├── GenerationRequest.swift   # 生成请求
│   ├── GenerationResult.swift    # 生成结果
│   └── User.swift                # 用户模型
├── Resources/
│   ├── Assets.xcassets           # 资源文件
│   ├── Templates/                # 内置模板
│   └── Localizable.strings       # 本地化
└── Tests/
    ├── UnitTests/                # 单元测试
    └── UITests/                  # UI测试
```

### 2.2 核心组件设计

#### 2.2.1 网络层架构
```swift
// 网络管理器
class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    private let session: URLSession
    private let baseURL: URL
    
    // API 请求方法
    func request<T: Codable>(
        endpoint: APIEndpoint,
        responseType: T.Type
    ) async throws -> T
    
    // 图片上传
    func uploadImage(
        _ image: NSImage,
        to endpoint: APIEndpoint
    ) async throws -> UploadResponse
}

// API 端点定义
enum APIEndpoint {
    case generateIcon(request: GenerationRequest)
    case validateSubscription(receipt: String)
    case getTemplates
    case uploadFeedback(GenerationFeedback)
    
    var path: String { /* 实现 */ }
    var method: HTTPMethod { /* 实现 */ }
    var headers: [String: String] { /* 实现 */ }
}
```

#### 2.2.2 状态管理架构
```swift
// 应用状态管理
class AppState: ObservableObject {
    @Published var currentProject: Project?
    @Published var user: User?
    @Published var subscriptionStatus: SubscriptionStatus
    @Published var isGenerating: Bool = false
    @Published var generationProgress: Double = 0.0
}

// 项目状态管理
class ProjectViewModel: ObservableObject {
    @Published var project: Project
    @Published var selectedTemplate: Template?
    @Published var promptText: String = ""
    @Published var selectedSFSymbol: SFSymbol?
    @Published var generationResults: [GenerationResult] = []
    
    func generateIcon() async {
        // 生成逻辑
    }
    
    func exportProject() async {
        // 导出逻辑
    }
}
```

#### 2.2.3 数据持久化架构
```swift
// Core Data 模型
@objc(ProjectEntity)
class ProjectEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var name: String
    @NSManaged var promptText: String
    @NSManaged var templateID: String?
    @NSManaged var createdAt: Date
    @NSManaged var updatedAt: Date
    @NSManaged var results: Set<GenerationResultEntity>
}

// 数据管理器
class DataManager: ObservableObject {
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Icons")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
```

### 2.3 UI组件架构

#### 2.3.1 主界面布局
```swift
struct MainView: View {
    @StateObject private var appState = AppState()
    @StateObject private var projectVM = ProjectViewModel()
    
    var body: some View {
        NavigationSplitView {
            // 左侧边栏：模板选择
            TemplateSidebarView()
        } content: {
            // 中央内容：Prompt编辑 + 生成结果
            ContentView()
        } detail: {
            // 右侧面板：属性编辑
            PropertyPanelView()
        }
        .environmentObject(appState)
        .environmentObject(projectVM)
    }
}
```

#### 2.3.2 可复用组件
```swift
// 模板卡片组件
struct TemplateCard: View {
    let template: Template
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        VStack {
            AsyncImage(url: template.previewURL) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 120, height: 120)
            
            Text(template.name)
                .font(.caption)
        }
        .padding()
        .background(isSelected ? Color.accentColor : Color.clear)
        .cornerRadius(8)
        .onTapGesture(perform: onSelect)
    }
}

// 生成进度组件
struct GenerationProgressView: View {
    let progress: Double
    let status: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView(value: progress)
                .progressViewStyle(CircularProgressViewStyle())
            
            Text(status)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}
```

## 3. 后端架构设计

### 3.1 API 服务架构
```typescript
// Express 应用结构
app/
├── src/
│   ├── controllers/
│   │   ├── GenerationController.ts    # 生成控制器
│   │   ├── AuthController.ts          # 认证控制器
│   │   ├── TemplateController.ts      # 模板控制器
│   │   └── SubscriptionController.ts  # 订阅控制器
│   ├── services/
│   │   ├── AIService.ts               # AI服务代理
│   │   ├── ImageService.ts            # 图像处理服务
│   │   ├── SubscriptionService.ts     # 订阅验证服务
│   │   └── RateLimitService.ts        # 限流服务
│   ├── middleware/
│   │   ├── auth.ts                    # 认证中间件
│   │   ├── rateLimit.ts               # 限流中间件
│   │   └── validation.ts              # 参数验证
│   ├── models/
│   │   ├── User.ts                    # 用户模型
│   │   ├── Generation.ts              # 生成记录
│   │   └── Subscription.ts            # 订阅模型
│   ├── routes/
│   │   ├── api.ts                     # API路由
│   │   └── health.ts                  # 健康检查
│   └── utils/
│       ├── logger.ts                  # 日志工具
│       ├── config.ts                  # 配置管理
│       └── errors.ts                  # 错误处理
├── tests/
├── docker/
└── docs/
```

### 3.2 核心API设计

#### 3.2.1 图标生成API
```typescript
// POST /api/v1/generate
interface GenerationRequest {
  prompt: string;
  templateId?: string;
  sfSymbol?: string;
  style?: {
    intensity: number;  // 0.0 - 1.0
    colorScheme?: 'light' | 'dark' | 'auto';
  };
  options?: {
    resolution: '512x512' | '1024x1024';
    format: 'png' | 'jpg';
    count: number;  // 1-3
  };
}

interface GenerationResponse {
  id: string;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  results?: {
    id: string;
    imageUrl: string;
    thumbnailUrl: string;
    metadata: {
      prompt: string;
      model: string;
      parameters: Record<string, any>;
    };
  }[];
  error?: string;
}
```

#### 3.2.2 订阅验证API
```typescript
// POST /api/v1/subscription/validate
interface SubscriptionValidationRequest {
  receiptData: string;  // Base64 encoded receipt
  bundleId: string;
}

interface SubscriptionValidationResponse {
  isValid: boolean;
  subscription?: {
    productId: string;
    expiresDate: string;
    isTrialPeriod: boolean;
    autoRenewStatus: boolean;
  };
  quotas: {
    daily: { used: number; limit: number };
    monthly: { used: number; limit: number };
  };
}
```

### 3.3 数据库设计

#### 3.3.1 用户表
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    device_id VARCHAR(255) UNIQUE NOT NULL,
    subscription_status VARCHAR(50) DEFAULT 'free',
    subscription_expires_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_quotas (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    quota_type VARCHAR(50) NOT NULL, -- 'daily', 'monthly'
    used_count INTEGER DEFAULT 0,
    limit_count INTEGER NOT NULL,
    reset_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

#### 3.3.2 生成记录表
```sql
CREATE TABLE generations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id),
    prompt TEXT NOT NULL,
    template_id VARCHAR(100),
    sf_symbol VARCHAR(100),
    parameters JSONB,
    status VARCHAR(50) DEFAULT 'pending',
    result_urls TEXT[],
    error_message TEXT,
    ai_model VARCHAR(100),
    processing_time_ms INTEGER,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

CREATE INDEX idx_generations_user_id ON generations(user_id);
CREATE INDEX idx_generations_status ON generations(status);
CREATE INDEX idx_generations_created_at ON generations(created_at);
```

## 4. 安全架构

### 4.1 客户端安全
- **API密钥保护**：不在客户端存储任何API密钥
- **证书绑定**：使用证书绑定防止中间人攻击
- **数据加密**：敏感数据本地加密存储
- **代码混淆**：发布版本进行代码混淆

### 4.2 服务端安全
- **HTTPS强制**：所有API强制使用HTTPS
- **JWT认证**：基于JWT的无状态认证
- **限流保护**：API限流防止滥用
- **输入验证**：严格的输入参数验证
- **SQL注入防护**：使用参数化查询

### 4.3 数据安全
- **数据脱敏**：日志中敏感信息脱敏
- **访问控制**：基于角色的访问控制
- **审计日志**：完整的操作审计日志
- **备份加密**：数据库备份加密存储

## 5. 性能优化

### 5.1 客户端优化
- **图像缓存**：智能图像缓存策略
- **懒加载**：列表和图像懒加载
- **内存管理**：及时释放大图像内存
- **后台处理**：耗时操作后台执行

### 5.2 服务端优化
- **连接池**：数据库连接池管理
- **缓存策略**：Redis缓存热点数据
- **CDN加速**：静态资源CDN分发
- **负载均衡**：多实例负载均衡

### 5.3 AI服务优化
- **请求合并**：批量处理相似请求
- **结果缓存**：缓存常见生成结果
- **降级策略**：服务不可用时的降级方案
- **重试机制**：智能重试机制

## 6. 监控与运维

### 6.1 应用监控
- **性能监控**：响应时间、内存使用
- **错误监控**：崩溃率、错误日志
- **用户行为**：功能使用统计
- **业务指标**：生成成功率、转化率

### 6.2 基础设施监控
- **服务器监控**：CPU、内存、磁盘
- **数据库监控**：连接数、查询性能
- **网络监控**：带宽、延迟
- **第三方服务**：AI API可用性

### 6.3 告警机制
- **阈值告警**：关键指标超阈值告警
- **异常检测**：基于机器学习的异常检测
- **多渠道通知**：邮件、短信、Slack
- **自动恢复**：部分故障自动恢复

## 7. 部署架构

### 7.1 容器化部署
```yaml
# docker-compose.yml
version: '3.8'
services:
  api:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=${DATABASE_URL}
      - REDIS_URL=${REDIS_URL}
    depends_on:
      - postgres
      - redis
  
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_DB=icons
      - POSTGRES_USER=${DB_USER}
      - POSTGRES_PASSWORD=${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
```

### 7.2 CI/CD流水线
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run tests
        run: |
          npm install
          npm test
  
  deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          docker build -t icons-api .
          docker push ${{ secrets.REGISTRY_URL }}/icons-api
          kubectl apply -f k8s/
```

## 8. 扩展性设计

### 8.1 水平扩展
- **无状态设计**：API服务无状态，支持水平扩展
- **数据库分片**：按用户ID分片存储
- **缓存集群**：Redis集群支持
- **CDN分发**：全球CDN节点

### 8.2 功能扩展
- **插件架构**：支持第三方模板插件
- **API开放**：开放API供第三方集成
- **多平台支持**：iOS、Web版本扩展
- **AI模型扩展**：支持更多AI模型

---

**文档版本**：v1.0  
**创建日期**：2024年12月  
**负责人**：技术架构师  
**审核人**：CTO