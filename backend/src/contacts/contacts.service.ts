import { Injectable, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateContactDto } from './dto/create-contact.dto';
import { UpdateContactOutcomeDto } from './dto/update-contact-outcome.dto';
import { ContactLogDto } from './dto/contact-log.dto';
import { BrokerContactLogDto } from './dto/broker-contact-log.dto';
import { mapContactLog } from './contact-log-row.mapper';

@Injectable()
export class ContactsService {
  constructor(private readonly prisma: PrismaService) {}

  /// Mirrors ContactRepository.log(...). The row is committed by the time
  /// this resolves — the controller has nothing left to await afterward, so
  /// "logged before the external channel opens" holds by construction: the
  /// client only calls url_launcher after this request's response returns.
  async log(dto: CreateContactDto, clientId: string): Promise<ContactLogDto> {
    try {
      const row = await this.prisma.contactLog.create({
        data: {
          brokerId: dto.brokerId,
          clientId,
          propertyId: dto.propertyId,
          channel: dto.channel,
          clientRequestId: dto.clientRequestId,
        },
        include: { review: { select: { id: true } } },
      });
      return mapContactLog(row);
    } catch (error) {
      if (
        dto.clientRequestId &&
        error instanceof Prisma.PrismaClientKnownRequestError &&
        error.code === 'P2002'
      ) {
        const existing = await this.prisma.contactLog.findFirst({
          where: { clientId, clientRequestId: dto.clientRequestId },
          include: { review: { select: { id: true } } },
        });
        if (existing) return mapContactLog(existing);
      }
      throw error;
    }
  }

  /// The other side of the same table: contacts a broker *received*.
  ///
  /// `all()` below answers "who did I contact" and filters on `clientId`, so
  /// it can never answer this — a broker calling it sees their own outgoing
  /// contacts as a client, which is why the broker activity screen was
  /// counting zero. Ownership is checked by the caller (BrokersController);
  /// this method only ever runs against one brokerId.
  ///
  /// The projection is explicit rather than `include`-and-strip so that a
  /// later field added to ContactLog cannot silently reach the broker: the
  /// client's identity is not selected at all.
  async byBrokerForOwner(brokerId: string): Promise<BrokerContactLogDto[]> {
    const rows = await this.prisma.contactLog.findMany({
      where: { brokerId },
      select: {
        id: true,
        brokerId: true,
        propertyId: true,
        channel: true,
        outcome: true,
        createdAt: true,
        review: { select: { id: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map((row) => ({
      id: row.id,
      brokerId: row.brokerId,
      propertyId: row.propertyId,
      channel: row.channel,
      outcome: row.outcome,
      hasReview: row.review !== null,
      createdAt: row.createdAt,
    }));
  }

  async all(clientId: string): Promise<ContactLogDto[]> {
    const rows = await this.prisma.contactLog.findMany({
      where: { clientId },
      include: { review: { select: { id: true } } },
      orderBy: { createdAt: 'desc' },
    });
    return rows.map(mapContactLog);
  }

  async byId(id: string, clientId: string): Promise<ContactLogDto> {
    const row = await this.prisma.contactLog.findFirst({
      where: { id, clientId },
      include: { review: { select: { id: true } } },
    });
    if (!row) throw new NotFoundException(`Contact ${id} not found`);
    return mapContactLog(row);
  }

  /// Mirrors the outcome half of ContactRepository.update(...).
  async updateOutcome(id: string, clientId: string, dto: UpdateContactOutcomeDto): Promise<ContactLogDto> {
    const existing = await this.prisma.contactLog.findUnique({ where: { id } });
    if (!existing || existing.clientId !== clientId) {
      throw new NotFoundException(`Contact ${id} not found`);
    }
    const row = await this.prisma.contactLog.update({
      where: { id },
      data: { outcome: dto.outcome },
      include: { review: { select: { id: true } } },
    });
    return mapContactLog(row);
  }
}
