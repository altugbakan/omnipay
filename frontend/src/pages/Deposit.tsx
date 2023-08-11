import { Navigate } from "react-router-dom";
import BalanceDialog from "../components/BalanceDialog";
import { useAccount } from "wagmi";
import DepositDialog from "../components/DepositDialog";
import USDCMintDialog from "../components/USDCMintDialog";

export default function Deposit() {
  const { isConnected } = useAccount();

  return (
    <>
      {isConnected ? null : <Navigate to="/" />}
      <div className="flex flex-row items-center justify-center p-16 gap-4">
        <BalanceDialog />
        <DepositDialog className="w-80" />
        <USDCMintDialog />
      </div>
    </>
  );
}
