import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";
import { useTheme } from "../lib/ThemeContext";

type Trip = {
  id: number;
  from_city?: string;
  to_city?: string;
  from: string;
  to: string;
  depart_time: string;
  arrive_time: string;
  price: number;
  total_seats: number;
};

export const Trips: React.FC = () => {
  const [trips, setTrips] = React.useState<Trip[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [editing, setEditing] = React.useState<Trip | null>(null);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    const { data } = await supabase
      .from("trips")
      .select("id, from_city, to_city, from, to, depart_time, arrive_time, price, total_seats")
      .gte('depart_time', new Date().toISOString())
      .order("depart_time", { ascending: true });
    setTrips((data as Trip[]) || []);
    setLoading(false);
  };

  React.useEffect(() => {
    load();
  }, []);

  const remove = async (trip: Trip) => {
    await supabase.from("trips").delete().eq("id", trip.id);
    await load();
  };

  if (!supabaseConfigured) {
    return <div>Configure Supabase env to load trips.</div>;
  }
  return (
    <div>
      <button
        className="btn primary"
        onClick={() => setEditing({} as Trip)}
        style={{ marginBottom: 12 }}
      >
        + New Trip
      </button>
      {editing && (
        <TripDialog
          initial={editing}
          onClose={() => {
            setEditing(null);
            load();
          }}
        />
      )}
      {loading ? (
        "Loading..."
      ) : (
        <table className="styled">
          <thead>
            <tr>
              <Th>From City</Th>
              <Th>To City</Th>
              <Th>From</Th>
              <Th>To</Th>
              <Th>Depart</Th>
              <Th>Arrive</Th>
              <Th>Price</Th>
              <Th>Seats</Th>
              <Th></Th>
            
            </tr>
          </thead>
          <tbody>
            {trips.map((t) => (
              <tr key={t.id}>
                <Td>{t.from_city || ''}</Td>
                <Td>{t.to_city || ''}</Td>
                <Td>{t.from}</Td>
                <Td>{t.to}</Td>
                <Td>{t.depart_time}</Td>
                <Td>{t.arrive_time}</Td>
                <Td>{t.price}</Td>
                <Td>{t.total_seats}</Td>
                <Td>
                  <button onClick={() => setEditing(t)}>Edit</button>
                  <button
                    onClick={() => remove(t)}
                    style={{ color: "red", marginLeft: 8 }}
                  >
                    Delete
                  </button>
                </Td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

const Th: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <th
    style={{ textAlign: "left", borderBottom: "1px solid #e5e7eb", padding: 8 }}
  >
    {children}
  </th>
);
const Td: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <td style={{ borderBottom: "1px solid #f3f4f6", padding: 8 }}>{children}</td>
);

const TripDialog: React.FC<{ initial: Partial<Trip>; onClose: () => void }> = ({
  initial,
  onClose,
}) => {
  const { theme } = useTheme();
  const [from_city, setFromCity] = React.useState(initial.from_city || "");
  const [to_city, setToCity] = React.useState(initial.to_city || "");
  const [fromVal, setFrom] = React.useState(initial.from || "");
  const [toVal, setTo] = React.useState(initial.to || "");
  const [depart_time, setDepart] = React.useState(initial.depart_time || "");
  const [arrive_time, setArrive] = React.useState(initial.arrive_time || "");
  const [price, setPrice] = React.useState<number>(Number(initial.price || 0));
  const [total_seats, setSeats] = React.useState<number>(
    Number(initial.total_seats || 0)
  );

  const save = async () => {
    const payload: any = {
      from_city,
      to_city,
      from: fromVal,
      to: toVal,
      depart_time,
      arrive_time,
      price,
      total_seats,
    };
    if (initial.id) {
      await supabase.from("trips").update(payload).eq("id", initial.id);
    } else {
      await supabase.from("trips").insert(payload);
    }
    onClose();
  };

  const isDark = theme === "dark";
  const inputStyle: React.CSSProperties = {
    padding: "8px 12px",
    borderRadius: "4px",
    border: `1px solid ${isDark ? "rgba(255,255,255,0.2)" : "#d1d5db"}`,
    background: isDark ? "rgba(255,255,255,0.05)" : "white",
    color: isDark ? "#ffffff" : "#000000",
    fontSize: "14px",
  };

  return (
    <div style={{
      position: "fixed",
      inset: 0,
      background: isDark ? "rgba(0,0,0,0.7)" : "rgba(0,0,0,0.4)",
      display: "flex",
      alignItems: "center",
      justifyContent: "center",
      zIndex: 1000,
    }}>
      <div style={{
        background: isDark ? "#1f2937" : "white",
        padding: 24,
        borderRadius: 8,
        width: 420,
        maxWidth: "90vw",
        boxShadow: isDark ? "0 10px 25px rgba(0,0,0,0.5)" : "0 10px 25px rgba(0,0,0,0.15)",
      }}>
        <h3 style={{ 
          margin: "0 0 16px 0", 
          color: isDark ? "#ffffff" : "#000000",
          fontSize: "20px",
          fontWeight: 600,
        }}>
          {initial.id ? "Edit Trip" : "Create Trip"}
        </h3>
        <div style={{ display: "grid", gap: 12 }}>
          <input
            placeholder="From City"
            value={from_city}
            onChange={(e) => setFromCity(e.target.value)}
            style={inputStyle}
          />
          <input
            placeholder="To City"
            value={to_city}
            onChange={(e) => setToCity(e.target.value)}
            style={inputStyle}
          />
          <input
            placeholder="From"
            value={fromVal}
            onChange={(e) => setFrom(e.target.value)}
            style={inputStyle}
          />
          <input
            placeholder="To"
            value={toVal}
            onChange={(e) => setTo(e.target.value)}
            style={inputStyle}
          />
          <input
            placeholder="Depart ISO"
            value={depart_time}
            onChange={(e) => setDepart(e.target.value)}
            style={inputStyle}
          />
          <input
            placeholder="Arrive ISO"
            value={arrive_time}
            onChange={(e) => setArrive(e.target.value)}
            style={inputStyle}
          />
          <input
            placeholder="Price"
            type="number"
            value={price}
            onChange={(e) => setPrice(Number(e.target.value))}
            style={inputStyle}
          />
          <input
            placeholder="Seats"
            type="number"
            value={total_seats}
            onChange={(e) => setSeats(Number(e.target.value))}
            style={inputStyle}
          />
        </div>
        <div
          style={{
            marginTop: 16,
            display: "flex",
            justifyContent: "flex-end",
            gap: 8,
          }}
        >
          <button 
            onClick={onClose}
            style={{
              padding: "8px 16px",
              borderRadius: "4px",
              border: `1px solid ${isDark ? "rgba(255,255,255,0.2)" : "#d1d5db"}`,
              background: isDark ? "rgba(255,255,255,0.1)" : "#f3f4f6",
              color: isDark ? "#ffffff" : "#000000",
              cursor: "pointer",
            }}
          >
            Cancel
          </button>
          <button 
            onClick={save}
            style={{
              padding: "8px 16px",
              borderRadius: "4px",
              border: "none",
              background: "#3b82f6",
              color: "#ffffff",
              cursor: "pointer",
              fontWeight: 500,
            }}
          >
            Save
          </button>
        </div>
      </div>
    </div>
  );
};

