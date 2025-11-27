import React from "react";
import { Link } from "react-router-dom";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type Driver = { id: string; full_name?: string; phone?: string; overallRating?: number; totalRatings?: number };

export const Drivers: React.FC = () => {
  const [drivers, setDrivers] = React.useState<Driver[]>([]);
  const [loading, setLoading] = React.useState(true);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    const { data } = await supabase.from("drivers").select("*");
    const driversList = (data as Driver[]) || [];
    
    // Fetch overall ratings for each driver
    const driversWithRatings = await Promise.all(
      driversList.map(async (driver) => {
        try {
          const { data: ratingsData } = await supabase
            .from("ratings")
            .select("rating")
            .eq("driver_id", driver.id);
          
          if (ratingsData && ratingsData.length > 0) {
            const totalRatings = ratingsData.length;
            const sum = ratingsData.reduce((acc, r) => acc + (r.rating || 0), 0);
            const overallRating = sum / totalRatings;
            return {
              ...driver,
              overallRating: Math.round(overallRating * 10) / 10, // Round to 1 decimal
              totalRatings,
            };
          }
          return { ...driver, overallRating: undefined, totalRatings: 0 };
        } catch (error) {
          console.error(`Error fetching rating for driver ${driver.id}:`, error);
          return { ...driver, overallRating: undefined, totalRatings: 0 };
        }
      })
    );
    
    setDrivers(driversWithRatings);
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
            <Th style={{ textAlign: "right" }}>Rating</Th>
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
              <Td>
                {d.overallRating !== undefined ? (
                  <div style={{ display: "flex", alignItems: "center", gap: 8, justifyContent: "flex-end" }}>
                    <span style={{ fontSize: 18, fontWeight: 600, color: "#fbbf24" }}>
                      ⭐ {d.overallRating.toFixed(1)}
                    </span>
                    <span style={{ fontSize: 12, color: "#9ca3af" }}>
                      ({d.totalRatings || 0})
                    </span>
                  </div>
                ) : (
                  <span style={{ color: "#9ca3af", textAlign: "right", display: "block" }}>No ratings</span>
                )}
              </Td>
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

const Th: React.FC<{ children: React.ReactNode; style?: React.CSSProperties }> = ({ children, style }) => (
  <th
    style={{
      textAlign: "left",
      borderBottom: "1px solid rgba(255,255,255,0.06)",
      padding: 10,
      ...(style || {}),
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
