import 'reflect-metadata';
import { writeFileSync } from 'node:fs';
import { resolve } from 'node:path';
import { NestFactory } from '@nestjs/core';
import { AppModule } from '../src/app.module';
import { buildOpenApiDocument } from '../src/openapi-document';

/// Writes backend/openapi.json without binding a port — this is what
/// `npm run emit:openapi` runs, and what packages/woutalma_api_client's
/// generation command (see root tool/generate_api_client.sh) reads from.
/// Never hand-edit the output; it's a build artifact of the controllers.
async function main() {
  process.env.SKIP_PRISMA_CONNECT = 'true';
  const app = await NestFactory.create(AppModule, { logger: false });
  await app.init();

  const document = buildOpenApiDocument(app);
  const outPath = resolve(__dirname, '..', 'openapi.json');
  writeFileSync(outPath, JSON.stringify(document, null, 2));
  // eslint-disable-next-line no-console
  console.log(`Wrote ${outPath}`);

  await app.close();
}

main().catch((error) => {
  // eslint-disable-next-line no-console
  console.error(error);
  process.exit(1);
});
