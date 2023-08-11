import { Outlet } from "react-router-dom";
import NavBar from "../components/NavBar";
import Footer from "../components/Footer";

export default function Root() {
  return (
    <div className="flex flex-col justify-between h-full bg-gradient-to-br from-base-100 to-base-200">
      <div>
        <NavBar />
        <div className="divider m-0" />
      </div>
      <Outlet />
      <div>
        <div className="divider m-0" />
        <Footer />
      </div>
    </div>
  );
}
