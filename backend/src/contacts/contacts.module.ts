import { Module } from '@nestjs/common';
import { ContactsController } from './contacts.controller';
import { ContactsService } from './contacts.service';

/// Exports ContactsService so BrokersModule can serve GET /brokers/:id/contacts
/// (the received-contacts view) without duplicating the query. The edge stays
/// one-way — ContactsModule imports nothing from brokers.
@Module({
  controllers: [ContactsController],
  providers: [ContactsService],
  exports: [ContactsService],
})
export class ContactsModule {}
