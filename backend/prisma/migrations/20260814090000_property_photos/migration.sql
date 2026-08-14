-- Broker-uploaded photo bytes. No object storage on the free tier, so they
-- live in Postgres; Property.photoAssets keeps holding the ordered display
-- keys and gains "api:<id>" entries pointing here.
CREATE TABLE "property_photos" (
    "id" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "bytes" BYTEA NOT NULL,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "property_photos_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "property_photos_propertyId_idx" ON "property_photos"("propertyId");

ALTER TABLE "property_photos"
    ADD CONSTRAINT "property_photos_propertyId_fkey"
    FOREIGN KEY ("propertyId") REFERENCES "properties"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
