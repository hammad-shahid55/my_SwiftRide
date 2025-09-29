import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type Payment = { id: string; amount?: number; status?: string };

export const Payments: React.FC = () => {
  const [payments, setPayments] = React.useState<Payment[]>([]);
  const [loading, setLoading] = React.useState(true);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    const { data } = await supabase
      .from("payments")
      .select("*")
      .order("created_at", { ascending: false });
    setPayments((data as Payment[]) || []);
    setLoading(false);
  };
  React.useEffect(() => {
    load();
  }, []);

  const refund = async (p: Payment) => {
    await supabase
      .from("payments")
      .update({ status: "refunded" })
      .eq("id", p.id);
    await load();
  };

  if (!supabaseConfigured) return <>Configure Supabase env to load payments.</>;
  if (loading) return <>Loading...</>;
  return (
    <table className="styled">
      <thead>
        <tr>
          <Th>Amount</Th>
          <Th>Status</Th>
        
        </tr>
      </thead>
      <tbody>
        {payments.map((p) => (
          <tr key={p.id}>
            <Td>{p.amount ?? "-"}</Td>
            <Td>{p.status ?? ""}</Td>
            <Td>
              {String(p.status).toLowerCase() === "succeeded" && (
                <button className="btn" onClick={() => refund(p)}>
                  Refund
                </button>
              )}
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
