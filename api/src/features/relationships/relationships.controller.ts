import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { RelationshipsService } from './relationships.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

/** STRICT PRIVACY: all routes scoped to current user only */
@Controller('relationships')
@UseGuards(FirebaseAuthGuard)
export class RelationshipsController {
  constructor(private readonly relationshipsService: RelationshipsService) {}

  @Get()
  findAll(@CurrentUser() user: DecodedIdToken) {
    return this.relationshipsService.findAll(user.uid);
  }

  @Post()
  create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.relationshipsService.create(user.uid, body);
  }

  @Get(':id')
  findOne(@Param('id') id: string, @CurrentUser() user: DecodedIdToken) {
    return this.relationshipsService.findOne(user.uid, id);
  }

  @Patch(':id')
  update(@Param('id') id: string, @CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.relationshipsService.update(user.uid, id, body);
  }

  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: DecodedIdToken) {
    return this.relationshipsService.remove(user.uid, id);
  }
}
