import { createPublicClient, http } from "viem";
import { configureChains, createConfig } from "wagmi";
import {
  optimismGoerli,
  baseGoerli,
  zoraTestnet,
  modeTestnet,
} from "wagmi/chains";
import { InjectedConnector } from "wagmi/connectors/injected";
import { publicProvider } from "wagmi/providers/public";

const { chains, publicClient } = configureChains(
  [optimismGoerli, baseGoerli, zoraTestnet, modeTestnet],
  [publicProvider()]
);

export const optimismProvider = createPublicClient({
  chain: optimismGoerli,
  transport: http(),
});

export const config = createConfig({
  autoConnect: true,
  connectors: [
    new InjectedConnector({
      chains,
      options: {
        name: "Injected",
        shimDisconnect: true,
      },
    }),
  ],
  publicClient,
});
