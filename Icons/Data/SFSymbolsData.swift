//
//  SFSymbolsData.swift
//  Icons
//
//  Created by Icons App on 2024/01/15.
//

import Foundation

/// SF Symbols 数据源
struct SFSymbolsData {
    
    /// 获取所有 SF Symbols
    static func getAllSymbols() -> [SFSymbolInfo] {
        return communicationSymbols + 
               weatherSymbols + 
               objectSymbols + 
               deviceSymbols + 
               connectivitySymbols + 
               transportationSymbols + 
               humanSymbols + 
               natureSymbols + 
               editingSymbols + 
               textFormattingSymbols + 
               mediaSymbols + 
               keyboardSymbols + 
               commerceSymbols + 
               timeSymbols + 
               healthSymbols + 
               gamingSymbols + 
               shapesSymbols + 
               arrowsSymbols + 
               indicesSymbols
    }
    
    /// 根据分类获取符号
    static func getSymbols(for category: SFSymbolCategory) -> [SFSymbolInfo] {
        switch category {
        case .all:
            return getAllSymbols()
        case .communication:
            return communicationSymbols
        case .weather:
            return weatherSymbols
        case .objects:
            return objectSymbols
        case .devices:
            return deviceSymbols
        case .connectivity:
            return connectivitySymbols
        case .transportation:
            return transportationSymbols
        case .human:
            return humanSymbols
        case .nature:
            return natureSymbols
        case .editing:
            return editingSymbols
        case .textFormatting:
            return textFormattingSymbols
        case .media:
            return mediaSymbols
        case .keyboard:
            return keyboardSymbols
        case .commerce:
            return commerceSymbols
        case .time:
            return timeSymbols
        case .health:
            return healthSymbols
        case .gaming:
            return gamingSymbols
        case .shapes:
            return shapesSymbols
        case .arrows:
            return arrowsSymbols
        case .indices:
            return indicesSymbols
        }
    }
    
    // MARK: - 通讯类符号
    
    private static let communicationSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "phone", category: .communication, keywords: ["电话", "通话", "联系"]),
        SFSymbolInfo(name: "phone.fill", category: .communication, keywords: ["电话", "通话", "联系"]),
        SFSymbolInfo(name: "message", category: .communication, keywords: ["消息", "聊天", "短信"]),
        SFSymbolInfo(name: "message.fill", category: .communication, keywords: ["消息", "聊天", "短信"]),
        SFSymbolInfo(name: "envelope", category: .communication, keywords: ["邮件", "信封", "邮箱"]),
        SFSymbolInfo(name: "envelope.fill", category: .communication, keywords: ["邮件", "信封", "邮箱"]),
        SFSymbolInfo(name: "paperplane", category: .communication, keywords: ["发送", "纸飞机", "传输"]),
        SFSymbolInfo(name: "paperplane.fill", category: .communication, keywords: ["发送", "纸飞机", "传输"]),
        SFSymbolInfo(name: "bubble.left", category: .communication, keywords: ["对话", "气泡", "聊天"]),
        SFSymbolInfo(name: "bubble.right", category: .communication, keywords: ["对话", "气泡", "聊天"]),
        SFSymbolInfo(name: "video", category: .communication, keywords: ["视频", "通话", "摄像"]),
        SFSymbolInfo(name: "video.fill", category: .communication, keywords: ["视频", "通话", "摄像"])
    ]
    
    // MARK: - 天气类符号
    
    private static let weatherSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "sun.max", category: .weather, keywords: ["太阳", "晴天", "天气"]),
        SFSymbolInfo(name: "sun.max.fill", category: .weather, keywords: ["太阳", "晴天", "天气"]),
        SFSymbolInfo(name: "cloud", category: .weather, keywords: ["云", "多云", "天气"]),
        SFSymbolInfo(name: "cloud.fill", category: .weather, keywords: ["云", "多云", "天气"]),
        SFSymbolInfo(name: "cloud.rain", category: .weather, keywords: ["雨", "下雨", "天气"]),
        SFSymbolInfo(name: "cloud.rain.fill", category: .weather, keywords: ["雨", "下雨", "天气"]),
        SFSymbolInfo(name: "cloud.snow", category: .weather, keywords: ["雪", "下雪", "天气"]),
        SFSymbolInfo(name: "cloud.snow.fill", category: .weather, keywords: ["雪", "下雪", "天气"]),
        SFSymbolInfo(name: "bolt", category: .weather, keywords: ["闪电", "雷电", "天气"]),
        SFSymbolInfo(name: "bolt.fill", category: .weather, keywords: ["闪电", "雷电", "天气"]),
        SFSymbolInfo(name: "moon", category: .weather, keywords: ["月亮", "夜晚", "天气"]),
        SFSymbolInfo(name: "moon.fill", category: .weather, keywords: ["月亮", "夜晚", "天气"])
    ]
    
    // MARK: - 物品类符号
    
    private static let objectSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "house", category: .objects, keywords: ["房子", "家", "建筑"]),
        SFSymbolInfo(name: "house.fill", category: .objects, keywords: ["房子", "家", "建筑"]),
        SFSymbolInfo(name: "car", category: .objects, keywords: ["汽车", "车辆", "交通"]),
        SFSymbolInfo(name: "car.fill", category: .objects, keywords: ["汽车", "车辆", "交通"]),
        SFSymbolInfo(name: "book", category: .objects, keywords: ["书", "阅读", "学习"]),
        SFSymbolInfo(name: "book.fill", category: .objects, keywords: ["书", "阅读", "学习"]),
        SFSymbolInfo(name: "bag", category: .objects, keywords: ["包", "购物", "携带"]),
        SFSymbolInfo(name: "bag.fill", category: .objects, keywords: ["包", "购物", "携带"]),
        SFSymbolInfo(name: "gift", category: .objects, keywords: ["礼物", "礼品", "庆祝"]),
        SFSymbolInfo(name: "gift.fill", category: .objects, keywords: ["礼物", "礼品", "庆祝"]),
        SFSymbolInfo(name: "camera", category: .objects, keywords: ["相机", "拍照", "摄影"]),
        SFSymbolInfo(name: "camera.fill", category: .objects, keywords: ["相机", "拍照", "摄影"])
    ]
    
    // MARK: - 设备类符号
    
    private static let deviceSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "iphone", category: .devices, keywords: ["手机", "iPhone", "设备"]),
        SFSymbolInfo(name: "ipad", category: .devices, keywords: ["平板", "iPad", "设备"]),
        SFSymbolInfo(name: "laptopcomputer", category: .devices, keywords: ["笔记本", "电脑", "设备"]),
        SFSymbolInfo(name: "desktopcomputer", category: .devices, keywords: ["台式机", "电脑", "设备"]),
        SFSymbolInfo(name: "applewatch", category: .devices, keywords: ["手表", "Apple Watch", "设备"]),
        SFSymbolInfo(name: "tv", category: .devices, keywords: ["电视", "显示器", "设备"]),
        SFSymbolInfo(name: "tv.fill", category: .devices, keywords: ["电视", "显示器", "设备"]),
        SFSymbolInfo(name: "headphones", category: .devices, keywords: ["耳机", "音频", "设备"]),
        SFSymbolInfo(name: "speaker", category: .devices, keywords: ["扬声器", "音响", "设备"]),
        SFSymbolInfo(name: "speaker.fill", category: .devices, keywords: ["扬声器", "音响", "设备"]),
        SFSymbolInfo(name: "keyboard", category: .devices, keywords: ["键盘", "输入", "设备"]),
        SFSymbolInfo(name: "mouse", category: .devices, keywords: ["鼠标", "输入", "设备"])
    ]
    
    // MARK: - 连接类符号
    
    private static let connectivitySymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "wifi", category: .connectivity, keywords: ["无线", "网络", "连接"]),
        SFSymbolInfo(name: "antenna.radiowaves.left.and.right", category: .connectivity, keywords: ["信号", "无线", "连接"]),
        SFSymbolInfo(name: "bluetooth", category: .connectivity, keywords: ["蓝牙", "无线", "连接"]),
        SFSymbolInfo(name: "cable.connector", category: .connectivity, keywords: ["线缆", "连接", "数据"]),
        SFSymbolInfo(name: "network", category: .connectivity, keywords: ["网络", "连接", "互联"]),
        SFSymbolInfo(name: "globe", category: .connectivity, keywords: ["全球", "网络", "互联网"]),
        SFSymbolInfo(name: "link", category: .connectivity, keywords: ["链接", "连接", "关联"]),
        SFSymbolInfo(name: "personalhotspot", category: .connectivity, keywords: ["热点", "共享", "网络"])
    ]
    
    // MARK: - 交通类符号
    
    private static let transportationSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "airplane", category: .transportation, keywords: ["飞机", "航空", "旅行"]),
        SFSymbolInfo(name: "car.2", category: .transportation, keywords: ["汽车", "驾驶", "交通"]),
        SFSymbolInfo(name: "bus", category: .transportation, keywords: ["公交", "巴士", "交通"]),
        SFSymbolInfo(name: "tram", category: .transportation, keywords: ["电车", "轨道", "交通"]),
        SFSymbolInfo(name: "bicycle", category: .transportation, keywords: ["自行车", "骑行", "交通"]),
        SFSymbolInfo(name: "scooter", category: .transportation, keywords: ["滑板车", "代步", "交通"]),
        SFSymbolInfo(name: "ferry", category: .transportation, keywords: ["轮渡", "船舶", "交通"]),
        SFSymbolInfo(name: "sailboat", category: .transportation, keywords: ["帆船", "船舶", "交通"])
    ]
    
    // MARK: - 人物类符号
    
    private static let humanSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "person", category: .human, keywords: ["人", "用户", "个人"]),
        SFSymbolInfo(name: "person.fill", category: .human, keywords: ["人", "用户", "个人"]),
        SFSymbolInfo(name: "person.2", category: .human, keywords: ["多人", "团队", "群组"]),
        SFSymbolInfo(name: "person.2.fill", category: .human, keywords: ["多人", "团队", "群组"]),
        SFSymbolInfo(name: "person.3", category: .human, keywords: ["多人", "团队", "群组"]),
        SFSymbolInfo(name: "person.3.fill", category: .human, keywords: ["多人", "团队", "群组"]),
        SFSymbolInfo(name: "figure.walk", category: .human, keywords: ["行走", "运动", "活动"]),
        SFSymbolInfo(name: "figure.run", category: .human, keywords: ["跑步", "运动", "活动"]),
        SFSymbolInfo(name: "hand.raised", category: .human, keywords: ["手", "举手", "停止"]),
        SFSymbolInfo(name: "hand.raised.fill", category: .human, keywords: ["手", "举手", "停止"])
    ]
    
    // MARK: - 自然类符号
    
    private static let natureSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "leaf", category: .nature, keywords: ["叶子", "植物", "自然"]),
        SFSymbolInfo(name: "leaf.fill", category: .nature, keywords: ["叶子", "植物", "自然"]),
        SFSymbolInfo(name: "tree", category: .nature, keywords: ["树", "植物", "自然"]),
        SFSymbolInfo(name: "tree.fill", category: .nature, keywords: ["树", "植物", "自然"]),
        SFSymbolInfo(name: "flame", category: .nature, keywords: ["火", "火焰", "热"]),
        SFSymbolInfo(name: "flame.fill", category: .nature, keywords: ["火", "火焰", "热"]),
        SFSymbolInfo(name: "drop", category: .nature, keywords: ["水滴", "水", "液体"]),
        SFSymbolInfo(name: "drop.fill", category: .nature, keywords: ["水滴", "水", "液体"]),
        SFSymbolInfo(name: "mountain.2", category: .nature, keywords: ["山", "山脉", "自然"]),
        SFSymbolInfo(name: "mountain.2.fill", category: .nature, keywords: ["山", "山脉", "自然"])
    ]
    
    // MARK: - 编辑类符号
    
    private static let editingSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "pencil", category: .editing, keywords: ["铅笔", "编辑", "写作"]),
        SFSymbolInfo(name: "pencil.circle", category: .editing, keywords: ["铅笔", "编辑", "写作"]),
        SFSymbolInfo(name: "square.and.pencil", category: .editing, keywords: ["编辑", "修改", "写作"]),
        SFSymbolInfo(name: "eraser", category: .editing, keywords: ["橡皮", "擦除", "删除"]),
        SFSymbolInfo(name: "eraser.fill", category: .editing, keywords: ["橡皮", "擦除", "删除"]),
        SFSymbolInfo(name: "scissors", category: .editing, keywords: ["剪刀", "剪切", "裁剪"]),
        SFSymbolInfo(name: "paintbrush", category: .editing, keywords: ["画笔", "绘画", "艺术"]),
        SFSymbolInfo(name: "paintbrush.fill", category: .editing, keywords: ["画笔", "绘画", "艺术"])
    ]
    
    // MARK: - 文本格式类符号
    
    private static let textFormattingSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "bold", category: .textFormatting, keywords: ["粗体", "加粗", "文本"]),
        SFSymbolInfo(name: "italic", category: .textFormatting, keywords: ["斜体", "倾斜", "文本"]),
        SFSymbolInfo(name: "underline", category: .textFormatting, keywords: ["下划线", "强调", "文本"]),
        SFSymbolInfo(name: "strikethrough", category: .textFormatting, keywords: ["删除线", "划掉", "文本"]),
        SFSymbolInfo(name: "textformat.size", category: .textFormatting, keywords: ["字体大小", "尺寸", "文本"]),
        SFSymbolInfo(name: "textformat.alt", category: .textFormatting, keywords: ["文本格式", "样式", "文本"]),
        SFSymbolInfo(name: "list.bullet", category: .textFormatting, keywords: ["列表", "项目", "文本"]),
        SFSymbolInfo(name: "list.number", category: .textFormatting, keywords: ["编号", "序号", "文本"])
    ]
    
    // MARK: - 媒体类符号
    
    private static let mediaSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "play", category: .media, keywords: ["播放", "开始", "媒体"]),
        SFSymbolInfo(name: "play.fill", category: .media, keywords: ["播放", "开始", "媒体"]),
        SFSymbolInfo(name: "pause", category: .media, keywords: ["暂停", "停止", "媒体"]),
        SFSymbolInfo(name: "pause.fill", category: .media, keywords: ["暂停", "停止", "媒体"]),
        SFSymbolInfo(name: "stop", category: .media, keywords: ["停止", "结束", "媒体"]),
        SFSymbolInfo(name: "stop.fill", category: .media, keywords: ["停止", "结束", "媒体"]),
        SFSymbolInfo(name: "forward", category: .media, keywords: ["快进", "前进", "媒体"]),
        SFSymbolInfo(name: "forward.fill", category: .media, keywords: ["快进", "前进", "媒体"]),
        SFSymbolInfo(name: "backward", category: .media, keywords: ["后退", "倒退", "媒体"]),
        SFSymbolInfo(name: "backward.fill", category: .media, keywords: ["后退", "倒退", "媒体"]),
        SFSymbolInfo(name: "music.note", category: .media, keywords: ["音乐", "音符", "媒体"]),
        SFSymbolInfo(name: "photo", category: .media, keywords: ["照片", "图片", "媒体"]),
        SFSymbolInfo(name: "photo.fill", category: .media, keywords: ["照片", "图片", "媒体"])
    ]
    
    // MARK: - 键盘类符号
    
    private static let keyboardSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "command", category: .keyboard, keywords: ["命令键", "Cmd", "键盘"]),
        SFSymbolInfo(name: "option", category: .keyboard, keywords: ["选项键", "Alt", "键盘"]),
        SFSymbolInfo(name: "shift", category: .keyboard, keywords: ["Shift", "大写", "键盘"]),
        SFSymbolInfo(name: "control", category: .keyboard, keywords: ["控制键", "Ctrl", "键盘"]),
        SFSymbolInfo(name: "escape", category: .keyboard, keywords: ["Escape", "退出", "键盘"]),
        SFSymbolInfo(name: "return", category: .keyboard, keywords: ["回车", "Enter", "键盘"]),
        SFSymbolInfo(name: "delete.left", category: .keyboard, keywords: ["删除", "退格", "键盘"]),
        SFSymbolInfo(name: "space", category: .keyboard, keywords: ["空格", "间隔", "键盘"])
    ]
    
    // MARK: - 商务类符号
    
    private static let commerceSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "cart", category: .commerce, keywords: ["购物车", "购买", "商务"]),
        SFSymbolInfo(name: "cart.fill", category: .commerce, keywords: ["购物车", "购买", "商务"]),
        SFSymbolInfo(name: "creditcard", category: .commerce, keywords: ["信用卡", "支付", "商务"]),
        SFSymbolInfo(name: "creditcard.fill", category: .commerce, keywords: ["信用卡", "支付", "商务"]),
        SFSymbolInfo(name: "dollarsign.circle", category: .commerce, keywords: ["美元", "金钱", "商务"]),
        SFSymbolInfo(name: "dollarsign.circle.fill", category: .commerce, keywords: ["美元", "金钱", "商务"]),
        SFSymbolInfo(name: "building.2", category: .commerce, keywords: ["建筑", "公司", "商务"]),
        SFSymbolInfo(name: "building.2.fill", category: .commerce, keywords: ["建筑", "公司", "商务"]),
        SFSymbolInfo(name: "briefcase", category: .commerce, keywords: ["公文包", "工作", "商务"]),
        SFSymbolInfo(name: "briefcase.fill", category: .commerce, keywords: ["公文包", "工作", "商务"])
    ]
    
    // MARK: - 时间类符号
    
    private static let timeSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "clock", category: .time, keywords: ["时钟", "时间", "计时"]),
        SFSymbolInfo(name: "clock.fill", category: .time, keywords: ["时钟", "时间", "计时"]),
        SFSymbolInfo(name: "timer", category: .time, keywords: ["计时器", "倒计时", "时间"]),
        SFSymbolInfo(name: "stopwatch", category: .time, keywords: ["秒表", "计时", "时间"]),
        SFSymbolInfo(name: "stopwatch.fill", category: .time, keywords: ["秒表", "计时", "时间"]),
        SFSymbolInfo(name: "calendar", category: .time, keywords: ["日历", "日期", "时间"]),
        SFSymbolInfo(name: "calendar.circle", category: .time, keywords: ["日历", "日期", "时间"]),
        SFSymbolInfo(name: "alarm", category: .time, keywords: ["闹钟", "提醒", "时间"]),
        SFSymbolInfo(name: "alarm.fill", category: .time, keywords: ["闹钟", "提醒", "时间"])
    ]
    
    // MARK: - 健康类符号
    
    private static let healthSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "heart", category: .health, keywords: ["心", "爱心", "健康"]),
        SFSymbolInfo(name: "heart.fill", category: .health, keywords: ["心", "爱心", "健康"]),
        SFSymbolInfo(name: "cross", category: .health, keywords: ["十字", "医疗", "健康"]),
        SFSymbolInfo(name: "cross.fill", category: .health, keywords: ["十字", "医疗", "健康"]),
        SFSymbolInfo(name: "pills", category: .health, keywords: ["药丸", "药物", "健康"]),
        SFSymbolInfo(name: "pills.fill", category: .health, keywords: ["药丸", "药物", "健康"]),
        SFSymbolInfo(name: "stethoscope", category: .health, keywords: ["听诊器", "医疗", "健康"]),
        SFSymbolInfo(name: "bandage", category: .health, keywords: ["绷带", "治疗", "健康"]),
        SFSymbolInfo(name: "bandage.fill", category: .health, keywords: ["绷带", "治疗", "健康"])
    ]
    
    // MARK: - 游戏类符号
    
    private static let gamingSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "gamecontroller", category: .gaming, keywords: ["游戏手柄", "游戏", "娱乐"]),
        SFSymbolInfo(name: "gamecontroller.fill", category: .gaming, keywords: ["游戏手柄", "游戏", "娱乐"]),
        SFSymbolInfo(name: "dice", category: .gaming, keywords: ["骰子", "游戏", "随机"]),
        SFSymbolInfo(name: "dice.fill", category: .gaming, keywords: ["骰子", "游戏", "随机"]),
        SFSymbolInfo(name: "suit.heart", category: .gaming, keywords: ["红桃", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.heart.fill", category: .gaming, keywords: ["红桃", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.club", category: .gaming, keywords: ["梅花", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.club.fill", category: .gaming, keywords: ["梅花", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.diamond", category: .gaming, keywords: ["方块", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.diamond.fill", category: .gaming, keywords: ["方块", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.spade", category: .gaming, keywords: ["黑桃", "扑克", "游戏"]),
        SFSymbolInfo(name: "suit.spade.fill", category: .gaming, keywords: ["黑桃", "扑克", "游戏"])
    ]
    
    // MARK: - 形状类符号
    
    private static let shapesSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "circle", category: .shapes, keywords: ["圆", "圆形", "形状"]),
        SFSymbolInfo(name: "circle.fill", category: .shapes, keywords: ["圆", "圆形", "形状"]),
        SFSymbolInfo(name: "square", category: .shapes, keywords: ["方", "正方形", "形状"]),
        SFSymbolInfo(name: "square.fill", category: .shapes, keywords: ["方", "正方形", "形状"]),
        SFSymbolInfo(name: "triangle", category: .shapes, keywords: ["三角", "三角形", "形状"]),
        SFSymbolInfo(name: "triangle.fill", category: .shapes, keywords: ["三角", "三角形", "形状"]),
        SFSymbolInfo(name: "diamond", category: .shapes, keywords: ["菱形", "钻石", "形状"]),
        SFSymbolInfo(name: "diamond.fill", category: .shapes, keywords: ["菱形", "钻石", "形状"]),
        SFSymbolInfo(name: "hexagon", category: .shapes, keywords: ["六边形", "蜂窝", "形状"]),
        SFSymbolInfo(name: "hexagon.fill", category: .shapes, keywords: ["六边形", "蜂窝", "形状"]),
        SFSymbolInfo(name: "star", category: .shapes, keywords: ["星", "星形", "形状"]),
        SFSymbolInfo(name: "star.fill", category: .shapes, keywords: ["星", "星形", "形状"])
    ]
    
    // MARK: - 箭头类符号
    
    private static let arrowsSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "arrow.up", category: .arrows, keywords: ["向上", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.down", category: .arrows, keywords: ["向下", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.left", category: .arrows, keywords: ["向左", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.right", category: .arrows, keywords: ["向右", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.up.right", category: .arrows, keywords: ["右上", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.down.right", category: .arrows, keywords: ["右下", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.up.left", category: .arrows, keywords: ["左上", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.down.left", category: .arrows, keywords: ["左下", "箭头", "方向"]),
        SFSymbolInfo(name: "arrow.clockwise", category: .arrows, keywords: ["顺时针", "旋转", "箭头"]),
        SFSymbolInfo(name: "arrow.counterclockwise", category: .arrows, keywords: ["逆时针", "旋转", "箭头"]),
        SFSymbolInfo(name: "arrow.2.squarepath", category: .arrows, keywords: ["循环", "重复", "箭头"]),
        SFSymbolInfo(name: "arrow.triangle.2.circlepath", category: .arrows, keywords: ["刷新", "更新", "箭头"])
    ]
    
    // MARK: - 指示类符号
    
    private static let indicesSymbols: [SFSymbolInfo] = [
        SFSymbolInfo(name: "checkmark", category: .indices, keywords: ["勾选", "确认", "完成"]),
        SFSymbolInfo(name: "checkmark.circle", category: .indices, keywords: ["勾选", "确认", "完成"]),
        SFSymbolInfo(name: "checkmark.circle.fill", category: .indices, keywords: ["勾选", "确认", "完成"]),
        SFSymbolInfo(name: "xmark", category: .indices, keywords: ["叉", "取消", "错误"]),
        SFSymbolInfo(name: "xmark.circle", category: .indices, keywords: ["叉", "取消", "错误"]),
        SFSymbolInfo(name: "xmark.circle.fill", category: .indices, keywords: ["叉", "取消", "错误"]),
        SFSymbolInfo(name: "plus", category: .indices, keywords: ["加", "添加", "新增"]),
        SFSymbolInfo(name: "plus.circle", category: .indices, keywords: ["加", "添加", "新增"]),
        SFSymbolInfo(name: "plus.circle.fill", category: .indices, keywords: ["加", "添加", "新增"]),
        SFSymbolInfo(name: "minus", category: .indices, keywords: ["减", "删除", "移除"]),
        SFSymbolInfo(name: "minus.circle", category: .indices, keywords: ["减", "删除", "移除"]),
        SFSymbolInfo(name: "minus.circle.fill", category: .indices, keywords: ["减", "删除", "移除"]),
        SFSymbolInfo(name: "exclamationmark", category: .indices, keywords: ["感叹号", "警告", "注意"]),
        SFSymbolInfo(name: "exclamationmark.triangle", category: .indices, keywords: ["警告", "注意", "危险"]),
        SFSymbolInfo(name: "exclamationmark.triangle.fill", category: .indices, keywords: ["警告", "注意", "危险"]),
        SFSymbolInfo(name: "questionmark", category: .indices, keywords: ["问号", "疑问", "帮助"]),
        SFSymbolInfo(name: "questionmark.circle", category: .indices, keywords: ["问号", "疑问", "帮助"]),
        SFSymbolInfo(name: "questionmark.circle.fill", category: .indices, keywords: ["问号", "疑问", "帮助"]),
        SFSymbolInfo(name: "info", category: .indices, keywords: ["信息", "详情", "说明"]),
        SFSymbolInfo(name: "info.circle", category: .indices, keywords: ["信息", "详情", "说明"]),
        SFSymbolInfo(name: "info.circle.fill", category: .indices, keywords: ["信息", "详情", "说明"])
    ]
}