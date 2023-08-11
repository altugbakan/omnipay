import { ConnectButton } from "../components/ConnectButton";
import { useAccount } from "wagmi";
import { Navigate } from "react-router-dom";

export default function Home() {
  const { isConnected } = useAccount();

  return (
    <>
      {isConnected ? <Navigate to="/dashboard" /> : null}
      <div className="hero min-h-screen px-6">
        <div className="hero-content flex-col md:flex-row">
          <img
            src="/omnipay-cover.png"
            className="max-w-sm rounded-lg shadow-2xl"
          />
          <div className="text-center">
            <h1 className="text-5xl font-bold">Deposit Once, Pay Anywhere</h1>
            <p className="py-6">Connect your wallet to get started.</p>
            <ConnectButton className="btn-primary" />
          </div>
        </div>
      </div>
    </>
  );
}
