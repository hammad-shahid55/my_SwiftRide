import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type User = {
  id: string;
  full_name?: string;
  email?: string;
  blocked?: boolean;
};

export const Users: React.FC = () => {
  const [users, setUsers] = React.useState<User[]>([]);
  const [loading, setLoading] = React.useState(true);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    const { data } = await supabase
      .from("profiles")
      .select("*")
      .order("created_at", { ascending: false });
    setUsers((data as User[]) || []);
    setLoading(false);
  };
  React.useEffect(() => {
    load();
  }, []);

  const toggle = async (u: User) => {
    await supabase
      .from("profiles")
      .update({ blocked: !u.blocked })
      .eq("id", u.id);
    await load();
  };

  if (!supabaseConfigured) return <>Configure Supabase env to load users.</>;
  if (loading) return <>Loading...</>;
  return (
    <table className="styled">
      <thead>
        <tr>
          <Th>Name</Th>
          <Th>Email</Th>
          <Th>Status</Th>
      
        </tr>
      </thead>
      <tbody>
        {users.map((u) => (
          <tr key={u.id}>
            <Td>{u.full_name || "User"}</Td>
            <Td>{u.email || ""}</Td>
            <Td>{u.blocked ? "Blocked" : "Active"}</Td>
            <Td>
              <button className="btn" onClick={() => toggle(u)}>
                {u.blocked ? "Unblock" : "Block"}
              </button>
            </Td>
          </tr>
        ))}
      </tbody>
    </table>
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
