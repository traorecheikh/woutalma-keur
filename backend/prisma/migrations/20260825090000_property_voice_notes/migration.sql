-- Broker-recorded audio for a listing, stored in Postgres like the photos.
-- "properties"."voiceAsset" holds the single "api:<id>" display key, or NULL
-- when the broker recorded nothing — existing rows start there.
ALTER TABLE "properties" ADD COLUMN "voiceAsset" TEXT;

CREATE TABLE "property_voice_notes" (
    "id" TEXT NOT NULL,
    "propertyId" TEXT NOT NULL,
    "mimeType" TEXT NOT NULL,
    "bytes" BYTEA NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "property_voice_notes_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "property_voice_notes_propertyId_idx" ON "property_voice_notes"("propertyId");

ALTER TABLE "property_voice_notes"
    ADD CONSTRAINT "property_voice_notes_propertyId_fkey"
    FOREIGN KEY ("propertyId") REFERENCES "properties"("id")
    ON DELETE CASCADE ON UPDATE CASCADE;
