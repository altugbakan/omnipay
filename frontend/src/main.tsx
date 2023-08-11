import React from "react";
import ReactDOM from "react-dom/client";
import "./index.css";
import { WagmiConfig } from "wagmi";
import {
  createBrowserRouter,
  createRoutesFromElements,
  Route,
  RouterProvider,
} from "react-router-dom";
import ErrorPage from "./components/Error";
import { config } from "./utils/chainConfig.js";
import Home from "./pages/Home";
import Dashboard from "./pages/Dashboard";
import Root from "./layouts/Root";
import Deposit from "./pages/Deposit";
import Withdraw from "./pages/Withdraw";

const router = createBrowserRouter(
  createRoutesFromElements(
    <Route path="/" element={<Root />} errorElement={<ErrorPage />}>
      <Route index element={<Home />} />
      <Route path="dashboard" element={<Dashboard />} />
      <Route path="deposit" element={<Deposit />} />
      <Route path="withdraw" element={<Withdraw />} />
    </Route>
  )
);

const rootElement = document.getElementById("root");
if (rootElement) {
  ReactDOM.createRoot(rootElement).render(
    <React.StrictMode>
      <WagmiConfig config={config}>
        <RouterProvider router={router} />
      </WagmiConfig>
    </React.StrictMode>
  );
}
