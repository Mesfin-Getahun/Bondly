import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { ConnectionsService } from './connections.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('connections')
@UseGuards(FirebaseAuthGuard)
export class ConnectionsController {
  constructor(private readonly connectionsService: ConnectionsService) {}

  /** GET /api/v1/connections — list all connections for current user */
  @Get()
  findAll(@CurrentUser() user: DecodedIdToken) {
    return this.connectionsService.findAllForUser(user.uid);
  }

  /** POST /api/v1/connections — send a connection request */
  @Post()
  create(@CurrentUser() user: DecodedIdToken, @Body('targetUid') targetUid: string) {
    return this.connectionsService.sendRequest(user.uid, targetUid);
  }

  /** PATCH /api/v1/connections/:id/accept — accept a connection request */
  @Patch(':id/accept')
  accept(@Param('id') id: string, @CurrentUser() user: DecodedIdToken) {
    return this.connectionsService.acceptRequest(id, user.uid);
  }

  /** DELETE /api/v1/connections/:id — remove or reject a connection */
  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: DecodedIdToken) {
    return this.connectionsService.remove(id, user.uid);
  }
}
