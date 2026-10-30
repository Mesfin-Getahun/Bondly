import { Controller, Get, Post, Body, Param, Patch, Delete, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('users')
@UseGuards(FirebaseAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  getMyProfile(@CurrentUser() user: DecodedIdToken) {
    return this.usersService.findById(user.uid);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findById(id);
  }

  @Patch('me')
  updateMyProfile(@CurrentUser() user: DecodedIdToken, @Body() body: Record<string, unknown>) {
    return this.usersService.updateProfile(user.uid, body);
  }

  @Delete('me')
  deleteMyAccount(@CurrentUser() user: DecodedIdToken) {
    return this.usersService.deleteAccount(user.uid);
  }
}
