-- CreateExtension
-- Pinned to public: PostGIS's own objects expect to live there, and on a
-- shared instance it may already be installed by another tenant, in which
-- case IF NOT EXISTS makes this a no-op.
CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA public;

-- CreateEnum
CREATE TYPE "Role" AS ENUM ('CLIENT', 'BROKER');

-- CreateEnum
CREATE TYPE "BrokerKind" AS ENUM ('INDIVIDUAL', 'AGENCY');

-- CreateEnum
CREATE TYPE "VerificationStatus" AS ENUM ('NONE', 'PENDING', 'VERIFIED', 'REJECTED');

-- CreateEnum
CREATE TYPE "TransactionKind" AS ENUM ('RENT', 'SALE');

-- CreateEnum
CREATE TYPE "PropertyKind" AS ENUM ('APARTMENT', 'HOUSE', 'LAND', 'STUDIO', 'ROOM');

-- CreateEnum
CREATE TYPE "PropertyStatus" AS ENUM ('AVAILABLE', 'RESERVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "ContactChannel" AS ENUM ('CALL', 'SMS', 'WHATSAPP', 'VOICE_MESSAGE');

-- CreateEnum
CREATE TYPE "ContactOutcome" AS ENUM ('ATTEMPTED', 'REACHED', 'NO_ANSWER');

-- CreateEnum
CREATE TYPE "ModerationStatus" AS ENUM ('PENDING', 'PUBLISHED', 'REJECTED');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "email" TEXT,
    "googleSub" TEXT,
    "phone" TEXT,
    "activeRole" "Role" NOT NULL DEFAULT 'CLIENT',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "brokers" (
    "id" TEXT NOT NULL,
    "ownerId" TEXT NOT NULL,
    "kind" "BrokerKind" NOT NULL,
    "name" TEXT NOT NULL,
    "phone" TEXT NOT NULL,
    "whatsapp" TEXT,
    -- Schema-qualified on purpose. Prisma's migration engine pins search_path
    -- to the target schema alone, so an unqualified `geography` resolves only
    -- when the app owns `public`. PostGIS installs into `public` either way.
    "position" public.geography(Point,4326) NOT NULL,
    "coverage" TEXT[],
    "logoAsset" TEXT,
    "verification" "VerificationStatus" NOT NULL DEFAULT 'NONE',
    "rejectionReason" TEXT,
    "responseRate" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "pinned" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "brokers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "properties" (
    "id" TEXT NOT NULL,
    "brokerId" TEXT NOT NULL,
    "kind" "PropertyKind" NOT NULL,
    "transaction" "TransactionKind" NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL DEFAULT '',
    "price" INTEGER NOT NULL,
    "surface" INTEGER,
    "rooms" INTEGER,
    -- Schema-qualified on purpose. Prisma's migration engine pins search_path
    -- to the target schema alone, so an unqualified `geography` resolves only
    -- when the app owns `public`. PostGIS installs into `public` either way.
    "position" public.geography(Point,4326) NOT NULL,
    "neighbourhood" TEXT NOT NULL,
    "photoAssets" TEXT[],
    "status" "PropertyStatus" NOT NULL DEFAULT 'AVAILABLE',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "properties_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "reviews" (
    "id" TEXT NOT NULL,
    "brokerId" TEXT NOT NULL,
    "contactId" TEXT NOT NULL,
    "authorId" TEXT NOT NULL,
    "rating" INTEGER NOT NULL,
    "responsiveness" INTEGER,
    "accuracy" INTEGER,
    "courtesy" INTEGER,
    "comment" TEXT,
    "moderation" "ModerationStatus" NOT NULL DEFAULT 'PENDING',
    "brokerReply" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "reviews_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "contact_logs" (
    "id" TEXT NOT NULL,
    "brokerId" TEXT NOT NULL,
    "clientId" TEXT NOT NULL,
    "propertyId" TEXT,
    "channel" "ContactChannel" NOT NULL,
    "outcome" "ContactOutcome" NOT NULL DEFAULT 'ATTEMPTED',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "contact_logs_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "users_googleSub_key" ON "users"("googleSub");

-- CreateIndex
CREATE UNIQUE INDEX "users_phone_key" ON "users"("phone");

-- CreateIndex
CREATE UNIQUE INDEX "brokers_ownerId_key" ON "brokers"("ownerId");

-- CreateIndex
CREATE INDEX "brokers_position_idx" ON "brokers" USING GIST ("position");

-- CreateIndex
CREATE INDEX "properties_status_idx" ON "properties"("status");

-- CreateIndex
CREATE INDEX "properties_position_idx" ON "properties" USING GIST ("position");

-- CreateIndex
CREATE UNIQUE INDEX "reviews_contactId_key" ON "reviews"("contactId");

-- CreateIndex
CREATE INDEX "contact_logs_brokerId_idx" ON "contact_logs"("brokerId");

-- CreateIndex
CREATE INDEX "contact_logs_clientId_idx" ON "contact_logs"("clientId");

-- AddForeignKey
ALTER TABLE "brokers" ADD CONSTRAINT "brokers_ownerId_fkey" FOREIGN KEY ("ownerId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "properties" ADD CONSTRAINT "properties_brokerId_fkey" FOREIGN KEY ("brokerId") REFERENCES "brokers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_brokerId_fkey" FOREIGN KEY ("brokerId") REFERENCES "brokers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_contactId_fkey" FOREIGN KEY ("contactId") REFERENCES "contact_logs"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "reviews" ADD CONSTRAINT "reviews_authorId_fkey" FOREIGN KEY ("authorId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact_logs" ADD CONSTRAINT "contact_logs_brokerId_fkey" FOREIGN KEY ("brokerId") REFERENCES "brokers"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact_logs" ADD CONSTRAINT "contact_logs_clientId_fkey" FOREIGN KEY ("clientId") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "contact_logs" ADD CONSTRAINT "contact_logs_propertyId_fkey" FOREIGN KEY ("propertyId") REFERENCES "properties"("id") ON DELETE SET NULL ON UPDATE CASCADE;

