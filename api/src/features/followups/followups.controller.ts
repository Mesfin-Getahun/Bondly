import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { FollowupsService } from './followups.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

/** STRICT PRIVACY: all routes scoped to current user only */
@Controller('followups')
@UseGuards(FirebaseAuthGuard)
export class FollowupsController {
  constructor(private readonly followupsService: FollowupsService) {}

  @Get()
  findAll(@CurrentUser() user: DecodedIdToken) {
    return this.followupsService.findAll(user.uid);
  }

  @Post()
  create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.followupsService.create(user.uid, body);
  }

  @Patch(':id')
  update(@Param('id') id: string, @CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.followupsService.update(user.uid, id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: DecodedIdToken) {
    return this.followupsService.remove(user.uid, id);
  }
}
