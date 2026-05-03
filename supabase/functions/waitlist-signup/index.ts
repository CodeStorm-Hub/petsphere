import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

interface WaitlistRequest {
  name: string;
  email: string;
  pet_type?: string;
  referral_code?: string;
}

interface WaitlistResponse {
  success: boolean;
  position?: number;
  referral_code?: string;
  message: string;
  total_signups?: number;
}

async function sendConfirmationEmail(
  email: string,
  name: string,
  position: number,
  referralCode: string
): Promise<boolean> {
  const resendApiKey = Deno.env.get("RESEND_API_KEY");

  if (!resendApiKey) {
    console.log("RESEND_API_KEY not configured, skipping email");
    return false;
  }

  const emailHtml = `
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Welcome to PetFolio!</title>
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Helvetica Neue', sans-serif; background-color: #f5f5f7;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="max-width: 600px; margin: 0 auto; padding: 40px 20px;">
    <tr>
      <td style="background: linear-gradient(135deg, #2979FF, #5BA3F5); border-radius: 20px 20px 0 0; padding: 40px; text-align: center;">
        <div style="font-size: 48px; margin-bottom: 16px;">🐾</div>
        <h1 style="color: #ffffff; font-size: 28px; font-weight: 700; margin: 0;">Welcome to PetFolio!</h1>
        <p style="color: rgba(255,255,255,0.9); font-size: 16px; margin: 12px 0 0;">Your pet's social world awaits</p>
      </td>
    </tr>
    <tr>
      <td style="background: #ffffff; padding: 40px; border-radius: 0 0 20px 20px; box-shadow: 0 4px 24px rgba(0,0,0,0.08);">
        <p style="color: #1d1d1f; font-size: 18px; line-height: 1.6; margin: 0 0 24px;">Hey ${name}! 👋</p>
        
        <p style="color: #6e6e73; font-size: 16px; line-height: 1.7; margin: 0 0 24px;">
          You're officially on the PetFolio beta waitlist. We're building something special for devoted pet parents like you — and you'll be among the first to experience it.
        </p>

        <div style="background: #f5f5f7; border-radius: 16px; padding: 24px; text-align: center; margin: 0 0 24px;">
          <p style="color: #6e6e73; font-size: 14px; margin: 0 0 8px; text-transform: uppercase; letter-spacing: 0.5px;">Your position</p>
          <p style="color: #2979FF; font-size: 48px; font-weight: 700; margin: 0; letter-spacing: -2px;">#${position}</p>
          <p style="color: #1d1d1f; font-size: 14px; margin: 8px 0 0;">in the waitlist queue</p>
        </div>

        <h3 style="color: #1d1d1f; font-size: 18px; margin: 0 0 16px;">🎁 Your Founding Member Perks:</h3>
        <ul style="color: #6e6e73; font-size: 15px; line-height: 1.8; padding-left: 24px; margin: 0 0 24px;">
          <li><strong style="color: #1d1d1f;">Founding Member Badge</strong> — Forever on your profile</li>
          <li><strong style="color: #1d1d1f;">First Beta Access</strong> — Before anyone else</li>
          <li><strong style="color: #1d1d1f;">3 Months Premium Free</strong> — At launch</li>
          <li><strong style="color: #1d1d1f;">Reserved Username</strong> — Lock in your pet's handle</li>
        </ul>

        <div style="background: linear-gradient(135deg, #1d1d1f, #2c2c2e); border-radius: 16px; padding: 24px; text-align: center; margin: 0 0 24px;">
          <p style="color: rgba(255,255,255,0.7); font-size: 14px; margin: 0 0 12px;">Share & move up the list!</p>
          <p style="color: #ffffff; font-size: 13px; margin: 0 0 8px;">Your referral code:</p>
          <p style="color: #2979FF; font-size: 24px; font-weight: 600; font-family: monospace; margin: 0; letter-spacing: 2px;">${referralCode}</p>
          <p style="color: rgba(255,255,255,0.5); font-size: 12px; margin: 12px 0 0;">Every friend who joins bumps you up!</p>
        </div>

        <p style="color: #6e6e73; font-size: 15px; line-height: 1.7; margin: 0 0 24px;">
          We'll email you the moment beta opens. Until then, give your furry friend an extra treat from us! 🐕🐈
        </p>

        <p style="color: #1d1d1f; font-size: 16px; margin: 0;">
          — The PetFolio Team 🐾
        </p>
      </td>
    </tr>
    <tr>
      <td style="padding: 24px; text-align: center;">
        <p style="color: #86868b; font-size: 12px; margin: 0;">
          © 2025 PetFolio. Made with 🐾 for pet parents everywhere.
        </p>
        <p style="color: #86868b; font-size: 11px; margin: 8px 0 0;">
          You received this email because you signed up for the PetFolio waitlist.
        </p>
      </td>
    </tr>
  </table>
</body>
</html>
  `;

  try {
    const response = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from: Deno.env.get("EMAIL_FROM") || "PetFolio <noreply@petfolio.app>",
        to: [email],
        subject: `🐾 You're #${position} on the PetFolio Waitlist!`,
        html: emailHtml,
      }),
    });

    if (!response.ok) {
      const error = await response.text();
      console.error("Email send failed:", error);
      return false;
    }

    console.log(`Confirmation email sent to ${email}`);
    return true;
  } catch (error) {
    console.error("Email error:", error);
    return false;
  }
}

async function sendAdminNotification(
  name: string,
  email: string,
  petType: string | undefined,
  position: number
): Promise<void> {
  const adminEmail = Deno.env.get("ADMIN_EMAIL");
  const resendApiKey = Deno.env.get("RESEND_API_KEY");

  if (!adminEmail || !resendApiKey) {
    return;
  }

  try {
    await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${resendApiKey}`,
      },
      body: JSON.stringify({
        from: Deno.env.get("EMAIL_FROM") || "PetFolio <noreply@petfolio.app>",
        to: [adminEmail],
        subject: `🎉 New Waitlist Signup #${position}: ${name}`,
        html: `
          <h2>New PetFolio Waitlist Signup!</h2>
          <p><strong>Name:</strong> ${name}</p>
          <p><strong>Email:</strong> ${email}</p>
          <p><strong>Pet Type:</strong> ${petType || "Not specified"}</p>
          <p><strong>Position:</strong> #${position}</p>
          <p><strong>Time:</strong> ${new Date().toISOString()}</p>
        `,
      }),
    });
  } catch (error) {
    console.error("Admin notification error:", error);
  }
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response(null, { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ success: false, message: "Method not allowed" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    const body: WaitlistRequest = await req.json();
    const { name, email, pet_type, referral_code } = body;

    if (!name || !name.trim()) {
      return new Response(
        JSON.stringify({ success: false, message: "Name is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!email || !email.includes("@")) {
      return new Response(
        JSON.stringify({ success: false, message: "Valid email is required" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { data: existing } = await supabase
      .from("waitlist")
      .select("position, referral_code")
      .eq("email", email.toLowerCase().trim())
      .single();

    if (existing) {
      return new Response(
        JSON.stringify({
          success: true,
          position: existing.position,
          referral_code: existing.referral_code,
          message: "You're already on the waitlist!",
        } as WaitlistResponse),
        { headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const insertData: Record<string, unknown> = {
      name: name.trim(),
      email: email.toLowerCase().trim(),
      pet_type: pet_type || null,
    };

    if (referral_code) {
      const { data: referrer } = await supabase
        .from("waitlist")
        .select("referral_code")
        .eq("referral_code", referral_code)
        .single();

      if (referrer) {
        insertData.referred_by = referral_code;
      }
    }

    const { data: newEntry, error: insertError } = await supabase
      .from("waitlist")
      .insert(insertData)
      .select("position, referral_code")
      .single();

    if (insertError) {
      console.error("Insert error:", insertError);
      return new Response(
        JSON.stringify({ success: false, message: "Failed to join waitlist" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const emailSent = await sendConfirmationEmail(
      email,
      name,
      newEntry.position,
      newEntry.referral_code
    );

    if (emailSent) {
      await supabase
        .from("waitlist")
        .update({ email_sent: true })
        .eq("email", email.toLowerCase().trim());
    }

    await sendAdminNotification(name, email, pet_type, newEntry.position);

    const { count } = await supabase
      .from("waitlist")
      .select("*", { count: "exact", head: true });

    const response: WaitlistResponse = {
      success: true,
      position: newEntry.position,
      referral_code: newEntry.referral_code,
      message: "Welcome to the waitlist!",
      total_signups: count || newEntry.position,
    };

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Waitlist signup error:", error);
    return new Response(
      JSON.stringify({ success: false, message: "Internal server error" }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
