import {
  createWalletClient,
  decodeAbiParameters,
  encodeAbiParameters,
  getContract,
  http,
  parseAbiParameters,
} from "viem";
import { privateKeyToAccount } from "viem/accounts";
import { zoraTestnet, optimismGoerli } from "viem/chains";
import externalRouter from "./abi/ExternalRouter.json" assert { type: "json" };
import dotenv from "dotenv";
dotenv.config();

// Initialize clients
const account = privateKeyToAccount(
  process.env.BOT_PRIVATE_KEY as `0x${string}`
);

const optimismRouterAddress = process.env
  .OPTIMISM_ROUTER_ADDRESS as `0x${string}`;
const zoraRouterAddress = process.env.ZORA_ROUTER_ADDRESS as `0x${string}`;

const zoraClient = createWalletClient({
  account,
  chain: zoraTestnet,
  transport: http(),
});

const optimismClient = createWalletClient({
  account,
  chain: optimismGoerli,
  transport: http(),
});

const optimismRouter = getContract({
  abi: externalRouter.abi,
  address: optimismRouterAddress,
  walletClient: optimismClient,
});

const zoraRouter = getContract({
  abi: externalRouter.abi,
  address: zoraRouterAddress,
  walletClient: zoraClient,
});

// Get source chain ids
const optimismChainId = await optimismRouter.read.currentChainId();
const zoraChainId = await zoraRouter.read.currentChainId();

// Find non-processed events
console.log("Processing events on optimismRouter");
const optimismQueue: Uint8Array[] =
  (await optimismRouter.read.messageQueue()) as Uint8Array[];
for (let item in optimismQueue) {
  const values = decodeAbiParameters(
    parseAbiParameters("uint16, bytes, bytes"),
    `0x${item}`
  );
  const srcAddress = encodeAbiParameters(
    parseAbiParameters("address, address"),
    [optimismRouterAddress, zoraRouterAddress]
  );

  await zoraRouter.write.route([optimismChainId, srcAddress, values[2]]);
  console.log(`Processed item ${item} on zoraRouter`);
  await optimismRouter.write.pop();
  console.log(`Popped item ${item} on optimismRouter`);
}
console.log(
  optimismQueue.length === 0
    ? "No events to process"
    : "Processed events on optimismRouter"
);

console.log("Processing events on zoraRouter...");
const zoraQueue: Uint8Array[] =
  (await zoraRouter.read.messageQueue()) as Uint8Array[];
for (let item in zoraQueue) {
  const values = decodeAbiParameters(
    parseAbiParameters("uint16, bytes, bytes"),
    `0x${item}`
  );
  const srcAddress = encodeAbiParameters(
    parseAbiParameters("address, address"),
    [zoraRouterAddress, optimismRouterAddress]
  );

  await optimismRouter.write.route([zoraChainId, srcAddress, values[2]]);
  console.log(`Processed item ${item} on optimismRouter.`);
  await zoraRouter.write.pop();
  console.log(`Popped item ${item} on zoraRouter.`);
}
console.log(
  zoraQueue.length === 0
    ? "No events to process."
    : "Processed events on zoraRouter."
);

// Listen for new events
optimismRouter.watchEvent.MessageSent({
  onLogs: (logs) => {
    const data = logs[0].data;
    console.log(`Received logs from optimismRouter: ${data}`);
    const values = decodeAbiParameters(
      parseAbiParameters("uint16, bytes, bytes"),
      `0x${data}`
    );

    zoraRouter.write.route(values);
    console.log(`Processed item ${data} on zoraRouter.`);
    optimismRouter.write.pop();
    console.log(`Popped item ${data} on optimismRouter.`);
  },
});

zoraRouter.watchEvent.MessageSent({
  onLogs: (logs) => {
    const data = logs[0].data;
    console.log(`Received logs from zoraRouter: ${data}`);
    const values = decodeAbiParameters(
      parseAbiParameters("uint16, bytes, bytes"),
      `0x${data}`
    );

    optimismRouter.write.route(values);
    console.log(`Processed item ${data} on optimismRouter.`);
    zoraRouter.write.pop();
    console.log(`Popped item ${data} on zoraRouter.`);
  },
});

console.log("Listening for events...");
