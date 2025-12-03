// ============================================
// 恋爱军师 API 中转服务 (Cloudflare Worker)
// ============================================
// 功能：保护 API Key，防止被反编译获取
// 作者：恋爱军师团队
// 版本：1.0.0
// ============================================

export default {
  async fetch(request, env) {
    // ============= CORS 处理 =============
    // 处理 OPTIONS 预检请求（移动端可能需要）
    if (request.method === "OPTIONS") {
      return new Response(null, {
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Access-Control-Allow-Methods": "POST, OPTIONS",
          "Access-Control-Allow-Headers": "Content-Type, X-API-Version",
          "Access-Control-Max-Age": "86400",
        },
      });
    }

    // ============= 安全检查 =============
    // 只允许 POST 请求
    if (request.method !== "POST") {
      return jsonResponse({ error: "只允许 POST 请求" }, 405);
    }

    try {
      // 解析 iOS App 发来的数据
      const body = await request.json();
      const { action, messages, model } = body;

      // 验证必填参数
      if (!action || !messages) {
        return jsonResponse({ 
          error: "缺少必填参数",
          details: "需要 action 和 messages" 
        }, 400);
      }

      // ============= 日志记录（可选，用于调试）=============
      console.log(`📱 收到请求 - Action: ${action}, Time: ${new Date().toISOString()}`);

      // ============= 调用火山引擎 API =============
      const volcanoApiUrl = "https://ark.cn-beijing.volces.com/api/v3/chat/completions";
      
      // 从环境变量读取配置（在 Cloudflare Dashboard 中设置）
      const apiKey = env.VOLC_API_KEY;
      const modelId = model || env.VOLC_MODEL_ID || "doubao-seed-1-6-flash-250828";

      // 检查环境变量是否配置
      if (!apiKey) {
        return jsonResponse({ 
          error: "服务器配置错误", 
          details: "未配置 VOLC_API_KEY 环境变量" 
        }, 500);
      }

      // 构建火山引擎请求
      const volcanoResponse = await fetch(volcanoApiUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Authorization": `Bearer ${apiKey}`, // 从环境变量读取，绝对安全
        },
        body: JSON.stringify({
          model: modelId,
          messages: messages,
          max_completion_tokens: 65535,
        }),
      });

      // 检查响应状态
      if (!volcanoResponse.ok) {
        const errorText = await volcanoResponse.text();
        console.error("❌ 火山引擎 API 错误：", errorText);
        
        return jsonResponse(
          { 
            error: "AI 服务暂时不可用", 
            details: `HTTP ${volcanoResponse.status}`,
            retry: true 
          },
          volcanoResponse.status
        );
      }

      // 返回结果给 iOS App
      const data = await volcanoResponse.json();
      console.log(`✅ 请求成功 - Action: ${action}`);
      
      return jsonResponse(data, 200);

    } catch (error) {
      // 错误处理
      console.error("💥 Worker 错误：", error);
      
      return jsonResponse(
        { 
          error: "服务器内部错误", 
          details: error.message,
          retry: true 
        },
        500
      );
    }
  },
};

// ============= 辅助函数 =============
/**
 * 返回 JSON 响应（带 CORS 头）
 */
function jsonResponse(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status: status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Cache-Control": "no-cache, no-store, must-revalidate",
    },
  });
}

// ============= 扩展功能（可选）=============
// 
// 如果未来需要添加：
// 1. 请求频率限制（Rate Limiting）
// 2. IP 黑名单/白名单
// 3. 请求日志分析
// 4. A/B 测试不同的 Prompt
// 
// 都可以在这个 Worker 中实现，而无需更新 iOS App！
//

