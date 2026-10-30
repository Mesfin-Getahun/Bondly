import { Controller, Get, Post, Body, Param, UseGuards } from '@nestjs/common';
import { MessagingService } from './messaging.service';
import { FirebaseAuthGuard } from '../../common/guards/firebase-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { DecodedIdToken } from 'firebase-admin/auth';

@Controller('messaging')
@UseGuards(FirebaseAuthGuard)
export class MessagingController {
  constructor(private readonly messagingService: MessagingService) {}

  @Get('conversations')
  getConversations(@CurrentUser() user: DecodedIdToken) {
    return this.messagingService.getConversations(user.uid);
  }

  @Post('conversations')
  createConversation(@CurrentUser() user: DecodedIdToken, @Body('participantUid') participantUid: string) {
    return this.messagingService.createConversation(user.uid, participantUid);
  }

  @Get('conversations/:id/messages')
  getMessages(@Param('id') conversationId: string) {
    return this.messagingService.getMessages(conversationId);
  }

  @Post('conversations/:id/messages')
  sendMessage(
    @Param('id') conversationId: string,
    @CurrentUser() user: DecodedIdToken,
    @Body('text') text: string,
  ) {
    return this.messagingService.sendMessage(conversationId, user.uid, text);
  }
}
