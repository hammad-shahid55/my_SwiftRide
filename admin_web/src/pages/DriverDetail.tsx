import React from "react";
import { useParams, Link } from "react-router-dom";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type Driver = { id: string; full_name?: string; phone?: string };
type Trip = {
  id: number;
  from_city?: string;
  to_city?: string;
  depart_time?: string;
  arrive_time?: string;
};
type Booking = {
  id: number;
  trip_id: number;
  user_id: string;
  seats: number;
  status?: string;
};

export const DriverDetail: React.FC = () => {
  const { id } = useParams();
  const [driver, setDriver] = React.useState<Driver | null>(null);
  const [trips, setTrips] = React.useState<Trip[]>([]);
  const [bookings, setBookings] = React.useState<Booking[]>([]);
  const [loading, setLoading] = React.useState(true);

  React.useEffect(() => {
    (async () => {
      if (!supabaseConfigured || !id) return;
      setLoading(true);
      const d = await supabase
        .from("drivers")
        .select("*")
        .eq("id", id)
        .maybeSingle();
      const t = await supabase
        .from("trips")
        .select("*")
        .eq("driver_id", id)
        .order("depart_time", { ascending: false });
      let b: { data: Booking[] | null } = { data: [] } as any;
      if (t.data && t.data.length) {
        const tripIds = (t.data as Trip[]).map((tr) => tr.id);
        b = await supabase
          .from("bookings")
          .select("*")
          .in("trip_id", tripIds)
          .order("created_at", { ascending: false });
      }
      setDriver((d.data as Driver) || null);
      setTrips((t.data as Trip[]) || []);
      setBookings((b.data as Booking[]) || []);
      setLoading(false);
    })();
  }, [id]);

  if (!supabaseConfigured) return <div>Configure Supabase env.</div>;
  if (loading) return <div>Loading...</div>;
  if (!driver)
    return (
      <div className="empty">
        Driver not found.{" "}
        <Link to="/drivers" style={{ color: "#93c5fd" }}>
          Back
        </Link>
      </div>
    );

  return (
    <div style={{ display: "grid", gap: 16 }}>
      <div
        className="card"
        style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 16 }}
      >
        <div>
          <div className="stat-title">Driver</div>
          <div style={{ fontSize: 20, fontWeight: 700 }}>
            {driver.full_name || "-"}
          </div>
          <div style={{ color: "#9ca3af" }}>{driver.id}</div>
        </div>
        <div>
          <div className="stat-title">Phone</div>
          <div>{driver.phone || "-"}</div>
        </div>
      </div>

      <div className="card">
        <div className="stat-title" style={{ marginBottom: 8 }}>
          Trips
        </div>
        {trips.length === 0 ? (
          <div className="empty">No trips.</div>
        ) : (
          <table className="styled">
            <thead>
              <tr>
                <Th>ID</Th>
                <Th>From</Th>
                <Th>To</Th>
                <Th>Depart</Th>
                <Th>Arrive</Th>
              </tr>
            </thead>
            <tbody>
              {trips.map((t) => (
                <tr key={t.id}>
                  <Td>{t.id}</Td>
                  <Td>{t.from_city || "-"}</Td>
                  <Td>{t.to_city || "-"}</Td>
                  <Td>{t.depart_time || "-"}</Td>
                  <Td>{t.arrive_time || "-"}</Td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <div className="card">
        <div className="stat-title" style={{ marginBottom: 8 }}>
          Recent bookings
        </div>
        {bookings.length === 0 ? (
          <div className="empty">No bookings.</div>
        ) : (
          <table className="styled">
            <thead>
              <tr>
                <Th>ID</Th>
                <Th>Trip</Th>
                <Th>User</Th>
                <Th>Seats</Th>
                <Th>Status</Th>
              </tr>
            </thead>
            <tbody>
              {bookings.map((b) => (
                <tr key={b.id}>
                  <Td>{b.id}</Td>
                  <Td>{b.trip_id}</Td>
                  <Td style={{ fontFamily: "monospace" }}>{b.user_id}</Td>
                  <Td>{b.seats}</Td>
                  <Td>{b.status || "-"}</Td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
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
