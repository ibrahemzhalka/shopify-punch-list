-- Shopify punch list — Supabase schema
-- Run this once in the Supabase SQL editor (Dashboard → SQL Editor → New query → Run).

create table if not exists public.punch_items (
  id           text primary key,
  sort_order   integer      not null default 0,
  section      text         not null default 'review',
  num          text         not null default '',
  description  text         not null default '',
  ref          text         not null default '',
  status       text         not null default 'open',
  status_note  text         not null default '',
  eta          text         not null default '',
  notes        text         not null default '',
  custom       boolean      not null default false,
  updated_at   timestamptz  not null default now()
);

create index if not exists punch_items_sort_idx on public.punch_items (sort_order);

-- Keep updated_at fresh on every edit.
create or replace function public.punch_items_touch()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists punch_items_touch on public.punch_items;
create trigger punch_items_touch
  before update on public.punch_items
  for each row execute function public.punch_items_touch();

-- Row Level Security.
-- These policies make the list readable and editable by ANYONE who has the page URL.
-- That is what makes a public link work without logins. Swap `anon` for `authenticated`
-- if you later want to put a Supabase login in front of it.
alter table public.punch_items enable row level security;

drop policy if exists punch_read   on public.punch_items;
drop policy if exists punch_insert on public.punch_items;
drop policy if exists punch_update on public.punch_items;
drop policy if exists punch_delete on public.punch_items;

create policy punch_read   on public.punch_items for select using (true);
create policy punch_insert on public.punch_items for insert with check (true);
create policy punch_update on public.punch_items for update using (true) with check (true);
create policy punch_delete on public.punch_items for delete using (true);

-- Live updates for everyone with the page open (safe to re-run).
do $$
begin
  alter publication supabase_realtime add table public.punch_items;
exception
  when duplicate_object then null;
end $$;

-- The 27 points from the 02.09 review, translated to English.
insert into public.punch_items
  (id, sort_order, section, num, description, ref, status, status_note, eta, notes, custom)
values
  ('m01', 10, 'review', '1', 'The font is too large, and everything written in English is in CAPITALS, which is very unpleasant to the eye.
This is an issue that runs through everything on the site. It all creates a very aggressive / oversized feel and many people complained that it is really unpleasant to look at. It all really needs to be toned down.', '', 'handled', '', '', '', false),
  ('m02', 20, 'review', '2', 'We suggest considering replacing the font – right now it looks a bit too plain. Are there other options you would recommend?', '', 'handled', '', '', '', false),
  ('m03', 30, 'review', '3', 'The whole Hebrew-to-English translation matter does not look good (in both directions):
- Product names must be left in English in every case.
- The automatic translation is really funny and incorrect. (For example, the HIGH RISE cut is translated as a "skyscraper" cut... product names come out funny, etc.)
- I think what should be translated is the content itself (such as product descriptions, shipping terms, the club, etc.), and everything else can stay in English in any case. What do you think?
- When there are buttons translated from Hebrew to English, their alignment stays according to Hebrew – both inside the button and the button''s position on the right side of the banner (more relevant on desktop, but you can also see it in the main menu on mobile). It does not look good.
- The Hebrew alignment even appears inside product pages, where the sizes start from right to left instead of the other way around. We need to keep consistency across the entire site.', '', 'handled', '', '', '', false),
  ('m04', 40, 'review', '4', 'Language switch button – well positioned on desktop, but on mobile it is hidden inside a menu; it should be in the Header', '', 'handled', '', '', '', false),
  ('m05', 50, 'review', '5', 'On the homepage there are images / banners that already have text on them originally, and you added duplicate text on top of them (obviously we will replace the images underneath, I am just noting it here so we do not miss it)', '', 'handled', '', '', '', false),
  ('m06', 60, 'review', '6', 'The mobile homepage is very crowded – 7 different carousels, a lot of duplication, etc. In my opinion the whole load can be cut in half and there would still be room to add plenty of content', '', 'handled', '', '', '', false),
  ('m07', 70, 'review', '7', 'I suggest that at least some of the carousels run automatically. Not at a fast pace, but it would still give the site a bit of movement.', 'Example of good carousels on mobile https://www.emanuel.co.il/', 'not_handled', '', '', '', false),
  ('m08', 80, 'review', '8', 'You basically did not touch the design of pages that are not product pages or the homepage (say TRY AT HOME, FIT GUIDE, About the store, etc.) – everything was carried over as-is from the old site. Is the intention to leave it like this, given that it no longer looks connected after the new site?', '', 'not_handled', '', '', '', false),
  ('m09', 90, 'review', '9', 'On web, when you click Shop, a really cool and beautiful gallery of all the collections opens. Really cool. Can we just change the button design for each category? (the one sitting on each category''s image)', '', 'blocked', 'Not possible to do, according to what you told me', '', '', false),
  ('m10', 100, 'review', '10', 'Gift card – again, the design is copied from the previous site, less suitable. In addition, there is a size chart there which is not relevant to a gift card. Regardless of the design – does Shopify have a built-in gift card option? Can a free amount be entered, for example?', '', 'blocked', 'Not possible to do, according to what you told me', '', '', false),
  ('m11', 110, 'review', '11', 'On the product page, size 24 is selected by default. Can there be no default, so customers simply choose?', '', 'blocked', 'Not possible to do, according to what you told me', '', '', false),
  ('m12', 120, 'review', '12', 'Add Breadcrumbs on product pages', '', 'handled', '', '', '', false),
  ('m13', 130, 'review', '13', 'In product galleries, add the available sizes (or show all sizes with the ones in stock highlighted)', '', 'not_relevant', '', '', '', false),
  ('m14', 140, 'review', '14', 'Everywhere there are several categories (for example, on a product page there is product details / care / size & fit, or more importantly in the main mobile menu), the first category is open automatically and it does not look good – very noticeable in the mobile menu, which opens SHOP automatically, and then it looks like there is a glitch and a distortion between the fonts)', '', 'handled', '', '', '', false),
  ('m15', 150, 'review', '15', 'On product pages on WEB, scrolling up and down always moves only the images side and not the text. It seems minor, but this comment came back from everyone I let try it, so it apparently bothers customers', '', 'not_handled', 'What can be done about this? Everyone who tried it complained about it', '', '', false),
  ('m16', 160, 'review', '16', 'I saw that a coupon code can only be added during the add-to-cart process and not during the checkout process.

In addition, can a field for additional notes be added on the payment page? (many customers like to give notes / instructions / additions regarding measurements etc. at the end) If not, then it is not critical.', '', 'blocked', 'Not possible to do, according to what you told me', '', '', false),
  ('m17', 170, 'review', '17', 'The design of the size chart and the measuring instructions was kept from the old site – it does not really suit the new site, and on mobile it opens very small and unreadable', '', 'partial', 'Already better in terms of size.', '', '', false),
  ('m18', 180, 'review', '18', 'In the categories there is currently no good filter – for us a price filter is less important. The only two parameters that interest us are cut and size (in stock)', '', 'handled', 'The filters are excellent. Can the "Sort" be removed? It is not relevant for us. If not, then it is not critical', '', '', false),
  ('m19', 190, 'review', '19', 'The footer on mobile is very large and it is not clear why it contains unrelated categories. (They also appear on desktop, which matters less, although in my opinion they could be removed from there as well)', '', 'not_handled', 'The footer is still huge – it is so big that it overflows past the margins and you have to scroll inside it. It really does not look good', '', '', false),
  ('x01', 1010, 'followup', '1', 'The size recommendation app we talked about is missing.', '', 'open', '', '', '', false),
  ('x02', 1020, 'followup', '2', 'Is it possible for the fit guide link to be different for different categories? (the men''s size chart is different from the women''s, and shirts differ from trousers) This is a critical point and we would be glad if it can be handled', '', 'open', '', '', '', false),
  ('x03', 1030, 'followup', '3', 'Is the privacy and cookies matter legally compliant?', '', 'open', '', '', '', false),
  ('x04', 1040, 'followup', '4', 'I currently have no way to see the customer club and how the points are redeemed at purchase. How can I see this?', '', 'open', '', '', '', false),
  ('x05', 1050, 'followup', '5', 'Can the gift card page be changed so that the amounts are whole numbers and not with digits after the decimal point? For example 100.00 etc. – it looks really odd.', '', 'open', '', '', '', false),
  ('x06', 1060, 'followup', '6', 'The accessibility statement page appears only in English.', '', 'open', '', '', '', false),
  ('x07', 1070, 'followup', '7', 'There are all sorts of small things and design things that I think it is better I handle myself once I have access to Shopify itself. Mainly because I need to learn how to work with the system. When can I start playing with it?', '', 'open', '', '', '', false),
  ('x08', 1080, 'followup', '8', 'Besides Hashavshevet (accounting software), what else are you missing? Payment processing?', '', 'open', '', '', '', false)
on conflict (id) do nothing;
