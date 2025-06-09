/**
 * The background script for the AI Studio extension.
 *
 * `--silent-debugger-extension-api` flag can be used to suppress
 * the pop-up message about the debugger extension.
 */
const SERVER_URL = "ws://localhost:4437";
const DEBUGGER_URL_PATTERN = "*MakerSuiteService/GenerateContent*";

let relaySocket = null;
const debuggerAttachedTabs = new Map();

async function handleServerMessage(event) {
  const command = JSON.parse(event.data);
  if (command.type !== "SEND_CHAT_MESSAGE") return;

  console.log(`Received SEND_CHAT_MESSAGE for requestId: ${command.requestId}`);
  const tabs = await chrome.tabs.query({ url: "*://aistudio.google.com/*" });

  if (tabs.length === 0) {
    console.error("No AI Studio tab found.");
    return;
  }

  const lastTab = tabs[tabs.length - 1];
  const tabId = lastTab.id;

  const tabInfo = debuggerAttachedTabs.get(tabId);
  if (!tabInfo) {
    console.error(
      `Could not get tabInfo for tab ${tabId} after setup attempt.`,
    );
    return;
  }

  tabInfo.lastKnownRequestId = command.requestId;

  try {
    if (!tabInfo.scriptInjected) {
      console.log(`Injecting content script into tab ${tabId}.`);
      await chrome.scripting.executeScript({
        target: { tabId: tabId },
        files: ["content.js"],
      });
      tabInfo.scriptInjected = true;
    }

    await chrome.tabs.sendMessage(tabId, command);
    console.log(`Message sent successfully to tab ${tabId}.`);
  } catch (error) {
    console.error(`Failed to send message:`, error);
  }
}

function connectToRelayServer() {
  if (relaySocket && relaySocket.readyState === WebSocket.OPEN) return;

  console.log(`Attempting to connect to ${SERVER_URL}`);
  relaySocket = new WebSocket(SERVER_URL);

  relaySocket.onopen = () => console.log("Connection established.");
  relaySocket.onclose = () => {
    console.log("Connection closed. Reconnecting in 5s.");
    relaySocket = null;
    setTimeout(connectToRelayServer, 5000);
  };
  relaySocket.onerror = (error) => console.error("WebSocket Error:", error);
  relaySocket.onmessage = handleServerMessage;
}

async function setupDebuggerForTab(tabId) {
  const debuggee = { tabId };
  try {
    await chrome.debugger.attach(debuggee, "1.3");
  } catch (error) {
    if (!error.message.includes("already attached")) {
      console.error(`Failed to attach debugger:`, error.message);
      return;
    }
  }

  debuggerAttachedTabs.set(tabId, {
    lastKnownRequestId: null,
    scriptInjected: false,
  });
  console.log(`Debugger state configured for tab ${tabId}.`);

  await chrome.debugger.sendCommand(debuggee, "Fetch.enable", {
    patterns: [{ urlPattern: DEBUGGER_URL_PATTERN, requestStage: "Response" }],
  });
}

chrome.tabs.onUpdated.addListener((tabId, changeInfo, tab) => {
  if (
    changeInfo.status === "complete" &&
    tab.url &&
    tab.url.includes("aistudio.google.com") &&
    !debuggerAttachedTabs.has(tabId)
  ) {
    console.log("AI Studio tab updated. Re-initializing debugger setup.");
    setupDebuggerForTab(tabId);
  }
});

chrome.runtime.onMessage.addListener((message) => {
  if (message.type !== "FINAL_RESPONSE") return;

  if (relaySocket && relaySocket.readyState === WebSocket.OPEN) {
    console.log(
      `Forwarding FINAL_RESPONSE for requestId: ${message.requestId}`,
    );
    relaySocket.send(JSON.stringify(message));
  }
});

chrome.debugger.onEvent.addListener(async (debuggeeId, method, params) => {
  if (method !== "Fetch.requestPaused") return;

  const tabId = debuggeeId.tabId;
  const tabInfo = debuggerAttachedTabs.get(tabId);
  const currentRequestId = tabInfo?.lastKnownRequestId;

  if (currentRequestId === null || currentRequestId === undefined) {
    chrome.debugger.sendCommand(debuggeeId, "Fetch.continueRequest", {
      requestId: params.requestId,
    });
    return;
  }

  try {
    const response = await chrome.debugger.sendCommand(
      debuggeeId,
      "Fetch.getResponseBody",
      { requestId: params.requestId },
    );
    const body = response.base64Encoded ? atob(response.body) : response.body;

    chrome.tabs.sendMessage(tabId, {
      type: "DEBUGGER_RESPONSE",
      requestId: currentRequestId,
      data: body,
    });
  } catch (error) {
    console.error(
      `Error getting response body for requestId ${currentRequestId}:`,
      error.message,
    );
  } finally {
    chrome.debugger.sendCommand(debuggeeId, "Fetch.continueRequest", {
      requestId: params.requestId,
    });
  }
});

chrome.tabs.onRemoved.addListener((tabId) => {
  if (debuggerAttachedTabs.has(tabId)) {
    chrome.debugger.detach({ tabId });
    debuggerAttachedTabs.delete(tabId);
  }
});

connectToRelayServer();
