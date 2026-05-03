# PetFolio Waitlist System Setup

This guide explains how to deploy the waitlist system that captures user signups and sends confirmation emails.

## Overview

The system consists of:
1. **Database Table** (`waitlist`) - Stores all signups with position, referral codes, etc.
2. **Edge Function** (`waitlist-signup`) - Handles form submissions and sends emails
3. **Updated HTML** - Calls the API endpoint when users submit the form

---

## Step 1: Create the Database Table

Run the SQL migration to create the waitlist table:

```bash
# Option A: Using Supabase CLI
supabase db push

# Option B: Run SQL directly in Supabase Dashboard
# Go to SQL Editor and paste the contents of:
# supabase/waitlist_table.sql
```

Or copy/paste this SQL in the Supabase Dashboard SQL Editor:

```sql
-- See: supabase/waitlist_table.sql
```

---

## Step 2: Deploy the Edge Function

### Prerequisites
- [Supabase CLI](https://supabase.com/docs/guides/cli) installed
- Logged in to Supabase CLI (`supabase login`)

### Deploy the Function

```bash
cd /home/kratzer/workspace/petsphere

# Link to your project (if not already)
supabase link --project-ref foubokcqaxyqgjhtgzsx

# Deploy the edge function
supabase functions deploy waitlist-signup --no-verify-jwt
```

The `--no-verify-jwt` flag allows anonymous access (no auth required for waitlist signup).

---

## Step 3: Set Up Email Sending (Resend)

### Create a Resend Account

1. Go to [resend.com](https://resend.com) and create a free account
2. Add and verify your domain (e.g., `petfolio.app`)
3. Create an API key

### Configure Secrets

Set the required secrets for the Edge Function:

```bash
# Required: Resend API key for sending emails
supabase secrets set RESEND_API_KEY=re_xxxxxxxxxxxxx

# Required: "From" email address (must be from verified domain)
supabase secrets set EMAIL_FROM="PetFolio <hello@petfolio.app>"

# Optional: Your email to receive notifications of new signups
supabase secrets set ADMIN_EMAIL="your-email@example.com"
```

### Alternative Email Providers

If you prefer a different email provider, modify the `sendConfirmationEmail` function in `supabase/functions/waitlist-signup/index.ts` to use:
- **SendGrid**: Replace Resend API call with SendGrid's API
- **Mailgun**: Use Mailgun's REST API
- **AWS SES**: Use AWS SDK

---

## Step 4: Test the System

### Test the Edge Function

```bash
curl -X POST https://foubokcqaxyqgjhtgzsx.supabase.co/functions/v1/waitlist-signup \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","pet_type":"dog"}'
```

Expected response:
```json
{
  "success": true,
  "position": 1,
  "referral_code": "abc123",
  "message": "Welcome to the waitlist!",
  "total_signups": 1
}
```

### Test the HTML Form

1. Open `petfolio-waitlist.html` in a browser
2. Fill out the form and submit
3. You should see the success state with your position number
4. Check your email for the confirmation (if email is configured)

---

## Features

### Automatic Position Assignment
Each signup is automatically assigned an incrementing position number.

### Duplicate Prevention
If someone tries to sign up with the same email, they'll get their existing position back.

### Referral Tracking
- Each signup gets a unique referral code
- Share URL format: `https://petfolio.app/waitlist?ref=CODE`
- The `referred_by` column tracks who referred whom

### Admin Notifications
When `ADMIN_EMAIL` is configured, you receive an email for each new signup with:
- Name
- Email
- Pet type
- Position number
- Signup time

---

## Viewing Signups

### Via Supabase Dashboard

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Navigate to Table Editor → `waitlist`
3. View and export signups

### Via SQL Query

```sql
-- Get all signups ordered by position
SELECT * FROM waitlist ORDER BY position ASC;

-- Get signup count
SELECT COUNT(*) FROM waitlist;

-- Get signups by pet type
SELECT pet_type, COUNT(*) 
FROM waitlist 
GROUP BY pet_type 
ORDER BY COUNT(*) DESC;

-- Get top referrers
SELECT 
  w1.name,
  w1.email,
  COUNT(w2.id) as referral_count
FROM waitlist w1
LEFT JOIN waitlist w2 ON w2.referred_by = w1.referral_code
GROUP BY w1.id, w1.name, w1.email
HAVING COUNT(w2.id) > 0
ORDER BY referral_count DESC;
```

---

## Customization

### Email Template
Edit the HTML template in `supabase/functions/waitlist-signup/index.ts` in the `sendConfirmationEmail` function.

### CORS Settings
The Edge Function allows all origins by default. To restrict:

```typescript
const corsHeaders = {
  "Access-Control-Allow-Origin": "https://petfolio.app", // Your domain only
  // ...
};
```

### Rate Limiting
Add rate limiting in Supabase Dashboard:
1. Go to Edge Functions
2. Click on `waitlist-signup`
3. Configure rate limits

---

## Troubleshooting

### "Failed to join waitlist" Error
- Check Edge Function logs: `supabase functions logs waitlist-signup`
- Verify the database table exists
- Check RLS policies are correct

### Emails Not Sending
- Verify `RESEND_API_KEY` is set: `supabase secrets list`
- Check Resend dashboard for delivery status
- Verify your domain is verified in Resend
- Check Edge Function logs for email errors

### CORS Errors
- Ensure the Edge Function is deployed with `--no-verify-jwt`
- Check the `corsHeaders` in the function include your domain

---

## Production Checklist

- [ ] Database table created
- [ ] Edge Function deployed
- [ ] Resend account set up with verified domain
- [ ] `RESEND_API_KEY` secret configured
- [ ] `EMAIL_FROM` secret configured
- [ ] `ADMIN_EMAIL` secret configured (optional)
- [ ] Test signup works end-to-end
- [ ] Confirmation email received
- [ ] Admin notification received (if configured)
