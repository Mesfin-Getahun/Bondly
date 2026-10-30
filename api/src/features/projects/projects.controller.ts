import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('projects')
@UseGuards(FirebaseAuthGuard)
export class ProjectsController {
  constructor(private readonly projectsService: ProjectsService) {}

  @Get() findAll(@CurrentUser() user: DecodedIdToken) { return this.projectsService.findAll(user.uid); }
  @Post() create(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) { return this.projectsService.create(user.uid, body); }
  @Get(':id') findOne(@Param('id') id: string) { return this.projectsService.findOne(id); }
  @Patch(':id') update(@Param('id') id: string, @Body() body: Record<string, unknown>) { return this.projectsService.update(id, body); }
  @Delete(':id') remove(@Param('id') id: string) { return this.projectsService.remove(id); }
}
