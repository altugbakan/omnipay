import { useAccount, useContractRead, useNetwork } from "wagmi";
import contracts from "../abi/contracts.json";
import omniPayCore from "../abi/OmniPayCore.json";
import fakeUSDC from "../abi/FakeUSDC.json";
import { optimismGoerli } from "wagmi/chains";
import { toFixed } from "../utils/bigIntHelpers";
import { getUsdcAddress } from "../utils/addressHelpers";

export default function BalanceDialog() {
  const { address } = useAccount();
  const { chain } = useNetwork();

  const {
    data: omniPayCoreBalance,
    isLoading: isOmniPayCoreBalanceLoading,
  }: { data: BigInt | undefined; isLoading: boolean } = useContractRead({
    address: contracts.OmniPayCore as `0x${string}`,
    abi: omniPayCore.abi,
    chainId: optimismGoerli.id,
    functionName: "balances",
    args: [address],
  });

  const {
    data: walletBalance,
    isLoading: isWalletBalanceLoading,
  }: { data: BigInt | undefined; isLoading: boolean } = useContractRead({
    address: getUsdcAddress(chain?.id) as `0x${string}`,
    abi: fakeUSDC.abi,
    chainId: chain?.id,
    functionName: "balanceOf",
    args: [address],
  });

  return (
    <div className="card w-96 bg-base-100 shadow-xl">
      <div className="card-body">
        <h2 className="card-title text-secondary">Your OmniPay Balance</h2>
        <p className="flex justify-center align-middle gap-1">
          <span className="text-3xl font-bold inline-flex items-center">
            {isOmniPayCoreBalanceLoading
              ? "Loading..."
              : toFixed(omniPayCoreBalance)}
          </span>
          <span className="inline-flex items-center">USDC</span>
        </p>
      </div>
      <div className="divider"></div>
      <div className="card-body">
        <h2 className="card-title text-secondary">Your Wallet Balance</h2>
        <p className="flex justify-center align-middle gap-1">
          <span className="text-3xl font-bold inline-flex items-center">
            {isWalletBalanceLoading ? "Loading..." : toFixed(walletBalance)}
          </span>
          <span className="inline-flex items-center">USDC</span>
        </p>
      </div>
    </div>
  );
}
