import { Controller, Get } from '@nestjs/common';
import { SeedService } from './seed.service';
import { Result } from './interfaces/poke-response.interface';

@Controller('seed')
export class SeedController {
  constructor(private readonly seedService: SeedService) {}

  @Get()
  executeSeed(): Promise<Result[]> {
    return this.seedService.executeSeed();
  }
}
