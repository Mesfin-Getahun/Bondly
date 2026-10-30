import { Module, Global } from '@nestjs/common';
import { FirebaseService } from './firebase.service';

/**
 * FirebaseModule — Global module.
 * FirebaseService is exported and available across the entire app
 * without needing to import this module in each feature module.
 */
@Global()
@Module({
  providers: [FirebaseService],
  exports: [FirebaseService],
})
export class FirebaseModule {}
