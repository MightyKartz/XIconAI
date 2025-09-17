# Icons 项目规则（Project Rules）

本规则基于《开发方案.md》制定，约束工程实现、产品边界与合规要求，所有提交必须遵循。

1. 范围与目标
- 目标：生成 iOS/macOS 应用图标并一键导出 .appiconset/.iconset，支持 Free 与 Pro 分级体验。
- 平台：macOS 13+，Swift + SwiftUI，必要时使用 AppKit 集成功能（如 NSOpenPanel/Services）。

2. 架构与安全
- 绝不在客户端存放生产 API Key。所有模型调用走中间层（推荐），由后端保存密钥并签发短期 token。
- 中间层负责：用户等级判定、配额与计费统计、优先级队列、失败重试/降级（Alibaba 不可用时回退 ModelScope）。
- 日志与隐私：默认不记录完整 prompt，可保存哈希；严禁输出/记录密钥与敏感信息。

3. 产品分级与配额
- Free：每天 2 次，512×512，自动水印，模板最多 3 种，非商用。
- Pro：1024×1024，无水印，高优先级队列；默认每月 100 张（或“不限但优先”策略按后端配置）。
- 防滥用：单用户并发 ≤ 3；IP/设备限流；基础敏感词审核。

4. 模型接入
- Free → ModelScope API-Inference；Pro → Alibaba Cloud Qwen-Image（后端转发/存储后回传）。
- 需实现优先队列与任务状态查询，异常时自动重试与降级提示。

5. Prompt 与模板
- 模板采用占位符（如 {style}/{app_name}/{sf_symbol}/{palette}/{negative_prompts}）。
- 内置 10–20 个风格化示例；支持 SF Symbols 搜索与注入名称，或本地矢量 overlay 合成。

6. 导出规范（必须）
- 生成完整 .appiconset/.iconset：高分辨率底图（≥1024）→ vImage/CGImage 高质量缩放 → 多尺寸 PNG。
- Contents.json 必含 images[].{idiom,size,scale,filename} 与 info 节点；确保 Xcode 正确解析。
- iOS 常见尺寸（示例）：20/29/40/58/60/76/80/87/120/152/167/180/1024 等（按 Apple 最新要求维护）。
- macOS .iconset：16/32/64/128/256/512/1024（含 @2x），可用 iconutil 生成 .icns。

7. 后端 API（建议）
- POST /v1/generate → {task_id}
- GET /v1/task/{task_id} → 状态与图片 URL/base64
- GET /v1/quota → 剩余次数与订阅状态
- POST /v1/receipt/verify → 收据校验与订阅同步

8. UI/UX 基线
- 首页：左侧模板栏；中央画布（1:1/2x 预览）；右侧属性面板（颜色、风格强度、SF Symbol）。
- 默认一次生成 3 个候选；支持颜色/符号替换与再生成微调。
- 导出对话：选择平台/尺寸、是否含 alpha、命名前缀、是否打包 ZIP。
- 超限弹窗：引导升级 Pro，并清晰说明权益与限制。

9. 测试与质量
- 单测：Prompt 格式化、Contents.json 生成、PNG 尺寸正确性、配额计数器。
- 集成：中间层 ↔ ModelScope/Alibaba，对断网/超时/重试覆盖。
- UI 自动化：关键流程（生成→预览→导出）。
- 手动回归：将 .appiconset 导入真实 Xcode 项目验证兼容性（必做）。

10. 上架与合规
- 明示模型来源（ModelScope/Alibaba Qwen）；EULA 与订阅条款明确商用授权范围（Pro）。
- 审核关注点：生成内容的审核与年龄限制、举报与条款入口。
- 支付：订阅走 StoreKit；若有超量/按次计费，优先使用 IAP（consumable/非消耗型）合规实现。

11. 里程碑（MVP → V1）
- MVP：客户端生成/导出与模板浏览；中间层 PoC；订阅集成；测试与上架准备（参考 8–11 周估算）。

12. 监控与指标
- KPI：DAU、月度生成次数、免费→Pro 转化、ARPU、失败率与延迟、API 成本（¥/张）。
- 告警：失败率>5%/队列堆积阈值预警；成本面板按来源/用户维度汇总。

13. 扩展方向
- 批量生成与团队版；企业本地部署；SVG/矢量化；Figma/Sketch/Xcode 插件直连。

14. 工程规范
- 代码：遵循 Swift API Design Guidelines；SwiftUI 组件化、状态单向流；避免在主线程做 IO/网络/重计算。
- 图像处理：必须使用 vImage/CGImage 高质量重采样，保证小尺寸清晰与颜色准确。
- 错误处理：统一 Error 类型与用户提示；提供可见的降级策略与重试入口。
- 配置：以配置驱动尺寸与导出（如 icon-sizes.json），严禁硬编码到多处。

15. 目录与交付物约定
- 交付前必须提供：可运行的 macOS .app（签名+notarize）、中间层代码与部署脚本、模板库与说明、icon-sizes.json、示例 .appiconset、隐私/EULA/授权文本、自动化测试与 CI 配置。

16. CI/CD 与提交
- CI：拉起构建与单测，失败禁止合并；必要时提供签名与公证流水线。
- 提交：变更涉及导出规格/后端接口/配额策略时，须同步更新本规则与相关文档。