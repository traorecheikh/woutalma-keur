import { BrokerKind, VerificationStatus } from '@prisma/client';
import { BrokerDto } from './dto/broker.dto';

/// Shape of a broker row selected via raw SQL (position re-projected to
/// latitude/longitude by common/postgis.ts's selectLatLng). Shared between
/// brokers.service.ts and search.service.ts so both endpoints serialize a
/// broker identically.
export interface BrokerRow {
  id: string;
  kind: BrokerKind;
  name: string;
  phone: string;
  whatsapp: string | null;
  coverage: string[];
  logoAsset: string | null;
  verification: VerificationStatus;
  responseRate: number;
  pinned: boolean;
  latitude: number;
  longitude: number;
}

export function mapBrokerRow(row: BrokerRow): BrokerDto {
  return {
    id: row.id,
    kind: row.kind,
    name: row.name,
    phone: row.phone,
    whatsapp: row.whatsapp,
    position: { latitude: row.latitude, longitude: row.longitude },
    coverage: row.coverage,
    logoAsset: row.logoAsset,
    verification: row.verification,
    responseRate: row.responseRate,
    pinned: row.pinned,
    isVerified: row.verification === VerificationStatus.VERIFIED,
  };
}
