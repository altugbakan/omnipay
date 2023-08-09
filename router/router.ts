import { ethers, getNumber } from "ethers";
import externalRouter from "./abi/ExternalRouter.json" assert { type: "json" };
import contracts from "./abi/contracts.json" assert { type: "json" };
import { JsonRpcProvider } from "ethers";
import dotenv from "dotenv";
dotenv.config();

function rotateHexString(hexString: string): string {
  hexString = hexString.replace("0x", "");
  hexString =
    hexString.slice(hexString.length / 2) +
    hexString.slice(0, hexString.length / 2);

  return `0x${hexString}`;
}

function processMessage(
  message: any[],
  fromChain: "optimism" | "zora" | "mode"
): any[] {
  message = [...message];

  switch (fromChain) {
    case "optimism":
      message[0] = 10132n;
      break;
    case "zora":
      message[0] = 9999n;
      break;
    case "mode":
      message[0] = 9998n;
      break;
  }

  message[1] = rotateHexString(message[1]);

  return message;
}

// Set up providers
const optimismProviderURl = "https://optimism-goerli.publicnode.com";
const zoraProviderUrl = "https://testnet.rpc.zora.co";
const modeProviderUrl = "https://sepolia.mode.network/";

// Initialize clients
const optimismProvider = new JsonRpcProvider(optimismProviderURl);
const optimismWallet = new ethers.Wallet(
  process.env.BOT_PRIVATE_KEY,
  optimismProvider
);

const zoraProvider = new JsonRpcProvider(zoraProviderUrl);
const zoraWallet = new ethers.Wallet(process.env.BOT_PRIVATE_KEY, zoraProvider);

const modeProvider = new JsonRpcProvider(modeProviderUrl);
const modeWallet = new ethers.Wallet(process.env.BOT_PRIVATE_KEY, modeProvider);

const optimismRouterAddress = contracts.OptimismExternalRouter;
const zoraRouterAddress = contracts.ZoraExternalRouter;
const modeRouterAddress = contracts.ModeExternalRouter;

const optimismRouter = new ethers.Contract(
  optimismRouterAddress,
  externalRouter.abi,
  optimismWallet
);

const zoraRouter = new ethers.Contract(
  zoraRouterAddress,
  externalRouter.abi,
  zoraWallet
);

const modeRouter = new ethers.Contract(
  modeRouterAddress,
  externalRouter.abi,
  modeWallet
);

// Find non-processed messages
console.log("Processing messages on optimismRouter");
const optimismQueueLength = getNumber(await optimismRouter.queueLength());
for (let i = optimismQueueLength - 1; i >= 0; i--) {
  let message = await optimismRouter.messageQueue(i);
  console.log(`Processing message: ${message}`);

  let toChain: "zora" | "mode";
  if (message[0] === 9999n) {
    toChain = "zora";
  } else if (message[0] === 9998n) {
    toChain = "mode";
  } else {
    console.log("Message not for Zora or Mode, skipping...");
    continue;
  }

  switch (toChain) {
    case "zora":
      await zoraRouter.route(processMessage(message, "optimism"));
      console.log("Routed message to zoraRouter.");
      break;
    case "mode":
      await modeRouter.route(processMessage(message, "optimism"));
      console.log("Routed message to modeRouter.");
      break;
  }

  await optimismRouter.pop();
  console.log("Popped message on optimismRouter.");
}

console.log(
  optimismQueueLength === 0
    ? "No messages to process on optimismRouter."
    : "Processed messages on optimismRouter."
);

console.log("Processing messages on zoraRouter...");
const zoraQueueLength = getNumber(await zoraRouter.queueLength());
for (let i = zoraQueueLength - 1; i >= 0; i--) {
  let message = await zoraRouter.messageQueue(i);
  console.log(`Processing message: ${message}`);

  await optimismRouter.route(processMessage(message, "zora"));
  console.log("Routed message to optimismRouter.");
  await zoraRouter.pop();
  console.log("Popped message on zoraRouter.");
}
console.log(
  zoraQueueLength === 0
    ? "No messages to process on zoraRouter."
    : "Processed messages on zoraRouter."
);

console.log("Processing messages on modeRouter...");
const modeQueueLength = getNumber(await modeRouter.queueLength());
for (let i = modeQueueLength - 1; i >= 0; i--) {
  let message = await modeRouter.messageQueue(i);
  console.log(`Processing message: ${message}`);

  await optimismRouter.route(processMessage(message, "mode"));
  console.log("Routed message to optimismRouter.");
  await modeRouter.pop();
  console.log("Popped message on modeRouter.");
}
console.log(
  modeQueueLength === 0
    ? "No messages to process on modeRouter."
    : "Processed messages on modeRouter."
);

// Listen for new events
optimismRouter.on("MessageSent", async (message) => {
  console.log(`Received message from optimismRouter: ${message}`);

  let toChain: "zora" | "mode";
  if (message[0] === 9999n) {
    toChain = "zora";
  } else if (message[0] === 9998n) {
    toChain = "mode";
  } else {
    console.log("Message not for Zora or Mode, skipping...");
    return;
  }

  switch (toChain) {
    case "zora":
      await zoraRouter.route(processMessage(message, "optimism"));
      console.log("Routed message to zoraRouter.");
      break;
    case "mode":
      await modeRouter.route(processMessage(message, "optimism"));
      console.log("Routed message to modeRouter.");
      break;
  }

  await optimismRouter.pop();
  console.log(`Popped messages on optimismRouter.`);
});

zoraRouter.on("MessageSent", async (message) => {
  console.log(`Received message from zoraRouter: ${message}`);

  await optimismRouter.route(processMessage(message, "zora"));
  console.log("Routed message to optimismRouter");
  await zoraRouter.pop();
  console.log("Popped message on zoraRouter.");
});

modeRouter.on("MessageSent", async (message) => {
  console.log(`Received message from modeRouter: ${message}`);

  await optimismRouter.route(processMessage(message, "mode"));
  console.log("Routed message to optimismRouter");
  await modeRouter.pop();
  console.log("Popped message on modeRouter.");
});

console.log("\nListening for new messages...");
