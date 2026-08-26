ALTER TABLE "properties" ADD COLUMN "clientRequestId" TEXT;

CREATE UNIQUE INDEX "properties_brokerId_clientRequestId_key"
ON "properties"("brokerId", "clientRequestId");
