import {
  useAccount,
  useContractRead,
  useContractWrite,
  useNetwork,
  usePrepareContractWrite,
  useWaitForTransaction,
} from "wagmi";
import { getOmniPayAddress, getUsdcAddress } from "../utils/addressHelpers";
import omniPayClient from "../abi/OmniPayClient.json";
import fakeUSDC from "../abi/FakeUSDC.json";
import { useEffect, useState } from "react";
import ChainSelector from "./ChainSelector";
import { toBigInt } from "../utils/bigIntHelpers";
import { useDebounce } from "use-debounce";

export default function DepositDialog({ className }: { className?: string }) {
  const { chain } = useNetwork();
  const { address } = useAccount();
  const [amount, setAmount] = useState(0);
  const [debouncedAmount] = useDebounce(amount, 500);
  const [needsApproval, setNeedsApproval] = useState(false);

  const {
    data: allowance,
    isLoading: isAllowanceLoading,
  }: { data: BigInt | undefined; isLoading: boolean } = useContractRead({
    address: getUsdcAddress(chain?.id) as `0x${string}`,
    abi: fakeUSDC.abi,
    chainId: chain?.id,
    functionName: "allowance",
    args: [address, getOmniPayAddress(chain?.id)],
  });

  const { config: approveConfig } = usePrepareContractWrite({
    address: getUsdcAddress(chain?.id) as `0x${string}`,
    abi: fakeUSDC.abi,
    chainId: chain?.id,
    functionName: "approve",
    args: [getOmniPayAddress(chain?.id), toBigInt(debouncedAmount)],
  });
  const {
    write: approve,
    isLoading: isApproveLoading,
    data: approveData,
  } = useContractWrite(approveConfig);
  const { isSuccess: isApproveSuccess } = useWaitForTransaction({
    hash: approveData?.hash,
  });

  const { config: depositConfig } = usePrepareContractWrite({
    address: getOmniPayAddress(chain?.id) as `0x${string}`,
    abi: omniPayClient.abi,
    chainId: chain?.id,
    functionName: "deposit",
    args: [toBigInt(debouncedAmount)],
    enabled: !needsApproval,
  });
  const {
    write: deposit,
    isLoading: isDepositLoading,
    data: depositData,
  } = useContractWrite(depositConfig);
  const { isSuccess: isDepositSuccess } = useWaitForTransaction({
    hash: depositData?.hash,
  });

  useEffect(() => {
    setNeedsApproval(
      !isApproveSuccess &&
        !isAllowanceLoading &&
        debouncedAmount !== 0 &&
        allowance! < toBigInt(debouncedAmount)
    );
  }, [allowance, debouncedAmount, isAllowanceLoading, isApproveSuccess]);

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
          {needsApproval && (
            <button
              className="btn btn-primary ml-8"
              disabled={isApproveLoading || !approve}
              onClick={() => approve!()}
            >
              Approve
            </button>
          )}
          {!needsApproval && (
            <button
              className="btn btn-primary ml-8"
              disabled={isAllowanceLoading || !deposit}
              onClick={() => deposit!()}
            >
              Deposit
            </button>
          )}
        </div>
        {isDepositLoading ||
          (isAllowanceLoading && (
            <div className="text-info">Confirm in your wallet...</div>
          ))}
        {isDepositSuccess && (
          <div className="text-success">Deposit successful!</div>
        )}
      </div>
    </div>
  );
}
