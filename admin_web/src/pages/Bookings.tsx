import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

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

export const Bookings: React.FC = () => {
  const [bookings, setBookings] = React.useState<Booking[]>([]);
  const [loading, setLoading] = React.useState(true);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    const { data } = await supabase
      .from("bookings")
      .select("*")
      .order("created_at", { ascending: false });
    
    const bookingsList = (data as Booking[]) || [];
    
    // Fetch ratings for all bookings
    if (bookingsList.length > 0) {
      const bookingIds = bookingsList.map(b => b.id);
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
      bookingsList.forEach(booking => {
        booking.rating = ratingsMap.get(booking.id);
      });
    }
    
    setBookings(bookingsList);
    setLoading(false);
  };

  React.useEffect(() => {
    load();
  }, []);

  if (!supabaseConfigured) return <>Configure Supabase env to load bookings.</>;
  if (loading) return <>Loading...</>;

  return (
    <div>
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
                {b.rating !== undefined && b.rating !== null ? (
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
      {bookings.length === 0 && (
        <div className="empty" style={{ marginTop: 12 }}>
          No bookings yet.
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
