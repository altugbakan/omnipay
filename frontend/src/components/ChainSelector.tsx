import { useNetwork, useSwitchNetwork } from "wagmi";
import {
  baseGoerli,
  modeTestnet,
  optimismGoerli,
  zoraTestnet,
} from "wagmi/chains";

export default function ChainSelector({ className }: { className?: string }) {
  const { chain } = useNetwork();
  const { chains, switchNetwork } = useSwitchNetwork();

  const chainList = [
    { name: "Optimism", id: optimismGoerli.id },
    { name: "Base", id: baseGoerli.id },
    { name: "Zora", id: zoraTestnet.id },
    { name: "Mode", id: modeTestnet.id },
  ] as const;

  function switchToChain(chainName: "Optimism" | "Base" | "Zora" | "Mode") {
    switchNetwork?.(chainList.find((c) => c.name === chainName)!.id);
  }

  if (!chain) {
    return null;
  }

  if (!chains.find((c) => c.id === chain.id)) {
    return (
      <button
        className="btn btn-error"
        onClick={() => switchToChain("Optimism")}
      >
        Switch to Optimism
      </button>
    );
  }

  return (
    <select
      onChange={(e) => switchToChain(e.target.value as any)}
      value={chainList.find((c) => c.id === chain.id)!.name}
      className={`select select-md select-primary ${className}`}
    >
      {chainList.map((c) => (
        <option key={c.name} value={c.name}>
          {c.name}
        </option>
      ))}
    </select>
  );
}
