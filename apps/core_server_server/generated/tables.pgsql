--
-- Class User as table users
--

CREATE TABLE "users" (
  "id" serial,
  "created_at" timestamp without time zone,
  "updated_at" timestamp without time zone
);

ALTER TABLE ONLY "users"
  ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Class Purchases as table user_purchases
--

CREATE TABLE "user_purchases" (
  "id" serial,
  "userId" integer NOT NULL,
  "has_one_time_purchase" boolean,
  "subscription_end_date" timestamp without time zone,
  "purchased_days_left" integer
);

ALTER TABLE ONLY "user_purchases"
  ADD CONSTRAINT user_purchases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY "user_purchases"
  ADD CONSTRAINT user_purchases_fk_0
    FOREIGN KEY("userId")
      REFERENCES users(id)
        ON DELETE CASCADE;

--
-- Class Purchase as table purchases
--

CREATE TABLE "purchases" (
  "id" serial,
  "source" integer,
  "status" integer,
  "purchase_date" timestamp without time zone,
  "expiry_date" timestamp without time zone,
  "userId" integer NOT NULL,
  "orderId" text,
  "productId" text
);

ALTER TABLE ONLY "purchases"
  ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY "purchases"
  ADD CONSTRAINT purchases_fk_0
    FOREIGN KEY("userId")
      REFERENCES users(id)
        ON DELETE CASCADE;

