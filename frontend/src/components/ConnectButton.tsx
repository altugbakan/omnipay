import { useAccount, useConnect, useDisconnect } from "wagmi";

export function ConnectButton({ className }: { className?: string }) {
  const { address, isConnected } = useAccount();
  const { connect, connectors } = useConnect();
  const { disconnect } = useDisconnect();
  const cls = "btn text-lg" + (className ? " " + className : "");

  if (isConnected && address) {
    return (
      <button className={cls} onClick={() => disconnect()}>
        <div>
          {address.slice(0, 5) + "..." + address.slice(address.length - 4)}
        </div>
      </button>
    );
  }

  return (
    <button
      className={cls}
      onClick={() => connect({ connector: connectors[0] })}
    >
      Connect Wallet
    </button>
  );
}
