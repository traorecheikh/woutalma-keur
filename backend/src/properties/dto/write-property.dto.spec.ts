import { plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { PropertyKind, TransactionKind } from '@prisma/client';
import { CreatePropertyDto, MAX_PRICE_CFA, UpdatePropertyDto } from './write-property.dto';

/// Pure DTO test — no database, unlike every other spec in this project.
///
/// It guards the one thing that regresses silently: what a broker is allowed
/// to type into B03. The rules are argued in write-property.dto.ts; this file
/// only proves they are actually wired, in the same order the ValidationPipe
/// applies them (transform first, then validate).
function build(overrides: Partial<Record<keyof CreatePropertyDto, unknown>> = {}): CreatePropertyDto {
  return plainToInstance(CreatePropertyDto, {
    kind: PropertyKind.APARTMENT,
    transaction: TransactionKind.RENT,
    title: 'Appartement 3 pièces',
    price: 250_000,
    latitude: 14.669,
    longitude: -17.438,
    neighbourhood: 'Plateau',
    ...overrides,
  });
}

function errorsOn(dto: object): string[] {
  return validateSync(dto, { whitelist: true }).map((error) => error.property);
}

describe('CreatePropertyDto — what a broker is allowed to type', () => {
  it('accepts a plain listing', () => {
    expect(errorsOn(build())).toEqual([]);
  });

  describe('title and neighbourhood normalisation', () => {
    it('trims and collapses whitespace runs, including a stray newline', () => {
      const dto = build({ title: '  Villa   basse \n à Ngor ', neighbourhood: ' Point  E ' });
      expect(dto.title).toBe('Villa basse à Ngor');
      expect(dto.neighbourhood).toBe('Point E');
    });

    it('preserves accents, ligatures and non-Latin script untouched', () => {
      const dto = build({ title: 'Chambre à Sacré-Cœur — بيت', neighbourhood: 'Médina' });
      expect(dto.title).toBe('Chambre à Sacré-Cœur — بيت');
      expect(dto.neighbourhood).toBe('Médina');
      expect(errorsOn(dto)).toEqual([]);
    });

    it('rejects a title that is empty once trimmed', () => {
      expect(errorsOn(build({ title: '   ' }))).toContain('title');
    });

    it('rejects a neighbourhood that is empty once trimmed', () => {
      expect(errorsOn(build({ neighbourhood: '\n\t' }))).toContain('neighbourhood');
    });

    it('accepts a quartier the eighteen-name picker does not know', () => {
      expect(errorsOn(build({ neighbourhood: 'Diamniadio' }))).toEqual([]);
    });

    it('leaves a non-string title to @IsString rather than swallowing it', () => {
      expect(errorsOn(build({ title: 42 }))).toContain('title');
    });
  });

  describe('description', () => {
    it('trims the ends but keeps the line breaks the composed text relies on', () => {
      const dto = build({ description: '\n  Deux chambres.\n\nGrand salon.  \n' });
      expect(dto.description).toBe('Deux chambres.\n\nGrand salon.');
      expect(errorsOn(dto)).toEqual([]);
    });
  });

  describe('price bounds', () => {
    it('refuses a free listing', () => {
      expect(errorsOn(build({ price: 0 }))).toContain('price');
    });

    it('accepts an exceptional villa at the corniche', () => {
      expect(errorsOn(build({ price: 900_000_000 }))).toEqual([]);
    });

    it('refuses a price past the ceiling', () => {
      expect(errorsOn(build({ price: MAX_PRICE_CFA + 1 }))).toContain('price');
    });
  });

  describe('surface and rooms, as a picker now produces them', () => {
    it('accepts a land listing with no rooms at all', () => {
      expect(errorsOn(build({ kind: PropertyKind.LAND, rooms: null, surface: 300 }))).toEqual([]);
    });

    it('accepts a land listing that answers zero rooms', () => {
      expect(errorsOn(build({ kind: PropertyKind.LAND, rooms: 0 }))).toEqual([]);
    });

    it('accepts an omitted surface', () => {
      expect(errorsOn(build({ surface: undefined }))).toEqual([]);
    });

    it('refuses a surface of zero — unstated travels as null', () => {
      expect(errorsOn(build({ surface: 0 }))).toContain('surface');
    });

    it('refuses an absurd surface and an absurd room count', () => {
      expect(errorsOn(build({ surface: 5_000_000 }))).toContain('surface');
      expect(errorsOn(build({ rooms: 500 }))).toContain('rooms');
    });
  });

  describe('voice note', () => {
    it('accepts a recording in a format a phone produces', () => {
      const dto = build({ newVoiceNote: { mimeType: 'audio/mp4', dataBase64: 'AAAA' } });
      expect(errorsOn(dto)).toEqual([]);
    });

    it('refuses a format the player cannot be trusted with', () => {
      const dto = build({ newVoiceNote: { mimeType: 'audio/x-caf', dataBase64: 'AAAA' } });
      expect(errorsOn(dto)).toContain('newVoiceNote');
    });

    it('accepts the empty string that means "remove the recording"', () => {
      expect(errorsOn(build({ voiceAsset: '' }))).toEqual([]);
    });
  });
});

describe('UpdatePropertyDto — the same rules survive PartialType', () => {
  it('leaves absent fields absent', () => {
    const dto = plainToInstance(UpdatePropertyDto, { price: 300_000 });
    expect(dto.title).toBeUndefined();
    expect(errorsOn(dto)).toEqual([]);
  });

  it('still normalises and still refuses a blanked title', () => {
    const dto = plainToInstance(UpdatePropertyDto, { title: '  Studio   Yoff  ' });
    expect(dto.title).toBe('Studio Yoff');
    expect(errorsOn(plainToInstance(UpdatePropertyDto, { title: ' ' }))).toContain('title');
  });
});
