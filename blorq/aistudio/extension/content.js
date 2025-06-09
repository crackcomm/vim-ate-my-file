console.log(`AI Studio relay script loaded.`);

const inputSelector = "textarea.textarea, textarea.gmat-body-medium";
const sendButtonSelector = 'button.run-button, button[aria-label="Run"]';
const newChatSelector = 'a[href="/prompts/new_chat"]';
const pendingResponseCallbacks = new Map();

async function sendChatMessage(messageContent) {
  if (typeof messageContent !== "string") {
    console.error(
      `[AIStudio] This script only supports sending string messages.`,
    );
    return false;
  }
  const newChatButton = document.querySelector(newChatSelector);
  if (newChatButton) {
    newChatButton.click();
    await new Promise((resolve) => setTimeout(resolve, 1000));
  }
  const inputField = document.querySelector(inputSelector);
  const sendButton = document.querySelector(sendButtonSelector);
  if (!inputField || !sendButton) {
    console.error(`[AIStudio] Missing input field or send button.`);
    return false;
  }
  try {
    inputField.value = messageContent;
    inputField.dispatchEvent(new Event("input", { bubbles: true }));
    await new Promise((resolve) => setTimeout(resolve, 100));

    let attempts = 0;
    while (attempts < 30) {
      const isDisabled =
        sendButton.disabled ||
        sendButton.getAttribute("aria-disabled") === "true";
      if (!isDisabled) {
        sendButton.click();
        return true;
      }
      attempts++;
      await new Promise((resolve) => setTimeout(resolve, 2000));
    }
    return false;
  } catch (error) {
    console.error(`[AIStudio] Error sending message:`, error);
    return false;
  }
}

function initiateResponseCapture(requestId, responseCallback) {
  pendingResponseCallbacks.set(requestId, responseCallback);
}

function handleDebuggerData(requestId, rawData, responseCallback) {
  const callback = pendingResponseCallbacks.get(requestId);
  if (!callback) return;
  const { text } = parseDebuggerResponse(rawData);
  callback(requestId, text, true);
  pendingResponseCallbacks.delete(requestId);
}

function handleProviderResponse(requestId, responseText, isFinal) {
  if (isFinal) {
    chrome.runtime.sendMessage({
      type: "FINAL_RESPONSE",
      requestId: requestId,
      response: responseText,
    });
  }
}

chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
  switch (message.type) {
    case "SEND_CHAT_MESSAGE":
      sendChatMessage(message.message);
      initiateResponseCapture(message.requestId, handleProviderResponse);
      break;
    case "DEBUGGER_RESPONSE":
      handleDebuggerData(
        message.requestId,
        message.data,
        handleProviderResponse,
      );
      break;
  }
  sendResponse({ status: "ok" });
  return true;
});

function parseDebuggerResponse(jsonString) {
  try {
    const googleRawResponse = JSON.parse(jsonString);
    const openAIResponse = createOpenAICompletion(googleRawResponse);
    return { text: JSON.stringify(openAIResponse), isFinalResponse: true };
  } catch (e) {
    console.error("Error parsing debugger response:", e, jsonString);
    return {
      text: JSON.stringify({ error: "Failed to parse AI Studio response." }),
      isFinalResponse: true,
    };
  }
}

function* findAllPayloadsInChunk(node) {
  if (!Array.isArray(node)) return;
  const isTextContent = node[0] === null && typeof node[1] === "string";
  const isToolCall = Array.isArray(node[10]);
  if (isTextContent || isToolCall) yield node;
  for (const element of node) yield* findAllPayloadsInChunk(element);
}

function* parseGoogleStreamToOpenAI(googleStream) {
  for (const chunk of googleStream) {
    for (const payload of findAllPayloadsInChunk(chunk)) {
      const toolCallData = payload[10];
      if (Array.isArray(toolCallData) && typeof toolCallData[0] === "string") {
        try {
          const args = {};
          for (const arg of toolCallData[1]?.[0] || []) {
            if (arg[0]) args[arg[0]] = arg[1]?.[2];
          }
          yield {
            choices: [
              {
                index: 0,
                delta: {
                  role: "assistant",
                  content: null,
                  tool_calls: [
                    {
                      index: 0,
                      id: `call_${Math.random().toString(36).slice(2)}`,
                      type: "function",
                      function: {
                        name: toolCallData[0],
                        arguments: JSON.stringify(args),
                      },
                    },
                  ],
                },
              },
            ],
          };
        } catch (e) {
          console.warn("Could not parse tool call chunk:", e);
        }
      }
      const textContent = payload[1];
      if (typeof textContent === "string" && textContent.trim().length > 0) {
        yield {
          choices: [
            { index: 0, delta: { role: "assistant", content: textContent } },
          ],
        };
      }
    }
  }
}

function createOpenAICompletion(googleStream, modelName = "gemini-pro") {
  let aggregatedContent = "";
  const aggregatedToolCalls = [];
  let finishReason = "stop";

  for (const chunk of parseGoogleStreamToOpenAI(googleStream)) {
    const delta = chunk.choices[0].delta;
    if (delta.content) aggregatedContent += delta.content;
    if (delta.tool_calls) {
      finishReason = "tool_calls";
      aggregatedToolCalls.push(...delta.tool_calls);
    }
  }
  const message = { role: "assistant" };
  if (aggregatedToolCalls.length > 0) {
    message.tool_calls = aggregatedToolCalls;
    message.content = null;
  } else {
    message.content = aggregatedContent;
  }
  return {
    id: `chatcmpl-${Math.random().toString(36).slice(2)}`,
    object: "chat.completion",
    created: Math.floor(Date.now() / 1000),
    model: modelName,
    choices: [{ index: 0, message: message, finish_reason: finishReason }],
    usage: { prompt_tokens: 0, completion_tokens: 0, total_tokens: 0 },
  };
}
