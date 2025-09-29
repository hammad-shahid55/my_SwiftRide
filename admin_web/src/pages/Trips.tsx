import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type Trip = {
  id: string;
  from_city: string;
  to_city: string;
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
      .select("*")
      .order("depart_time");
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
              <Th>From</Th>
              <Th>To</Th>
              <Th>Depart</Th>
              <Th>Arrive</Th>
              <Th>Price</Th>
              <Th>Seats</Th>
            
            </tr>
          </thead>
          <tbody>
            {trips.map((t) => (
              <tr key={t.id}>
                <Td>{t.from_city}</Td>
                <Td>{t.to_city}</Td>
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
  const [from_city, setFrom] = React.useState(initial.from_city || "");
  const [to_city, setTo] = React.useState(initial.to_city || "");
  const [depart_time, setDepart] = React.useState(initial.depart_time || "");
  const [arrive_time, setArrive] = React.useState(initial.arrive_time || "");
  const [price, setPrice] = React.useState<number>(Number(initial.price || 0));
  const [total_seats, setSeats] = React.useState<number>(
    Number(initial.total_seats || 0)
  );

  const save = async () => {
    const payload = {
      from_city,
      to_city,
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

  return (
    <div style={modalBackdrop}>
      <div style={modalCard}>
        <h3>{initial.id ? "Edit Trip" : "Create Trip"}</h3>
        <div style={{ display: "grid", gap: 8 }}>
          <input
            placeholder="From"
            value={from_city}
            onChange={(e) => setFrom(e.target.value)}
          />
          <input
            placeholder="To"
            value={to_city}
            onChange={(e) => setTo(e.target.value)}
          />
          <input
            placeholder="Depart ISO"
            value={depart_time}
            onChange={(e) => setDepart(e.target.value)}
          />
          <input
            placeholder="Arrive ISO"
            value={arrive_time}
            onChange={(e) => setArrive(e.target.value)}
          />
          <input
            placeholder="Price"
            type="number"
            value={price}
            onChange={(e) => setPrice(Number(e.target.value))}
          />
          <input
            placeholder="Seats"
            type="number"
            value={total_seats}
            onChange={(e) => setSeats(Number(e.target.value))}
          />
        </div>
        <div
          style={{
            marginTop: 12,
            display: "flex",
            justifyContent: "flex-end",
            gap: 8,
          }}
        >
          <button onClick={onClose}>Cancel</button>
          <button onClick={save}>Save</button>
        </div>
      </div>
    </div>
  );
};

const modalBackdrop: React.CSSProperties = {
  position: "fixed",
  inset: 0,
  background: "rgba(0,0,0,0.4)",
  display: "flex",
  alignItems: "center",
  justifyContent: "center",
};
const modalCard: React.CSSProperties = {
  background: "white",
  padding: 16,
  borderRadius: 8,
  width: 420,
};
