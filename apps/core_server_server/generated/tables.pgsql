--
-- Class User as table users
--

CREATE TABLE "users" (
  "id" serial,
  "created_at" timestamp without time zone NOT NULL,
  "updated_at" timestamp without time zone NOT NULL
);

ALTER TABLE ONLY "users"
  ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Class Purchases as table user_purchases
--

CREATE TABLE "user_purchases" (
  "id" serial,
  "userId" integer NOT NULL,
  "has_one_time_purchase" boolean NOT NULL,
  "subscription_end_date" timestamp without time zone NOT NULL,
  "purchased_days_left" integer NOT NULL
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
  "source" integer NOT NULL,
  "status" integer NOT NULL,
  "purchase_date" timestamp without time zone NOT NULL,
  "expiry_date" timestamp without time zone NOT NULL,
  "userId" integer NOT NULL,
  "orderId" text NOT NULL,
  "productId" text NOT NULL
);

ALTER TABLE ONLY "purchases"
  ADD CONSTRAINT purchases_pkey PRIMARY KEY (id);

ALTER TABLE ONLY "purchases"
  ADD CONSTRAINT purchases_fk_0
    FOREIGN KEY("userId")
      REFERENCES users(id)
        ON DELETE CASCADE;

