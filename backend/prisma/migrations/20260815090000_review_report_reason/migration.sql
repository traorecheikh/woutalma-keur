-- A broker can now flag a review about them (POST /reviews/:id/report), which
-- sends it back to PENDING for a human to re-moderate. The free-text reason
-- rides along so the operator has the broker's side of the story; nullable,
-- because the endpoint accepts a report without one.
ALTER TABLE "reviews" ADD COLUMN "reportedReason" TEXT;
