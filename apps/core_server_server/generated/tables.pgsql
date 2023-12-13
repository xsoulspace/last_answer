--
-- Class User as table custom_users
--

CREATE TABLE "custom_users" (
  "id" serial,
  "user_id" integer NOT NULL,
  "created_at" timestamp without time zone,
  "updated_at" timestamp without time zone
);

ALTER TABLE ONLY "custom_users"
  ADD CONSTRAINT custom_users_pkey PRIMARY KEY (id);


--
-- Class Purchases as table custom_user_purchases
--

CREATE TABLE "custom_user_purchases" (
  "id" serial,
  "userId" integer NOT NULL,
  "has_one_time_purchase" boolean,
  "subscription_end_date" timestamp without time zone,
  "purchased_days_left" integer
);

ALTER TABLE ONLY "custom_user_purchases"
  ADD CONSTRAINT custom_user_purchases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY "custom_user_purchases"
  ADD CONSTRAINT custom_user_purchases_fk_0
    FOREIGN KEY("userId")
      REFERENCES custom_users(id)
        ON DELETE CASCADE;

--
-- Class Purchase as table custom_purchases
--

CREATE TABLE "custom_purchases" (
  "id" serial,
  "source" integer,
  "status" integer,
  "purchase_date" timestamp without time zone,
  "expiry_date" timestamp without time zone,
  "userId" integer NOT NULL,
  "orderId" text,
  "productId" text
);

ALTER TABLE ONLY "custom_purchases"
  ADD CONSTRAINT custom_purchases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY "custom_purchases"
  ADD CONSTRAINT custom_purchases_fk_0
    FOREIGN KEY("userId")
      REFERENCES custom_users(id)
        ON DELETE CASCADE;

