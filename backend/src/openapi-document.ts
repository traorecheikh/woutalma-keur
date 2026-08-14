import { INestApplication } from '@nestjs/common';
import { DocumentBuilder, OpenAPIObject, SwaggerModule } from '@nestjs/swagger';

/// Single source of the OpenAPI spec — both main.ts (serves it live at
/// /api-json for local inspection) and scripts/emit-openapi.ts (writes it to
/// disk for the Dart client generator) call this, so the two can never
/// drift apart.
export function buildOpenApiDocument(app: INestApplication): OpenAPIObject {
  const config = new DocumentBuilder()
    .setTitle('Woutalma Keur API')
    .setDescription('Phase 1: broker/property read, ranked search, contact logging, review eligibility.')
    .setVersion('0.1.0')
    .addBearerAuth()
    .build();
  return SwaggerModule.createDocument(app, config);
}
