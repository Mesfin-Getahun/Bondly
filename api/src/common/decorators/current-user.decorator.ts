import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { DecodedIdToken } from 'firebase-admin/auth';

/**
 * @CurrentUser() decorator
 *
 * Extracts the decoded Firebase ID token from the request.
 * Use inside any route handler that is protected by FirebaseAuthGuard.
 *
 * Example:
 *   @Get('me')
 *   getMe(@CurrentUser() user: DecodedIdToken) {
 *     return { uid: user.uid, email: user.email };
 *   }
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, ctx: ExecutionContext): DecodedIdToken => {
    const request = ctx.switchToHttp().getRequest();
    return request.user;
  },
);
