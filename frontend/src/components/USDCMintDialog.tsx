import {
  useAccount,
  useContractRead,
  useContractWrite,
  useNetwork,
  usePrepareContractWrite,
} from "wagmi";
import { getUsdcAddress } from "../utils/addressHelpers";
import fakeUSDC from "../abi/FakeUSDC.json";

export default function USDCMintDialog({ className }: { className?: string }) {
  const { chain } = useNetwork();
  const { address } = useAccount();

  const {
    data: isMinted,
    isLoading: isMintedLoading,
  }: { data: boolean | undefined; isLoading: boolean } = useContractRead({
    address: getUsdcAddress(chain?.id) as `0x${string}`,
    abi: fakeUSDC.abi,
    chainId: chain?.id,
    functionName: "minted",
    args: [address],
  });

  const { config } = usePrepareContractWrite({
    address: getUsdcAddress(chain?.id) as `0x${string}`,
    abi: fakeUSDC.abi,
    chainId: chain?.id,
    functionName: "mintOnce",
    args: [address],
  });
  const { write, isLoading, isSuccess } = useContractWrite(config);

  if (isSuccess || isMintedLoading || isMinted) {
    return null;
  }

  return (
    <div className={`card w-96 bg-base shadow-xl ${className}`}>
      <div className="card-body">
        <h2 className="card-title">Need USDC?</h2>
        <button
          className="btn btn-primary"
          disabled={!write}
          onClick={() => write!()}
        >
          Mint
        </button>
        {isLoading && (
          <div className="text-info">Confirm in your wallet...</div>
        )}
      </div>
    </div>
  );
}
