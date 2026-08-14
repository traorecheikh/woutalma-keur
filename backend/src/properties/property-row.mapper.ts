import { PropertyKind, PropertyStatus, TransactionKind } from '@prisma/client';
import { PropertyDto } from './dto/property.dto';

export interface PropertyRow {
  id: string;
  brokerId: string;
  kind: PropertyKind;
  transaction: TransactionKind;
  title: string;
  description: string;
  price: number;
  surface: number | null;
  rooms: number | null;
  neighbourhood: string;
  photoAssets: string[];
  status: PropertyStatus;
  createdAt: Date;
  latitude: number;
  longitude: number;
}

export function mapPropertyRow(row: PropertyRow): PropertyDto {
  return {
    id: row.id,
    brokerId: row.brokerId,
    kind: row.kind,
    transaction: row.transaction,
    title: row.title,
    description: row.description,
    price: row.price,
    surface: row.surface,
    rooms: row.rooms,
    position: { latitude: row.latitude, longitude: row.longitude },
    neighbourhood: row.neighbourhood,
    photoAssets: row.photoAssets,
    status: row.status,
    createdAt: row.createdAt,
    // Closed covers both sold and rented — matches Property.isDiscoverable
    // in lib/app/domain/entities.dart: the client only needs "no longer
    // available", not which of the two it was.
    isDiscoverable: row.status !== PropertyStatus.CLOSED,
  };
}
