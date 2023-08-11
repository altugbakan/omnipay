import { Navigate } from "react-router-dom";
import BalanceDialog from "../components/BalanceDialog";
import { useAccount } from "wagmi";
import WithdrawDialog from "../components/WithdrawDialog";

export default function Withdraw() {
  const { isConnected } = useAccount();

  return (
    <>
      {isConnected ? null : <Navigate to="/" />}
      <div className="flex flex-row items-center justify-center p-16 gap-4">
        <BalanceDialog />
        <WithdrawDialog className="w-80" />
      </div>
    </>
  );
}
