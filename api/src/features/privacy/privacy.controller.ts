import { Controller, Get, Post, Body, Delete, UseGuards } from '@nestjs/common';
import { PrivacyService } from './privacy.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('privacy')
@UseGuards(FirebaseAuthGuard)
export class PrivacyController {
  constructor(private readonly privacyService: PrivacyService) {}

  @Get('settings')
  getSettings(@CurrentUser() user: DecodedIdToken) {
    return this.privacyService.getSettings(user.uid);
  }

  @Post('settings')
  updateSettings(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.privacyService.updateSettings(user.uid, body);
  }

  @Post('export')
  requestExport(@CurrentUser() user: DecodedIdToken) {
    return this.privacyService.requestDataExport(user.uid);
  }

  @Delete('account')
  deleteAccount(@CurrentUser() user: DecodedIdToken) {
    return this.privacyService.requestAccountDeletion(user.uid);
  }
}
