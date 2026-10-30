import {
  CanActivate,
  ExecutionContext,
  Injectable,
  UnauthorizedException,
} from '@nestjs/common';
import { Request } from 'express';
import { FirebaseService } from '../../firebase/firebase.service';

/**
 * FirebaseAuthGuard
 *
 * Validates the Firebase ID token sent as a Bearer token in
 * the Authorization header. On success, attaches the decoded
 * token payload to `request.user`:
 *   { uid, email, name, picture, ... }
 *
 * Usage:
 *   @UseGuards(FirebaseAuthGuard)
 *   @Controller('resource')
 *   export class ResourceController { ... }
 */
@Injectable()
export class FirebaseAuthGuard implements CanActivate {
  constructor(private readonly firebase: FirebaseService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<Request>();
    const authHeader = request.headers['authorization'];

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw new UnauthorizedException('Missing or invalid Authorization header');
    }

    const token = authHeader.split('Bearer ')[1];
    try {
      const decoded = await this.firebase.auth.verifyIdToken(token);
      request['user'] = decoded;
      return true;
    } catch {
      throw new UnauthorizedException('Invalid or expired Firebase ID token');
    }
  }
}
