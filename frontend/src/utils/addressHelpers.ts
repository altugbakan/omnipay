import {
  baseGoerli,
  modeTestnet,
  optimismGoerli,
  zoraTestnet,
} from "wagmi/chains";
import contracts from "../abi/contracts.json";

export function getUsdcAddress(chain: number | undefined): string {
  switch (chain) {
    case optimismGoerli.id:
      return contracts.OptimismUSDC;
    case baseGoerli.id:
      return contracts.BaseUSDC;
    case zoraTestnet.id:
      return contracts.ZoraUSDC;
    case modeTestnet.id:
      return contracts.ModeUSDC;
    default:
      return contracts.OptimismUSDC;
  }
}

export function getOmniPayAddress(chain: number | undefined): string {
  switch (chain) {
    case optimismGoerli.id:
      return contracts.OmniPayCore;
    case baseGoerli.id:
      return contracts.BaseOmniPayClient;
    case zoraTestnet.id:
      return contracts.ZoraOmniPayClient;
    case modeTestnet.id:
      return contracts.ModeOmniPayClient;
    default:
      return contracts.OmniPayCore;
  }
}
