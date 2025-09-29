import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

export const Dashboard: React.FC = () => {
  const [counts, setCounts] = React.useState({
    trips: 0,
    users: 0,
    payments: 0,
    payers: 0,
  });

  React.useEffect(() => {
    if (!supabaseConfigured) return;
    (async () => {
      const [trips, users, payments, payers] = await Promise.all([
        supabase.from("trips").select("*", { count: "exact", head: true }),
        supabase.from("profiles").select("*", { count: "exact", head: true }),
        supabase.from("payments").select("*", { count: "exact", head: true }),
        // distinct count of users who have added to wallet
        supabase
          .from("profiles")
          .select("id", { count: "exact" })
          .gt("wallet_balance", 0)
          .neq("email", null),
      ]);
      setCounts({
        trips: trips.count || 0,
        users: users.count || 0,
        payments: payments.count || 0,
        payers: payers.count || 0,
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
VITE_SUPABASE_ANON_KEY`}
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
        <Stat title="Users with wallet > 0" value={counts.payers} />
      </div>
      <div className="card" style={{ padding: 0, overflow: "hidden" }}>
        <MapWithStops />
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

// Lightweight Google Maps loader and renderer
const MapWithStops: React.FC = () => {
  const mapRef = React.useRef<HTMLDivElement | null>(null);
  const mapObj = React.useRef<google.maps.Map | null>(null);

  React.useEffect(() => {
    const key = (import.meta as any).env.VITE_GOOGLE_MAPS_API_KEY as string | undefined;
    if (!key) return;
    const existing = document.getElementById('gmaps-script') as HTMLScriptElement | null;
    if (existing) {
      if ((window as any).google?.maps) initMap();
      else existing.addEventListener('load', initMap, { once: true });
      return;
    }
    const s = document.createElement('script');
    s.id = 'gmaps-script';
    s.async = true;
    s.defer = true;
    s.src = `https://maps.googleapis.com/maps/api/js?key=${key}`;
    s.onload = initMap;
    document.head.appendChild(s);

    function initMap() {
      if (!mapRef.current) return;
      const center = { lat: 33.6844, lng: 73.0479 }; // Islamabad/Rawalpindi area
      mapObj.current = new (window as any).google.maps.Map(mapRef.current, {
        center,
        zoom: 11,
        mapTypeControl: false,
        streetViewControl: false,
        fullscreenControl: false,
      });
      const stops = [
        // Islamabad
        { lat: 33.7294, lng: 73.0379, title: 'Faisal Mosque (ISB)' },
        { lat: 33.7086, lng: 73.0552, title: 'The Centaurus (ISB)' },
        // Rawalpindi
        { lat: 33.5973, lng: 73.0479, title: 'Saddar (RWP)' },
        { lat: 33.6261, lng: 73.0710, title: 'Committee Chowk (RWP)' },
      ];
      stops.forEach((s) => new (window as any).google.maps.Marker({ position: s, map: mapObj.current, title: s.title }));
    }

    // no cleanup of script tag; map div will unmount with component
  }, []);

  return (
    <div style={{ height: 380, width: '100%' }}>
      <div ref={mapRef} style={{ height: '100%', width: '100%' }} />
    </div>
  );
};
