# Backend report: `POST /auth/register` exceeds 45 s and leaves a half-created account

**From:** RouteX driver app (Flutter) team
**To:** Backend team
**Environment:** `https://backend-repo-0y6z.onrender.com` (Render)
**Date:** 2026-11-16

## Summary

Signing up from the driver app often ends with "Request timed out" even though the server **did create the account**. Retrying then fails with "User with this email or phone number already exists", and the user has no way to finish activating the account.

## What we observe

1. The app calls `POST /auth/register` and waits up to **45 s** (client timeout). The call frequently does not answer in time.
2. The server-side effect still happens: the account is created (inactive) and the OTP flow starts.
3. The retry with the same email returns an error whose message is the English text *"User with this email or phone number already exists"*.
4. The server itself was **awake and fast** when we checked: `GET /` answered `404` in 0.3–0.5 s on two consecutive calls. So the delay is not (only) Render's cold start; it is inside the register request.

## Not yet measured

We have not yet timed `POST /auth/register` directly. Please measure it on your side (server logs) and tell us where the time goes. Our guess, to be confirmed: the request waits for the OTP e-mail to be sent (SMTP/provider call) before responding.

## Reproduce

```bash
curl -s -o /dev/null -m 120 -X POST https://backend-repo-0y6z.onrender.com/auth/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Test","lastName":"Timing","country":"Saudi Arabia","email":"<new-address>@example.com","password":"<test-password>","phone":"+966500000001","role":"DRIVER"}' \
  -w "t=%{time_total}s code=%{http_code}\n"
```

Use a new e-mail each time. Request body fields are exactly what the app sends: `firstName`, `lastName`, `country`, `email`, `password`, `phone`, `role` (`DRIVER`).

## What we need from the backend

| # | Request | Why |
|---|---------|-----|
| 1 | Respond to `/auth/register` right after the account row is saved; send the OTP e-mail asynchronously (queue / background task). Target: under 5 s. | Removes the timeout at its source. |
| 2 | Tell us the real p50/p95 latency of `/auth/register` and what dominates it (DB, hashing, e-mail provider). | We chose the 45 s client timeout from an assumption. |
| 3 | Make register **idempotent for unverified accounts**: if the e-mail/phone belongs to an account that is still inactive, resend the OTP and return success instead of an "already exists" error. | A timed-out or abandoned signup must be recoverable. |
| 4 | Provide a "resend verification code" endpoint for inactive accounts (by e-mail), and/or let `/auth/login` for an inactive account return a distinct error code plus trigger a new OTP. | Today an inactive account is stuck forever. |
| 5 | Return a stable machine-readable error **code** (e.g. `USER_ALREADY_EXISTS`, `ACCOUNT_NOT_VERIFIED`) next to the message. | The app is localized (EN/AR); it must not parse English text. |
| 6 | Avoid cold starts for this environment (paid instance, or a keep-alive ping), at least for testing and release. | First request after idle can take 30–50 s on the free tier. |

## What the app already does

- On a timeout during register, it remembers the e-mail; if the user retries and gets "already exists", it continues to the verification-code screen. This is a workaround for the missing items 3–5 and relies on matching the English message text.
- The client timeout stays at 45 s until we have the numbers from item 2.

## Contact

Reply with the measurements from item 2 and which of items 1, 3, 4, 5 you can deliver, so we can remove the workaround.
