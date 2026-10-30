import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { GoalsService } from './goals.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('goals')
@UseGuards(FirebaseAuthGuard)
export class GoalsController {
  constructor(private readonly goalsService: GoalsService) {}

  @Get() findAll(@CurrentUser() user: DecodedIdToken) { return this.goalsService.findAll(user.uid); }
  @Post() create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) { return this.goalsService.create(user.uid, body); }
  @Patch(':id') update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.goalsService.update(id, body); }
  @Delete(':id') remove(@Param('id') id: string) { return this.goalsService.remove(id); }
}
