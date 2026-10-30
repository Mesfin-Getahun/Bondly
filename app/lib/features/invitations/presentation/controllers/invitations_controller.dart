import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/invitations_entity.dart';
import '../../domain/repositories/invitations_repository.dart';
import '../../domain/usecases/get_invitations_usecase.dart';
import '../../data/repositories/invitations_repository_impl.dart';

/// Feature: Invitations - Controller (ChangeNotifier)
class InvitationsController extends ChangeNotifier {
  final GetSentInvitationsUseCase _getSentInvitations;
  final CreateInvitationUseCase _createInvitation;
  final ClaimInvitationUseCase _claimInvitation;
  final RevokeInvitationUseCase _revokeInvitation;

  InvitationsController({
    InvitationsRepository? repository,
  })  : _getSentInvitations = GetSentInvitationsUseCase(repository ?? InvitationsRepositoryImpl()),
        _createInvitation = CreateInvitationUseCase(repository ?? InvitationsRepositoryImpl()),
        _claimInvitation = ClaimInvitationUseCase(repository ?? InvitationsRepositoryImpl()),
        _revokeInvitation = RevokeInvitationUseCase(repository ?? InvitationsRepositoryImpl());

  StreamSubscription<List<InvitationEntity>>? _sub;
  String? _currentUserId;

  List<InvitationEntity> _invitations = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  List<InvitationEntity> get invitations => _invitations;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<InvitationEntity> get activeInvitations =>
      _invitations.where((i) => i.isPending).toList();

  List<InvitationEntity> get historyInvitations =>
      _invitations.where((i) => !i.isPending).toList();

  int get totalCount => _invitations.length;
  int get activeCount => activeInvitations.length;
  int get claimedCount => _invitations.where((i) => i.isClaimed).length;

  void init(String currentUserId) {
    if (_currentUserId == currentUserId && _sub != null) return;
    _currentUserId = currentUserId;

    _isLoading = true;
    notifyListeners();

    _sub?.cancel();
    _sub = _getSentInvitations(currentUserId).listen((list) {
      _invitations = list;
      _isLoading = false;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<InvitationEntity?> createNewInvitation({
    required String senderId,
    required String senderName,
    String? inviteeName,
    String? inviteeEmail,
    String relationshipType = 'Friend',
    String? personalNote,
    int validityDays = 14,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inv = await _createInvitation(
        senderId: senderId,
        senderName: senderName,
        inviteeName: inviteeName,
        inviteeEmail: inviteeEmail,
        relationshipType: relationshipType,
        personalNote: personalNote,
        validityDays: validityDays,
      );
      _successMessage = 'Invitation code ${inv.code} created successfully!';
      return inv;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> redeemInvitation({
    required String code,
    required String recipientId,
    required String recipientName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final inv = await _claimInvitation(
        code: code,
        recipientId: recipientId,
        recipientName: recipientName,
      );
      _successMessage = 'Connected with ${inv.senderName}! Invitation redeemed.';
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '').replaceFirst('ServerException: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> revoke(String invitationId) async {
    try {
      await _revokeInvitation(invitationId);
      _successMessage = 'Invitation revoked.';
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
