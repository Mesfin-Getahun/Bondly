import { Controller, Get, Post, Body, Param, Delete, UseGuards } from '@nestjs/common';
import { InvitationsService } from './invitations.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('invitations')
@UseGuards(FirebaseAuthGuard)
export class InvitationsController {
  constructor(private readonly invitationsService: InvitationsService) {}

  @Get()
  findMine(@CurrentUser() user: DecodedIdToken) {
    return this.invitationsService.findByUser(user.uid);
  }

  @Post()
  create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.invitationsService.create(user.uid, body);
  }

  @Get(':code')
  resolve(@Param('code') code: string) {
    return this.invitationsService.resolveCode(code);
  }

  @Delete(':id')
  revoke(@Param('id') id: string, @CurrentUser() user: DecodedIdToken) {
    return this.invitationsService.revoke(id, user.uid);
  }
}
