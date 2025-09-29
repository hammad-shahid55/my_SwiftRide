import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

export const Dashboard: React.FC = () => {
  const [counts, setCounts] = React.useState({
    trips: 0,
    users: 0,
    payments: 0,
  });

  React.useEffect(() => {
    if (!supabaseConfigured) return;
    (async () => {
      const [trips, users, payments] = await Promise.all([
        supabase.from("trips").select("*"),
        supabase.from("profiles").select("*"),
        supabase.from("payments").select("*"),
      ]);
      setCounts({
        trips: trips.data?.length || 0,
        users: users.data?.length || 0,
        payments: payments.data?.length || 0,
      });
    })();
  }, []);

  if (!supabaseConfigured) {
    return (
      <div style={{ color: "#7f1d1d" }}>
        Missing Supabase env. Create <code>admin_web/.env</code> with:
        <pre style={{ background: "#f3f4f6", padding: 12 }}>
          {`VITE_SUPABASE_URL=${
            location.origin.includes("localhost")
              ? "https://ffsqsalfmwjnauamlobc.supabase.co"
              : ""
          }
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY`}
        </pre>
        Then restart dev server.
      </div>
    );
  }

  return (
    <div style={{ display: "grid", gap: 16 }}>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(220px, 1fr))",
          gap: 16,
        }}
      >
        <Stat title="Trips" value={counts.trips} />
        <Stat title="Users" value={counts.users} />
        <Stat title="Payments" value={counts.payments} />
      </div>
      <div className="card">
        <div className="stat-title" style={{ marginBottom: 8 }}>
          Recent activity
        </div>
        <div className="empty">No recent activity yet.</div>
      </div>
    </div>
  );
};

const Stat: React.FC<{ title: string; value: number }> = ({ title, value }) => (
  <div className="card stat">
    <div className="stat-title">{title}</div>
    <div className="stat-value">{value}</div>
  </div>
);
