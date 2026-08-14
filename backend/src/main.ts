import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule } from '@nestjs/swagger';
import { json, urlencoded } from 'express';
import { AppModule } from './app.module';
import { buildOpenApiDocument } from './openapi-document';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Property photos travel as base64 inside the JSON body (no object storage
  // on the free tier), so the default 100kb limit is far too small — and an
  // unbounded limit would be a trivial way to exhaust a 512 MB instance.
  // 2 MB fits three hard-compressed photos with room to spare.
  app.use(json({ limit: '2mb' }));
  app.use(urlencoded({ extended: true, limit: '2mb' }));

  // Render terminates TLS at its own proxy; without this every request looks
  // like it came from the proxy's address.
  app.getHttpAdapter().getInstance().set('trust proxy', 1);

  // Nest only runs OnModuleDestroy (and therefore PrismaService.$disconnect)
  // when shutdown hooks are enabled. Free instances are SIGTERM'd on every
  // spin-down, so without this each idle cycle leaks a Postgres connection.
  app.enableShutdownHooks();

  // The Flutter app is not a browser origin, but Swagger UI and any future web
  // build are. CORS_ORIGINS unset means "reflect the request origin", which is
  // the right default for a public read API with bearer-token (not cookie)
  // auth — there is no ambient credential for a hostile page to ride on.
  const allowedOrigins = process.env.CORS_ORIGINS?.split(',')
    .map((origin) => origin.trim())
    .filter((origin) => origin.length > 0);
  app.enableCors({
    origin: allowedOrigins && allowedOrigins.length > 0 ? allowedOrigins : true,
    methods: ['GET', 'POST', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'x-dev-auth-secret'],
    maxAge: 86400,
  });

  app.useGlobalPipes(new ValidationPipe({ whitelist: true, transform: true }));

  // Serves Swagger UI at /api and the raw spec at /api-json — the same
  // document scripts/emit-openapi.ts writes to disk for the Dart client
  // generator, so the two can never drift apart.
  SwaggerModule.setup('api', app, buildOpenApiDocument(app));

  await app.listen(Number(process.env.PORT ?? 3000), '0.0.0.0');
}
bootstrap();
