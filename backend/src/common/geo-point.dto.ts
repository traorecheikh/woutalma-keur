import { ApiProperty } from '@nestjs/swagger';

/// Mirrors lib/app/domain/entities.dart's GeoPoint. PostGIS stores this as a
/// single geography(Point,4326) column; every read path re-projects it back
/// to {latitude, longitude} so the wire shape matches what the Flutter app
/// already knows how to parse.
export class GeoPointDto {
  @ApiProperty()
  latitude!: number;

  @ApiProperty()
  longitude!: number;
}
