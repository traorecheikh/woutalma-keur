ALTER TABLE "contact_logs" ADD COLUMN "clientRequestId" TEXT;

CREATE UNIQUE INDEX "contact_logs_clientId_clientRequestId_key"
ON "contact_logs"("clientId", "clientRequestId");
