import React from "react";
import { supabase, supabaseConfigured } from "../lib/supabaseClient";

type Payment = { id: string; amount?: number; status?: string };

export const Payments: React.FC = () => {
  const [payments, setPayments] = React.useState<Payment[]>([]);
  const [loading, setLoading] = React.useState(true);
  const [totalWalletProfiles, setTotalWalletProfiles] = React.useState<number>(0);
  const [stripeCount, setStripeCount] = React.useState<number>(0);
  const [stripeTotal, setStripeTotal] = React.useState<number>(0);

  const load = async () => {
    if (!supabaseConfigured) return;
    setLoading(true);
    // Load only Stripe wallet payments
    const { data: stripePayments } = await supabase
      .from("payments")
      .select("*")
      .eq("provider", "stripe")
      .eq("status", "succeeded")
      .order("created_at", { ascending: false });
    const pl = (stripePayments as Payment[]) || [];
    setPayments(pl);
    setStripeCount(pl.length);
    setStripeTotal(pl.reduce((acc, p) => acc + Number(p.amount || 0), 0));

    // Sum via view (wallet_total_view)
    const { data: totalRow } = await supabase
      .from("wallet_total_view")
      .select("total")
      .maybeSingle();
    setTotalWalletProfiles(Number(totalRow?.total ?? 0));
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
    <>
    <div style={{ marginBottom: 12, fontWeight: 700, display: 'grid', gap: 4 }}>
      <span>Total Wallet (profiles.wallet_balance): {totalWalletProfiles}</span>
      <span>Stripe Wallet Payments — Count: {stripeCount} | Total: {stripeTotal}</span>
    </div>
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
