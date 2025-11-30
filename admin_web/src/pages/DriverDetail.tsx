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
  cancellation_reason?: string;
  cancelled_at?: string;
  rating?: number;
};

export const DriverDetail: React.FC = () => {
  const { id } = useParams();
  const [driver, setDriver] = React.useState<Driver | null>(null);
  const [trips, setTrips] = React.useState<Trip[]>([]);
  const [bookings, setBookings] = React.useState<Booking[]>([]);
  const [overallRating, setOverallRating] = React.useState<number | null>(null);
  const [totalRatings, setTotalRatings] = React.useState<number>(0);
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
        
        // Fetch ratings for bookings
        if (b.data && b.data.length > 0) {
          const bookingIds = (b.data as Booking[]).map(booking => booking.id);
          const { data: ratingsData } = await supabase
            .from("ratings")
            .select("booking_id, rating")
            .in("booking_id", bookingIds);
          
          // Create a map of booking_id to rating
          const ratingsMap = new Map<number, number>();
          if (ratingsData) {
            ratingsData.forEach((r: any) => {
              ratingsMap.set(r.booking_id, r.rating);
            });
          }
          
          // Add ratings to bookings
          (b.data as Booking[]).forEach(booking => {
            booking.rating = ratingsMap.get(booking.id);
          });
        }
      }
      
      // Fetch overall rating from backend (only from completed bookings)
      try {
        const { data: ratingsData, error } = await supabase
          .from("ratings")
          .select("rating, booking_id")
          .eq("driver_id", id);
        
        if (error) {
          console.error("Error fetching ratings:", error);
          setOverallRating(null);
          setTotalRatings(0);
          return;
        }
        
        if (ratingsData && ratingsData.length > 0) {
          // Verify ratings are only from completed bookings
          const bookingIds = ratingsData.map(r => r.booking_id);
          const { data: bookingsData } = await supabase
            .from("bookings")
            .select("id, status")
            .in("id", bookingIds)
            .eq("status", "completed");
          
          // Filter ratings to only include those from completed bookings
          const completedBookingIds = new Set(
            (bookingsData || []).map(b => b.id)
          );
          const validRatings = ratingsData.filter(r => 
            completedBookingIds.has(r.booking_id)
          );
          
          if (validRatings.length > 0) {
            const total = validRatings.length;
            const sum = validRatings.reduce((acc, r) => acc + (r.rating || 0), 0);
            const avg = sum / total;
            setOverallRating(Math.round(avg * 10) / 10);
            setTotalRatings(total);
          } else {
            setOverallRating(null);
            setTotalRatings(0);
          }
        } else {
          setOverallRating(null);
          setTotalRatings(0);
        }
      } catch (error) {
        console.error("Error fetching rating:", error);
        setOverallRating(null);
        setTotalRatings(0);
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
        style={{ display: "grid", gridTemplateColumns: "1fr 1fr auto", gap: 16 }}
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
        <div style={{ display: "flex", flexDirection: "column", alignItems: "center", justifyContent: "center", paddingLeft: 16, borderLeft: "1px solid rgba(255,255,255,0.1)" }}>
          {overallRating !== null ? (
            <>
              <div style={{ fontSize: 32, fontWeight: 700, color: "#fbbf24", lineHeight: 1 }}>
                ⭐ {overallRating.toFixed(1)}
              </div>
              <div style={{ fontSize: 12, color: "#9ca3af", marginTop: 4 }}>
                {totalRatings} {totalRatings === 1 ? "rating" : "ratings"}
              </div>
            </>
          ) : (
            <div style={{ fontSize: 14, color: "#9ca3af" }}>
              No ratings
            </div>
          )}
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
                <Th>Rating</Th>
                <Th>Cancellation Reason</Th>
              </tr>
            </thead>
            <tbody>
              {bookings.map((b) => (
                <tr key={b.id}>
                  <Td>{b.id}</Td>
                  <Td>{b.trip_id}</Td>
                  <Td style={{ fontFamily: "monospace" }}>{b.user_id}</Td>
                  <Td>{b.seats}</Td>
                  <Td>
                    <span style={{
                      color: b.status === 'cancelled' ? '#ef4444' : 
                             b.status === 'completed' ? '#10b981' : 
                             b.status === 'booked' ? '#3b82f6' : '#9ca3af'
                    }}>
                      {b.status || "-"}
                    </span>
                  </Td>
                  <Td>
                    {b.status === 'completed' ? (
                      b.rating !== undefined && b.rating !== null ? (
                        <span style={{
                          color: '#fbbf24',
                          fontWeight: 600,
                          display: 'flex',
                          alignItems: 'center',
                          gap: 4
                        }}>
                          ⭐ {b.rating}/5
                        </span>
                      ) : (
                        <span style={{
                          color: '#9ca3af',
                          fontStyle: 'italic'
                        }}>
                          Rating not given by user
                        </span>
                      )
                    ) : (
                      <span style={{
                        color: '#6b7280',
                        fontStyle: 'italic'
                      }}>
                        N/A (not completed)
                      </span>
                    )}
                  </Td>
                  <Td>
                    {b.status === 'cancelled' ? (
                      <span style={{
                        color: b.cancellation_reason ? '#ffffff' : '#9ca3af',
                        fontStyle: b.cancellation_reason ? 'normal' : 'italic'
                      }}>
                        {b.cancellation_reason || 'Reason not mentioned'}
                      </span>
                    ) : (
                      <span style={{ color: '#9ca3af' }}>-</span>
                    )}
                  </Td>
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
