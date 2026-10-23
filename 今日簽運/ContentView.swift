
import SwiftUI

// MARK: - 資料

struct FortuneLevel {
    let name: String
    let emoji: String
    let color: Color
    let weight: Int          // 抽到的機率權重
    let baseStars: Int       // 各項運勢的基準星數
    let messages: [String]   // 籤詩
}

let fortuneLevels: [FortuneLevel] = [
    FortuneLevel(name: "大吉", emoji: "🎉", color: .red, weight: 10, baseStars: 5, messages: [
        "今天你說什麼都對，放手去做吧！",
        "好運滿格，連紅燈都會為你變綠。",
        "想做的事今天就開始，宇宙站在你這邊。"
    ]),
    FortuneLevel(name: "中吉", emoji: "😄", color: .orange, weight: 20, baseStars: 4, messages: [
        "穩穩前進，今天會有小驚喜。",
        "貴人出現的日子，多笑一點。",
        "努力過的事，有機會得到回報。"
    ]),
    FortuneLevel(name: "小吉", emoji: "🙂", color: Color(red: 0.85, green: 0.6, blue: 0.0), weight: 20, baseStars: 4, messages: [
        "平平順順，小確幸就藏在午餐裡。",
        "放慢一點，好事自然靠近。"
    ]),
    FortuneLevel(name: "吉", emoji: "😌", color: .green, weight: 20, baseStars: 3, messages: [
        "按部就班就好，今天不需要冒險。",
        "照顧好自己，一切剛剛好。"
    ]),
    FortuneLevel(name: "末吉", emoji: "🤔", color: .blue, weight: 15, baseStars: 3, messages: [
        "好運慢了一拍，不用著急。",
        "先把手邊的事做完，轉機在傍晚。"
    ]),
    FortuneLevel(name: "凶", emoji: "😬", color: .gray, weight: 10, baseStars: 2, messages: [
        "出門記得帶傘，也帶點耐心。",
        "今天少說多聽，小心手滑。"
    ]),
    FortuneLevel(name: "大凶", emoji: "😱", color: .purple, weight: 5, baseStars: 1, messages: [
        "今天就當作休息日，早點睡最安全。",
        "壞運氣今天一次用完，明天只會更好。"
    ])
]

struct LuckyColor {
    let name: String
    let color: Color
}

let luckyColors: [LuckyColor] = [
    LuckyColor(name: "紅色", color: .red),
    LuckyColor(name: "橘色", color: .orange),
    LuckyColor(name: "黃色", color: .yellow),
    LuckyColor(name: "綠色", color: .green),
    LuckyColor(name: "藍色", color: .blue),
    LuckyColor(name: "紫色", color: .purple),
    LuckyColor(name: "粉紅色", color: .pink),
    LuckyColor(name: "咖啡色", color: .brown)
]

let doList = ["喝一杯手搖", "整理桌面", "傳訊息給老朋友", "出門散步", "早點睡覺", "寫一小段程式", "吃頓好吃的"]
let avoidList = ["衝動購物", "熬夜", "跟人爭論", "吃太飽", "亂改程式碼", "已讀不回", "滑手機滑太久"]

/// 一張籤
struct Fortune: Identifiable, Equatable {
    let id = UUID()
    let level: Int          // fortuneLevels 的索引
    let message: String
    let love: Int
    let career: Int
    let money: Int
    let health: Int
    let luckyColor: Int     // luckyColors 的索引
    let luckyNumber: Int
    let doText: String
    let avoidText: String
}

// MARK: - 抽籤邏輯

func weightedLevelIndex() -> Int {
    let total = fortuneLevels.reduce(0) { $0 + $1.weight }
    var r = Int.random(in: 0..<total)
    for (index, level) in fortuneLevels.enumerated() {
        if r < level.weight { return index }
        r -= level.weight
    }
    return 0
}

func makeFortune() -> Fortune {
    let index = weightedLevelIndex()
    let info = fortuneLevels[index]

    func stars() -> Int {
        min(5, max(1, info.baseStars + Int.random(in: -1...1)))
    }

    return Fortune(
        level: index,
        message: info.messages.randomElement() ?? "",
        love: stars(),
        career: stars(),
        money: stars(),
        health: stars(),
        luckyColor: Int.random(in: 0..<luckyColors.count),
        luckyNumber: Int.random(in: 1...99),
        doText: doList.randomElement() ?? "",
        avoidText: avoidList.randomElement() ?? ""
    )
}

// MARK: - 主畫面

struct ContentView: View {
    // 這次練習的主角：@State
    @State private var fortune: Fortune? = nil
    @State private var isShaking = false
    @State private var shakeAngle: Double = 0
    @State private var drawCount = 0
    @State private var greatCount = 0
    @State private var history: [Fortune] = []

    private let stickHeights: [CGFloat] = [140, 165, 150, 175, 145]
    private let stickAngles: [Double] = [-9, -4, 0, 5, 10]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("今日運勢抽籤")
                    .font(.largeTitle.bold())

                summaryCard

                cupView

                Button {
                    draw()
                } label: {
                    Label(isShaking ? "搖籤中…" : "搖籤", systemImage: "hand.tap.fill")
                        .font(.title3.bold())
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(isShaking)

                if let f = fortune {
                    resultCard(f)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text(isShaking ? "搖啊搖…" : "誠心默念問題，按下「搖籤」")
                        .foregroundStyle(.secondary)
                        .padding(.vertical, 24)
                }

                if !history.isEmpty {
                    historySection
                }
            }
            .padding()
        }
    }

    // MARK: 籤筒

    private var cupView: some View {
        ZStack(alignment: .bottom) {
            // 籤
            HStack(alignment: .bottom, spacing: 5) {
                ForEach(0..<5, id: \.self) { i in
                    Capsule()
                        .fill(Color(red: 0.88, green: 0.72, blue: 0.45))
                        .frame(width: 10, height: stickHeights[i])
                        .rotationEffect(.degrees(stickAngles[i]), anchor: .bottom)
                }
            }
            .padding(.bottom, 60)

            // 籤筒
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.85, green: 0.15, blue: 0.15),
                                     Color(red: 0.6, green: 0.05, blue: 0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: 110, height: 130)

                VStack {
                    Rectangle().fill(Color(red: 0.95, green: 0.8, blue: 0.3)).frame(height: 8)
                    Spacer()
                    Rectangle().fill(Color(red: 0.95, green: 0.8, blue: 0.3)).frame(height: 8)
                }
                .frame(width: 110, height: 130)
                .clipShape(RoundedRectangle(cornerRadius: 18))

                Text("籤")
                    .font(.system(size: 54, weight: .black, design: .serif))
                    .foregroundStyle(.white)
            }
        }
        .frame(width: 160, height: 240)
        .rotationEffect(.degrees(shakeAngle), anchor: .bottom)
    }

    // MARK: 統計

    private var summaryCard: some View {
        HStack {
            summaryItem(title: "抽籤次數", value: "\(drawCount)")
            Divider().frame(height: 36)
            summaryItem(title: "大吉次數", value: "\(greatCount)")
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.15))
        )
    }

    private func summaryItem(title: String, value: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.bold().monospacedDigit())
                .contentTransition(.numericText())
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: 結果卡片

    private func resultCard(_ f: Fortune) -> some View {
        let info = fortuneLevels[f.level]
        let lucky = luckyColors[f.luckyColor]

        return VStack(spacing: 14) {
            HStack(spacing: 10) {
                Text(info.emoji)
                    .font(.system(size: 40))
                Text(info.name)
                    .font(.system(size: 52, weight: .black, design: .serif))
                    .foregroundStyle(info.color)
            }

            Text(f.message)
                .font(.headline)
                .multilineTextAlignment(.center)

            Divider()

            VStack(spacing: 8) {
                starRow("💕 愛情", f.love)
                starRow("💼 事業", f.career)
                starRow("💰 財運", f.money)
                starRow("🍀 健康", f.health)
            }

            Divider()

            HStack {
                HStack(spacing: 6) {
                    Text("幸運色")
                        .foregroundStyle(.secondary)
                    Circle()
                        .fill(lucky.color)
                        .frame(width: 18, height: 18)
                        .overlay(Circle().stroke(Color.black.opacity(0.2), lineWidth: 1))
                    Text(lucky.name)
                }
                .frame(maxWidth: .infinity)

                HStack(spacing: 6) {
                    Text("幸運數字")
                        .foregroundStyle(.secondary)
                    Text("\(f.luckyNumber)")
                        .font(.headline.monospacedDigit())
                }
                .frame(maxWidth: .infinity)
            }
            .font(.subheadline)

            HStack(spacing: 12) {
                tag(title: "宜", text: f.doText, color: .green)
                tag(title: "忌", text: f.avoidText, color: .red)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(info.color.opacity(0.6), lineWidth: 2)
        )
    }

    private func starRow(_ title: String, _ count: Int) -> some View {
        HStack {
            Text(title)
                .frame(width: 80, alignment: .leading)
            Spacer()
            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { i in
                    Image(systemName: i <= count ? "star.fill" : "star")
                        .foregroundStyle(.orange)
                }
            }
        }
        .font(.subheadline)
    }

    private func tag(title: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.white)
                .frame(width: 22, height: 22)
                .background(Circle().fill(color))
            Text(text)
                .font(.subheadline)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.12))
        )
    }

    // MARK: 歷史紀錄

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("最近抽到的籤")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Spacer()
                Button("全部重置", role: .destructive) {
                    reset()
                }
                .font(.footnote)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(history) { item in
                        let info = fortuneLevels[item.level]
                        Text(info.name)
                            .font(.subheadline.bold())
                            .foregroundStyle(info.color)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(info.color.opacity(0.15)))
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: 按鈕動作（全部都是在改 @State）

    private func draw() {
        guard !isShaking else { return }

        withAnimation(.easeOut(duration: 0.2)) {
            fortune = nil
        }
        isShaking = true

        Task { @MainActor in
            // 左右搖晃 10 次
            for i in 0..<10 {
                withAnimation(.easeInOut(duration: 0.1)) {
                    shakeAngle = (i % 2 == 0) ? 12 : -12
                }
                try? await Task.sleep(nanoseconds: 100_000_000)
            }

            // 抽出一張籤
            let result = makeFortune()
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                shakeAngle = 0
                fortune = result
                isShaking = false
                drawCount += 1
                if result.level == 0 { greatCount += 1 }
                history.insert(result, at: 0)
                if history.count > 10 { history.removeLast() }
            }
        }
    }

    private func reset() {
        withAnimation {
            fortune = nil
            history = []
            drawCount = 0
            greatCount = 0
        }
    }
}

#Preview {
    ContentView()
}
