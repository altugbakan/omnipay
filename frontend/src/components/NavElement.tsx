import React from "react";
import { NavLink } from "react-router-dom";

export default function NavElement({
  children,
  to,
}: {
  children?: React.ReactNode;
  to: string;
}) {
  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        "btn btn-ghost p-2 border-none text-lg" + (isActive ? " text-info" : "")
      }
    >
      {children}
    </NavLink>
  );
}
