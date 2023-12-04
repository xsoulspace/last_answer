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
-- Class Purchase as table purchases
--

CREATE TABLE "purchases" (
  "id" serial,
  "source" text NOT NULL,
  "status" text NOT NULL,
  "purchaseDate" timestamp without time zone NOT NULL,
  "expiryDate" timestamp without time zone NOT NULL,
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

