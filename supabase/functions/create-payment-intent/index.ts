/**
 * Creates a Stripe PaymentIntent and returns its client_secret.
 *
 * Secrets required:
 * - STRIPE_SECRET_KEY
 *
 * Client sends:
 * - amount_cents: number (integer)
 * - currency: string (default: "usd")
 * - metadata?: record<string, string>
 */
import Stripe from "npm:stripe@16";

type CreatePaymentIntentRequest = {
  amount_cents: number;
  currency?: string;
  metadata?: Record<string, string>;
};

function json(res: unknown, status = 200) {
  return new Response(JSON.stringify(res), {
    status,
    headers: {
      "Content-Type": "application/json",
      "Access-Control-Allow-Origin": "*",
      "Access-Control-Allow-Headers":
        "authorization, x-client-info, apikey, content-type",
    },
  });
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return json({ ok: true });
  if (req.method !== "POST") return json({ error: "Method not allowed" }, 405);

  const stripeSecretKey = Deno.env.get("STRIPE_SECRET_KEY");
  if (!stripeSecretKey) {
    return json({ error: "STRIPE_SECRET_KEY not configured" }, 500);
  }

  let body: CreatePaymentIntentRequest;
  try {
    body = (await req.json()) as CreatePaymentIntentRequest;
  } catch {
    return json({ error: "Invalid JSON" }, 400);
  }

  const amount = body.amount_cents;
  if (!Number.isInteger(amount) || amount <= 0) {
    return json({ error: "amount_cents must be a positive integer" }, 400);
  }

  const currency = (body.currency || "usd").toLowerCase();

  const stripe = new Stripe(stripeSecretKey, {
    apiVersion: "2024-06-20",
    httpClient: Stripe.createFetchHttpClient(),
  });

  try {
    const intent = await stripe.paymentIntents.create({
      amount,
      currency,
      automatic_payment_methods: { enabled: true },
      metadata: body.metadata || {},
    });

    return json({
      client_secret: intent.client_secret,
      payment_intent_id: intent.id,
    });
  } catch (e) {
    return json(
      { error: e instanceof Error ? e.message : "Stripe error" },
      500,
    );
  }
});

