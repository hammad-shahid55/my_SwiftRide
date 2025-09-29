import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type User = {
  id: string;
  full_name?: string;
  email?: string;
};

export const Users: React.FC = () => {
  const [users, setUsers] = React.useState<User[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [q, setQ] = React.useState("");
  const qRef = React.useRef("");

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    let query = supabase
      .from("profiles")
      .select("id, full_name, email")
      .order("updated_at", { ascending: false });
    const search = qRef.current.trim();
    if (search) {
      query = query.or(`full_name.ilike.%${search}%,email.ilike.%${search}%`);
    }
    const { data } = await query;
    setUsers((data as User[]) || []);
    setLoading(false);
  };
  React.useEffect(() => {
    load();
  }, []);

  React.useEffect(() => {
    qRef.current = q;
    const t = setTimeout(() => load(), 300);
    return () => clearTimeout(t);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [q]);

  // Status/blocked removed as requested

  if (!supabaseConfigured) return <>Configure Supabase env to load users.</>;
  if (loading) return <>Loading...</>;
  return (
    <>
    <div style={{ display: 'flex', gap: 8, marginBottom: 12 }}>
      <input
        placeholder="Search by name or email"
        value={q}
        onChange={(e) => setQ(e.target.value)}
        style={{ flex: 1 }}
      />
      <button onClick={() => load()}>Search</button>
      <button onClick={() => setQ("")}>Clear</button>
    </div>
    <table className="styled">
      <thead>
        <tr>
          <Th>Name</Th>
          <Th>Email</Th>
      
        </tr>
      </thead>
      <tbody>
        {users.map((u) => (
          <tr key={u.id}>
            <Td>{u.full_name || "User"}</Td>
            <Td>{u.email || ""}</Td>
          </tr>
        ))}
      </tbody>
    </table>
    </>
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
