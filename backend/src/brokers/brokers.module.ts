import { Module } from '@nestjs/common';
import { BrokersController } from './brokers.controller';
import { BrokersService } from './brokers.service';
import { PropertiesModule } from '../properties/properties.module';
import { ContactsModule } from '../contacts/contacts.module';

@Module({
  imports: [PropertiesModule, ContactsModule],
  controllers: [BrokersController],
  providers: [BrokersService],
  exports: [BrokersService],
})
export class BrokersModule {}
