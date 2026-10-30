import { Controller, Get, UseGuards } from '@nestjs/common';
import { InsightsService } from './insights.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('insights')
@UseGuards(FirebaseAuthGuard)
export class InsightsController {
  constructor(private readonly insightsService: InsightsService) {}

  /** GET /api/v1/insights — get personalised relationship insights for current user */
  @Get()
  findMine(@CurrentUser() user: DecodedIdToken) {
    return this.insightsService.findForUser(user.uid);
  }
}
