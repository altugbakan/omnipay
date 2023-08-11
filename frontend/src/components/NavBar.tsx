import { NavLink } from "react-router-dom";
import NavElement from "./NavElement";
import { ConnectButton } from "./ConnectButton";
import ChainSelector from "./ChainSelector";

export default function NavBar() {
  return (
    <nav className="navbar px-8">
      <div className="navbar-start">
        <NavLink to="/" className="flex flex-row gap-2 btn btn-ghost p-1">
          <img
            src="/omnipay.png"
            alt="OmniPay"
            className="w-8 h-8 rounded-full"
          />
          <h2 className="text-xl text-primary">OmniPay</h2>
        </NavLink>
      </div>
      <div className="navbar-center flex gap-2">
        <NavElement to="/">Home</NavElement>
        <NavElement to="/dashboard">Dashboard</NavElement>
        <NavElement to="/deposit">Deposit</NavElement>
        <NavElement to="/withdraw">Withdraw</NavElement>
      </div>
      <div className="navbar-end gap-2">
        <ChainSelector />
        <ConnectButton className="btn-primary" />
      </div>
    </nav>
  );
}
