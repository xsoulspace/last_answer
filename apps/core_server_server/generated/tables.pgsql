--
-- Class User as table user
--

CREATE TABLE "user" (
  "id" serial,
  "created_at" timestamp without time zone NOT NULL,
  "updated_at" timestamp without time zone NOT NULL
);

ALTER TABLE ONLY "user"
  ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Class Purchase as table purchase
--

CREATE TABLE "purchase" (
  "id" serial,
  "source" text NOT NULL,
  "status" text NOT NULL,
  "purchaseDate" timestamp without time zone NOT NULL,
  "expiryDate" timestamp without time zone NOT NULL,
  "userId" integer NOT NULL,
  "orderId" text NOT NULL,
  "productId" text NOT NULL
);

ALTER TABLE ONLY "purchase"
  ADD CONSTRAINT purchase_pkey PRIMARY KEY (id);

ALTER TABLE ONLY "purchase"
  ADD CONSTRAINT purchase_fk_0
    FOREIGN KEY("userId")
      REFERENCES user(id)
        ON DELETE CASCADE;

