import React from "react";
import { Link } from "react-router-dom";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type Driver = { id: string; full_name?: string; phone?: string };

export const Drivers: React.FC = () => {
  const [drivers, setDrivers] = React.useState<Driver[]>([]);
  const [loading, setLoading] = React.useState(true);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    const { data } = await supabase.from("drivers").select("*");
    setDrivers((data as Driver[]) || []);
    setLoading(false);
  };

  React.useEffect(() => {
    load();
  }, []);

  if (!supabaseConfigured) return <>Configure Supabase env to load drivers.</>;
  if (loading) return <>Loading...</>;

  return (
    <div>
      <table className="styled">
        <thead>
          <tr>
            <Th>ID</Th>
            <Th>Name</Th>
            <Th>Phone</Th>
          </tr>
        </thead>
        <tbody>
          {drivers.map((d) => (
            <tr key={d.id}>
              <Td style={{ fontFamily: "monospace" }}>{d.id}</Td>
              <Td>
                <Link to={`/drivers/${d.id}`} style={{ color: "#93c5fd" }}>
                  {d.full_name || "-"}
                </Link>
              </Td>
              <Td>{d.phone || "-"}</Td>
            </tr>
          ))}
        </tbody>
      </table>
      {drivers.length === 0 && (
        <div className="empty" style={{ marginTop: 12 }}>
          No drivers yet.
        </div>
      )}
    </div>
  );
};

const Th: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <th
    style={{
      textAlign: "left",
      borderBottom: "1px solid rgba(255,255,255,0.06)",
      padding: 10,
    }}
  >
    {children}
  </th>
);
const Td: React.FC<{
  children: React.ReactNode;
  style?: React.CSSProperties;
}> = ({ children, style }) => (
  <td
    style={{
      borderBottom: "1px solid rgba(255,255,255,0.06)",
      padding: 10,
      ...(style || {}),
    }}
  >
    {children}
  </td>
);
