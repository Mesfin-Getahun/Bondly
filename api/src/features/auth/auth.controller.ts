import { Controller, Get, UseGuards } from '@nestjs/common';
import { AuthService } from './auth.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  /** GET /api/v1/auth/me — returns the current authenticated user's profile */
  @UseGuards(FirebaseAuthGuard)
  @Get('me')
  getMe(@CurrentUser() user: DecodedIdToken) {
    return this.authService.getMe(user.uid);
  }
}
