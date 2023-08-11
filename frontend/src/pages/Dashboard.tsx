import { Navigate } from "react-router-dom";
import { useAccount } from "wagmi";
import BalanceDialog from "../components/BalanceDialog";
import DepositWithdrawDialog from "../components/DepositWithdrawDialog";

export default function Dashboard() {
  const { isConnected } = useAccount();

  return (
    <>
      {isConnected ? null : <Navigate to="/" />}
      <div className="flex flex-row items-center justify-center p-16">
        <BalanceDialog />
        <DepositWithdrawDialog className="w-80" />
      </div>
    </>
  );
}
