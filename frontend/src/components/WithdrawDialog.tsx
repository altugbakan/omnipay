import { useState } from "react";
import ChainSelector from "./ChainSelector";
import { useDebounce } from "use-debounce";
import {
  useAccount,
  useContractRead,
  useContractWrite,
  useNetwork,
  usePrepareContractWrite,
  useWaitForTransaction,
} from "wagmi";
import contracts from "../abi/contracts.json";
import omniPayCore from "../abi/OmniPayCore.json";
import { optimismGoerli } from "wagmi/chains";
import { toBigInt, toNumber } from "../utils/bigIntHelpers";
import { getOmniPayAddress } from "../utils/addressHelpers";
import omniPayClient from "../abi/OmniPayClient.json";

export default function WithdrawDialog({ className }: { className?: string }) {
  const { address } = useAccount();
  const { chain } = useNetwork();
  const [amount, setAmount] = useState(0);
  const [debouncedAmount] = useDebounce(amount, 500);

  const { config: withdrawConfig } = usePrepareContractWrite({
    address: getOmniPayAddress(chain?.id) as `0x${string}`,
    abi: omniPayClient.abi,
    chainId: chain?.id,
    functionName: "withdraw",
    args: [toBigInt(debouncedAmount)],
  });
  const {
    write: withdraw,
    isLoading: isWithdrawLoading,
    data: approveData,
  } = useContractWrite(withdrawConfig);
  const { isSuccess: isWithdrawSuccess } = useWaitForTransaction({
    hash: approveData?.hash,
  });

  const {
    data: omniPayCoreBalance,
  }: { data: BigInt | undefined; isLoading: boolean } = useContractRead({
    address: contracts.OmniPayCore as `0x${string}`,
    abi: omniPayCore.abi,
    chainId: optimismGoerli.id,
    functionName: "balances",
    args: [address],
  });

  return (
    <div className={`card bg-base w-fit shadow-xl ${className}`}>
      <div className="card-body">
        <h2 className="card-title">Select a chain</h2>
        <ChainSelector />
      </div>
      <div className="divider" />
      <div className="card-body">
        <h2 className="card-title">Amount</h2>
        <div className="flex flex-row gap-1">
          <input
            className="text-right outline-none border-none bg-inherit text-3xl font-bold inline-flex items-center w-32"
            placeholder="0.00"
            inputMode="numeric"
            onChange={(e) => setAmount(parseFloat(e.target.value))}
          />
          <span className="inline-flex items-center">USDC</span>
          <button
            onClick={withdraw}
            disabled={amount > toNumber(omniPayCoreBalance)}
            className="btn btn-primary ml-8"
          >
            Withdraw
          </button>
        </div>
        {isWithdrawLoading && (
          <div className="text-info">Confirm in your wallet...</div>
        )}
        {isWithdrawSuccess && (
          <div className="text-success">
            Withdrawal successful! Your tokens will arrive at your wallet soon.
          </div>
        )}
      </div>
    </div>
  );
}
