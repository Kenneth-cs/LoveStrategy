# 🛡️ Cloudflare Workers 部署指南

## 为什么要部署 Worker？

### 🚨 安全风险

如果直接在 iOS App 中硬编码 API Key：
- ✅ **开发快**：直接写在代码里，3分钟搞定
- ❌ **10秒破解**：别人用 IDA Pro 反编译你的 `.ipa`，立刻看到你的 Key
- ❌ **财产损失**：别人用你的 Key 刷爆你的额度
- ❌ **Prompt 泄露**：你精心设计的 Prompt 会被竞品抄走

### ✅ Worker 方案的优势

```
iOS App → Cloudflare Worker → 火山引擎 API
           ↑ API Key 存在这里
           ↑ 即使抓包也看不到真实的 Key
```

**好处：**
1. **绝对安全**：API Key 存在 Cloudflare 服务器，App 中完全没有
2. **防抓包**：抓包只能看到你的 Worker 网址，看不到火山引擎的 Key
3. **Prompt 保护**：可以把 Prompt 也移到 Worker 中
4. **免费使用**：Cloudflare 免费版每天 10 万次请求
5. **灵活控制**：可以随时修改逻辑，不用更新 App

---

## 📋 部署步骤（10 分钟完成）

### Step 1：注册 Cloudflare 账号

1. 访问：https://dash.cloudflare.com/sign-up
2. 使用邮箱注册（**免费版足够用**）
3. 验证邮箱后登录

---

### Step 2：创建 Worker

1. 登录后，点击左侧菜单 **"Workers & Pages"**

   ![Step 2-1](https://i.imgur.com/placeholder1.png)

2. 点击右上角 **"Create application"** 按钮

3. 选择 **"Create Worker"**

4. 给 Worker 起个名字，例如：
   - `love-strategy-api`（推荐）
   - `ls-api`（简短版）
   - `your-custom-name`（自定义）

5. 点击 **"Deploy"**（先部署一个默认的，后面再改代码）

---

### Step 3：编辑 Worker 代码

1. 部署成功后，点击 **"Edit Code"** 按钮

2. 删除默认代码，粘贴 `cloudflare-worker.js` 中的代码

   ```javascript
   // 复制本项目根目录下的 cloudflare-worker.js 文件内容
   // 全选删除默认代码，粘贴新代码
   ```

3. 点击右上角 **"Save and Deploy"** 保存

4. **复制你的 Worker 网址**（非常重要！）
   - 网址格式：`https://your-worker-name.your-username.workers.dev`
   - 例如：`https://love-strategy-api.zhangsan.workers.dev`

---

### Step 4：配置环境变量（关键！）

1. 回到 Worker 主页，点击 **"Settings"** 标签

2. 找到 **"Variables"** 部分

3. 点击 **"Add variable"** 添加以下两个变量：

#### 变量 1：API Key（必须加密）

| 字段 | 值 |
|------|-----|
| **Variable name** | `VOLC_API_KEY` |
| **Value** | 你的火山引擎 API Key（如：`7d51475c-4721-4a09-8f0b-dd74d2e4eb00`）|
| **Type** | ✅ **选择 "Encrypt"（加密）** |

#### 变量 2：Model ID（可选）

| 字段 | 值 |
|------|-----|
| **Variable name** | `VOLC_MODEL_ID` |
| **Value** | `doubao-seed-1-6-flash-250828` |
| **Type** | "Text"（普通文本即可）|

4. 点击 **"Save"** 保存

---

### Step 5：测试 Worker

在终端运行以下命令测试：

```bash
curl -X POST https://your-worker-name.your-username.workers.dev \
  -H "Content-Type: application/json" \
  -d '{
    "action": "reply",
    "messages": [
      {
        "role": "user",
        "content": "在干嘛？"
      }
    ]
  }'
```

**预期结果：**
- ✅ 返回 JSON 格式的 AI 回复
- ❌ 如果返回错误，检查环境变量是否配置正确

---

### Step 6：更新 iOS 代码

1. 打开 `Zhananfenxi/VolcengineService.swift`

2. 找到第 19 行，修改为你的 Worker 网址：

   ```swift
   // 替换这一行：
   private let workerEndpoint = "https://YOUR-WORKER-NAME.workers.dev"
   
   // 改成你的实际网址：
   private let workerEndpoint = "https://love-strategy-api.zhangsan.workers.dev"
   ```

3. 保存文件，重新编译运行 App

4. **测试所有功能**：
   - ✅ 鉴渣雷达（分析截图）
   - ✅ 心理投射（卦象）
   - ✅ 拿捏助手（生成回复）

---

## 🧪 验证是否部署成功

### 方法 1：查看 Xcode 控制台日志

运行 App 后，在 Xcode 控制台应该看到：

```
✅ 收到 AI 响应
📝 内容: {"hexagram_name": "天风姤", ...}
```

### 方法 2：抓包测试（可选）

使用 Charles 或 Proxyman 抓包，你应该看到：

```
Request URL: https://your-worker-name.workers.dev
Headers: 
  Content-Type: application/json
  (没有 Authorization 头！)

Request Body:
  {
    "action": "analyze",
    "messages": [...]
  }
```

**关键点：**
- ✅ 请求发往你的 Worker 网址（不是火山引擎）
- ✅ 没有 `Authorization` 头（API Key 不暴露）
- ✅ 响应正常返回 AI 结果

---

## 🔥 常见问题 FAQ

### Q1: Worker 免费版够用吗？

**A:** 完全够用！

- **免费额度**：每天 10 万次请求
- **你的需求**：假设 DAU 1000 人，每人用 10 次 = 1 万次/天
- **结论**：免费版可支撑到 DAU 1 万

### Q2: 如果超过免费额度怎么办？

**A:** 付费很便宜

- **付费版**：$5/月，1000 万次请求
- **计费方式**：超过免费额度才扣费
- **监控**：Cloudflare Dashboard 可以看实时流量

### Q3: Worker 会不会很慢？

**A:** 不会，反而可能更快

- Cloudflare 全球 CDN，延迟通常 < 50ms
- 比直连火山引擎可能还快（Worker 在境外节点）

### Q4: 可以用自己的域名吗？

**A:** 可以！

1. 在 Cloudflare 添加你的域名
2. 在 Worker 设置中绑定自定义域名
3. 例如：`api.yourdomain.com`

### Q5: 如果想换 API Key 怎么办？

**A:** 超级简单

1. 进入 Worker → Settings → Variables
2. 编辑 `VOLC_API_KEY` 变量
3. 保存即可，**不用更新 App**

### Q6: 可以看到请求日志吗？

**A:** 可以

1. Worker 主页 → **"Logs"** 标签
2. 点击 **"Begin log stream"**
3. 实时查看所有请求和错误

---

## 🚀 进阶功能（可选）

### 1. 添加请求频率限制（防刷）

在 Worker 中添加：

```javascript
// 使用 Cloudflare KV 存储来记录请求次数
const key = `rate_limit:${clientIP}`;
const count = await env.RATE_LIMIT_KV.get(key) || 0;

if (count > 100) { // 每小时最多 100 次
  return jsonResponse({ error: "请求过于频繁" }, 429);
}

await env.RATE_LIMIT_KV.put(key, count + 1, { expirationTtl: 3600 });
```

### 2. IP 黑名单（防止恶意攻击）

```javascript
const blockedIPs = ["1.2.3.4", "5.6.7.8"];
const clientIP = request.headers.get("CF-Connecting-IP");

if (blockedIPs.includes(clientIP)) {
  return jsonResponse({ error: "访问被拒绝" }, 403);
}
```

### 3. 把 Prompt 也移到 Worker（最高安全）

```javascript
// 在 Worker 中存储 Prompt
const ANALYSIS_PROMPT = `你是一位拥有 10 年经验的情感心理咨询师...`;

// iOS App 只需发送图片，不发送 Prompt
const messages = [
  {
    role: "user",
    content: [
      { type: "image_url", image_url: { url: body.image } },
      { type: "text", text: ANALYSIS_PROMPT } // 在 Worker 中添加
    ]
  }
];
```

这样即使抓包，也看不到你的 Prompt！

---

## 📊 监控和维护

### 查看流量统计

1. Worker 主页 → **"Metrics"** 标签
2. 可以看到：
   - 每日请求量
   - 成功率
   - 平均响应时间
   - 错误率

### 设置告警（可选）

1. Worker 主页 → **"Triggers"** 标签
2. 添加 Cron Trigger（定时任务）
3. 可以设置：
   - 错误率过高时发邮件通知
   - 流量异常时发 Webhook

---

## 🎯 总结

### 部署前 vs 部署后

| 对比项 | 部署前（硬编码） | 部署后（Worker） |
|--------|-----------------|-----------------|
| **安全性** | ❌ 10秒破解 | ✅ 无法破解 |
| **成本** | ❌ 可能被刷爆 | ✅ 可控 |
| **灵活性** | ❌ 改逻辑要更新App | ✅ 随时修改 |
| **Prompt保护** | ❌ 可被抓包 | ✅ 可隐藏 |
| **维护成本** | ❌ 高 | ✅ 低 |

### 下一步

1. ✅ 部署完成后，测试所有功能
2. ✅ 提交 App Store（现在可以安全提交了）
3. ✅ 监控 Worker 流量，优化性能
4. ✅ 考虑添加进阶功能（频率限制、黑名单等）

---

## 💡 需要帮助？

如果遇到问题，检查：

1. **环境变量是否正确配置**（最常见错误）
2. **Worker 网址是否更新到 iOS 代码中**
3. **火山引擎 API Key 是否有效**
4. **查看 Worker 日志**（Logs 标签）

---

**祝部署顺利！🎉**

