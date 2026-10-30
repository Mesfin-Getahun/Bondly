import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ReportsService } from './reports.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('reports')
@UseGuards(FirebaseAuthGuard)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  /** POST /api/v1/reports — submit a report about a user or content */
  @Post()
  create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.reportsService.create(user.uid, body);
  }
}
