import { FaArrowDown, FaArrowUp } from "react-icons/fa";
import { Link } from "react-router-dom";

export default function DepositWithdrawDialog({
  className,
}: {
  className?: string;
}) {
  return (
    <div
      className={`card flex flex-col gap-4 w-48 bg-base-100 shadow-xl ${className}`}
    >
      <div className="card-body">
        <Link to="/deposit" className="btn btn-primary flex flex-row">
          Deposit <FaArrowUp />
        </Link>
        <div className="divider" />
        <Link to="/withdraw" className="btn btn-primary">
          Withdraw <FaArrowDown />
        </Link>
      </div>
    </div>
  );
}
