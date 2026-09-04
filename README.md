# Shopify site review — punch list

A single-page, shared tracker for the 02.09 Shopify site review. 27 points translated
from the original Hebrew sheet, with **Status**, **ETA** and **Notes** that anyone with
the link can edit. Changes sync live to everyone who has the page open.

No build step, no framework, no login. Three files: `index.html`, `config.js`, `schema.sql`.

## Setup

**1. Create the table**

In the Supabase dashboard: **SQL Editor → New query**, paste all of `schema.sql`, **Run**.
That creates the `punch_items` table, its access policies, live updates, and inserts the 27 points.
It's safe to run more than once.

**2. Point the page at your project**

Edit `config.js`:

```js
window.PUNCHLIST_CONFIG = {
  url:     "https://YOUR-PROJECT.supabase.co",
  anonKey: "YOUR-ANON-KEY"
};
```

Both values are in the Supabase dashboard under **Project Settings → API**.
The anon key is a *publishable* key — it is designed to ship in client-side code.
What it is allowed to do is decided entirely by the RLS policies in `schema.sql`.

**3. Host it**

Any static host works, because the page is just HTML. Drop the folder on Netlify,
or push this repo and let Netlify/GitHub Pages serve it.

## Who can edit

As shipped, the policies in `schema.sql` allow read *and* write to anyone who opens the
page. That is what makes a plain shareable link work with no accounts. The trade-off:
anyone who gets the URL can change or delete rows.

To lock it down later, change the four policies from `using (true)` to
`using (auth.role() = 'authenticated')` and add a Supabase login to the page.

## Data model

| column | meaning |
|---|---|
| `id` | stable row key (`m01`…`m19` review, `x01`…`x08` follow-up, `c…` added in-app) |
| `sort_order` | display order |
| `section` | `review` or `followup` |
| `num` | number shown in the `#` column |
| `description` | the point itself |
| `ref` | reference text / link |
| `status` | `handled`, `partial`, `blocked`, `not_relevant`, `not_handled`, `open` |
| `status_note` | the dev team's reply under the status chip |
| `eta` | free text, filled in by the team |
| `notes` | free text, filled in by the team |
| `custom` | `true` for points added from the page (their description is editable) |

## Features

- Inline editing of Status, ETA and Notes — saves ~0.5s after you stop typing
- Live sync across open tabs via Supabase Realtime, plus a 60s refresh as a fallback
- Delete a row with confirm + undo
- Add new points
- Filter by status, search across all text
- Export the current list to CSV
- Light / dark, following the system theme with a manual toggle
