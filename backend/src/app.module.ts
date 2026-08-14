import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { PrismaModule } from './prisma/prisma.module';
import { AuthModule } from './auth/auth.module';
import { BrokersModule } from './brokers/brokers.module';
import { PropertiesModule } from './properties/properties.module';
import { SearchModule } from './search/search.module';
import { ReviewsModule } from './reviews/reviews.module';
import { ContactsModule } from './contacts/contacts.module';
import { HealthModule } from './health/health.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    PrismaModule,
    HealthModule,
    AuthModule,
    BrokersModule,
    PropertiesModule,
    SearchModule,
    ReviewsModule,
    ContactsModule,
  ],
})
export class AppModule {}
