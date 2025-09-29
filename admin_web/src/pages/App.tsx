import React from "react";
import { Link, Outlet, useLocation } from "react-router-dom";

export const App: React.FC = () => {
  const { pathname } = useLocation();
  return (
    <div style={{ display: "flex", minHeight: "100vh" }}>
      <nav
        style={{
          width: 220,
          background: "#2e1065",
          color: "white",
          padding: 16,
        }}
      >
        <h3 style={{ marginTop: 0 }}>Swift Ride Admin</h3>
        <ul style={{ listStyle: "none", padding: 0 }}>
          <li>
            <Link style={linkStyle(pathname === "/")} to="/">
              Dashboard
            </Link>
          </li>
          <li>
            <Link style={linkStyle(pathname.startsWith("/trips"))} to="/trips">
              Trips
            </Link>
          </li>
          <li>
            <Link style={linkStyle(pathname.startsWith("/users"))} to="/users">
              Users
            </Link>
          </li>
          <li>
            <Link
              style={linkStyle(pathname.startsWith("/payments"))}
              to="/payments"
            >
              Payments
            </Link>
          </li>
        </ul>
      </nav>
      <main style={{ flex: 1, padding: 24 }}>
        <Outlet />
      </main>
    </div>
  );
};

const linkStyle = (active: boolean): React.CSSProperties => ({
  color: "white",
  textDecoration: active ? "underline" : "none",
  display: "block",
  padding: "8px 0",
});
