import React from "react";
import { Link, Outlet, useLocation } from "react-router-dom";
import { useTheme } from "../lib/ThemeContext";

export const App: React.FC = () => {
  const { pathname } = useLocation();
  const { theme, toggleTheme } = useTheme();

  return (
    <div
      style={{
        display: "grid",
        gridTemplateRows: "56px 1fr",
        minHeight: "100vh",
      }}
    >
      <header
        className="gradient-header"
        style={{
          display: "flex",
          alignItems: "center",
          padding: "0 20px",
          borderBottom: "1px solid var(--border)",
        }}
      >
        <div
          className="container"
          style={{ display: "flex", alignItems: "center", gap: 16, justifyContent: "space-between", width: "100%" }}
        >
          <div style={{ display: "flex", alignItems: "center", gap: 16 }}>
            <div style={{ fontWeight: 800 }}>Swift Ride Admin</div>
            <nav style={{ display: "flex", gap: 16 }}>
              <Link style={linkStyle(pathname === "/")} to="/">
                Dashboard
              </Link>
              <Link style={linkStyle(pathname.startsWith("/trips"))} to="/trips">
                Trips
              </Link>
              <Link style={linkStyle(pathname.startsWith("/users"))} to="/users">
                Users
              </Link>
              <Link
                style={linkStyle(pathname.startsWith("/payments"))}
                to="/payments"
              >
                Payments
              </Link>
              <Link
                style={linkStyle(pathname.startsWith("/drivers"))}
                to="/drivers"
              >
                Drivers
              </Link>
              <Link
                style={linkStyle(pathname.startsWith("/bookings"))}
                to="/bookings"
              >
                Bookings
              </Link>
            </nav>
          </div>
          <button
            className="theme-toggle"
            onClick={toggleTheme}
            title={`Switch to ${theme === "dark" ? "light" : "dark"} theme`}
          >
            {theme === "dark" ? (
              <>
                <span>☀️</span>
                <span>Light</span>
              </>
            ) : (
              <>
                <span>🌙</span>
                <span>Dark</span>
              </>
            )}
          </button>
        </div>
      </header>
      <div className="container" style={{ width: "100%", padding: 20 }}>
        <div className="card" style={{ padding: 20 }}>
          <Outlet />
        </div>
      </div>
    </div>
  );
};

const linkStyle = (active: boolean): React.CSSProperties => ({
  color: "white",
  textDecoration: active ? "underline" : "none",
  display: "block",
  padding: "8px 0",
});
