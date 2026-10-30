import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { GroupsService } from './groups.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('groups')
@UseGuards(FirebaseAuthGuard)
export class GroupsController {
  constructor(private readonly groupsService: GroupsService) {}

  @Get() findAll(@CurrentUser() user: DecodedIdToken) { return this.groupsService.findAll(user.uid); }
  @Post() create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) { return this.groupsService.create(user.uid, body); }
  @Get(':id') findOne(@Param('id') id: string) { return this.groupsService.findOne(id); }
  @Patch(':id') update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.groupsService.update(id, body); }
  @Delete(':id') remove(@Param('id') id: string) { return this.groupsService.remove(id); }
}
