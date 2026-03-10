import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:idoc_user/data/models/chat_message_model.dart';
import 'package:idoc_user/data/repostories/user_chat_repository.dart';
import 'package:idoc_user/logic/blocs/chat/chat_bloc.dart';

import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Design tokens
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF0077B6);
  static const primaryLight = Color(0xFF90E0EF);
  static const accent = Color(0xFF00B4D8);
  static const bgBase = Color(0xFFF2F8FF);
  static const bgChat = Color(0xFFEDF4FB);
  static const cardBg = Colors.white;
  static const textPrimary = Color(0xFF1A2332);
  static const textSecondary = Color(0xFF6B7A91);
  static const textMuted = Color(0xFFADB8C9);
  static const divider = Color(0xFFEEF2F7);
  static const sentBubble1 = Color(0xFF0077B6);
  static const sentBubble2 = Color(0xFF00B4D8);
  static const receivedBubble = Colors.white;
}

// ─────────────────────────────────────────────────────────────────────────────
// Message stream BLoC — watches only messages sub-collection
// ─────────────────────────────────────────────────────────────────────────────

abstract class _MsgEvent {}

class _StartMessages extends _MsgEvent {
  final String chatRoomId;
  _StartMessages(this.chatRoomId);
}

abstract class _MsgState {}

class _MsgInitial extends _MsgState {}

class _MsgLoaded extends _MsgState {
  final List<ChatMessageModel> messages;
  _MsgLoaded(this.messages);
}

class _MessageStreamBloc extends Bloc<_MsgEvent, _MsgState> {
  final UserChatRepository _repo;

  _MessageStreamBloc(this._repo) : super(_MsgInitial()) {
    on<_StartMessages>(_onStart);
  }

  Future<void> _onStart(_StartMessages event, Emitter<_MsgState> emit) async {
    await emit.forEach<List<ChatMessageModel>>(
      _repo.watchMessages(event.chatRoomId),
      onData: (msgs) => _MsgLoaded(msgs),
      onError: (_, __) => _MsgInitial(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UserChatScreen
// ─────────────────────────────────────────────────────────────────────────────

class UserChatScreen extends StatelessWidget {
  final String doctorId;
  final String patientId;
  final String appointmentId;
  final String? doctorName;
  final String? patientName;
  final String? doctorProfileImageUrl;
  final String? patientProfileImageUrl;

  const UserChatScreen({
    super.key,
    required this.doctorId,
    required this.patientId,
    required this.appointmentId,
    this.doctorName,
    this.patientName,
    this.doctorProfileImageUrl,
    this.patientProfileImageUrl,
  });

  static Route<void> route({
    required String doctorId,
    required String patientId,
    required String appointmentId,
    String? doctorName,
    String? patientName,
    String? doctorProfileImageUrl,
    String? patientProfileImageUrl,
  }) =>
      MaterialPageRoute(
        builder: (_) => UserChatScreen(
          doctorId: doctorId,
          patientId: patientId,
          appointmentId: appointmentId,
          doctorName: doctorName,
          patientName: patientName,
          doctorProfileImageUrl: doctorProfileImageUrl,
          patientProfileImageUrl: patientProfileImageUrl,
        ),
      );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => UserChatBloc()
            ..add(InitializeUserChat(
              doctorId: doctorId,
              patientId: patientId,
              appointmentId: appointmentId,
              doctorName: doctorName,
              patientName: patientName,
              doctorProfileImageUrl: doctorProfileImageUrl,
              patientProfileImageUrl: patientProfileImageUrl,
            )),
        ),
        BlocProvider(
          create: (_) => _MessageStreamBloc(UserChatRepository()),
        ),
      ],
      child: _ChatView(
        patientId: patientId,
        doctorName: doctorName,
        doctorProfileImageUrl: doctorProfileImageUrl,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChatView — reacts to both BLoCs
// ─────────────────────────────────────────────────────────────────────────────

class _ChatView extends StatefulWidget {
  final String patientId;
  final String? doctorName;
  final String? doctorProfileImageUrl;

  const _ChatView({
    required this.patientId,
    this.doctorName,
    this.doctorProfileImageUrl,
  });

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  bool _messageStreamStarted = false;

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    // ✅ FIX: Do NOT call context.read() in dispose - the BLoC provider
    // is already unmounted. The BLoC's close() method will clean up streams.
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    context.read<UserChatBloc>().add(SendUserMessage(text));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _C.bgChat,
        body: Column(
          children: [
            // ── App bar ─────────────────────────────────────────────
            _ChatAppBar(
              doctorName: widget.doctorName,
              avatarUrl: widget.doctorProfileImageUrl,
            ),

            // ── Main content ─────────────────────────────────────────
            Expanded(
              child: BlocConsumer<UserChatBloc, UserChatState>(
                listener: (context, state) {
                  if (state is UserChatLoaded && !_messageStreamStarted) {
                    // Room exists — start the message stream
                    _messageStreamStarted = true;
                    context
                        .read<_MessageStreamBloc>()
                        .add(_StartMessages(state.chatRoom.chatRoomId));
                    
                    // ✅ FIX: Mark as read immediately when THIS screen opens
                    // (not when the inbox loads)
                    context
                        .read<UserChatBloc>()
                        .add(const MarkUserMessagesRead());
                  }
                },
                builder: (context, chatState) {
                  if (chatState is UserChatLoading) {
                    return const _LoadingView();
                  }
                  if (chatState is UserChatWaiting) {
                    return const _WaitingView();
                  }
                  if (chatState is UserChatError) {
                    return _ErrorView(message: chatState.message);
                  }
                  if (chatState is UserChatLoaded) {
                    // Listen to message stream
                    return BlocConsumer<_MessageStreamBloc, _MsgState>(
                      listener: (_, msgState) {
                        if (msgState is _MsgLoaded) {
                          _scrollToBottom();
                          // ✅ Already marked as read when screen opened above
                          // No need to mark again on every new message event
                        }
                      },
                      builder: (_, msgState) {
                        final messages = msgState is _MsgLoaded
                            ? msgState.messages
                            : chatState.messages;

                        if (messages.isEmpty) {
                          return const _EmptyView();
                        }
                        return _MessageList(
                          messages: messages,
                          patientId: widget.patientId,
                          scrollCtrl: _scrollCtrl,
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),

            // ── Input field ──────────────────────────────────────────
            BlocBuilder<UserChatBloc, UserChatState>(
              builder: (context, state) {
                final canSend = state is UserChatLoaded;
                return _InputBar(
                  controller: _inputCtrl,
                  onSend: canSend ? _sendMessage : null,
                  isSending:
                      state is UserChatLoaded ? state.isSending : false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// App bar
// ─────────────────────────────────────────────────────────────────────────────

class _ChatAppBar extends StatelessWidget {
  final String? doctorName;
  final String? avatarUrl;

  const _ChatAppBar({this.doctorName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.only(
        top: topPad + 10,
        bottom: 14,
        left: 8,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF005F8E), _C.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          // Doctor avatar
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.4), width: 1.5),
            ),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl!.isNotEmpty
                  ? Image.network(
                      avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _DoctorInitialAvatar(name: doctorName),
                    )
                  : _DoctorInitialAvatar(name: doctorName),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctorName != null ? 'Dr. $doctorName' : 'Your Doctor',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF4EE876),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Doctor',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white.withOpacity(0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorInitialAvatar extends StatelessWidget {
  final String? name;
  const _DoctorInitialAvatar({this.name});

  @override
  Widget build(BuildContext context) {
    final initial =
        (name != null && name!.isNotEmpty) ? name![0].toUpperCase() : 'D';
    return Container(
      color: _C.primaryLight.withOpacity(0.35),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Message list
// ─────────────────────────────────────────────────────────────────────────────

class _MessageList extends StatelessWidget {
  final List<ChatMessageModel> messages;
  final String patientId;
  final ScrollController scrollCtrl;

  const _MessageList({
    required this.messages,
    required this.patientId,
    required this.scrollCtrl,
  });

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayLabel(DateTime dt) {
    final now = DateTime.now();
    if (_isSameDay(dt, now)) return 'Today';
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(dt, yesterday)) return 'Yesterday';
    return DateFormat('MMMM d, y').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: messages.length,
      itemBuilder: (_, i) {
        final msg = messages[i];
        final isFromPatient = msg.senderId == patientId;

        // Date separator
        bool showDate = false;
        if (i == 0) {
          showDate = true;
        } else {
          showDate =
              !_isSameDay(messages[i - 1].timestamp, msg.timestamp);
        }

        return Column(
          children: [
            if (showDate) _DateSeparator(label: _dayLabel(msg.timestamp)),
            _ChatBubble(
              message: msg,
              isFromPatient: isFromPatient,
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Date separator
// ─────────────────────────────────────────────────────────────────────────────

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: _C.divider),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: _C.primaryLight.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: _C.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 1, color: _C.divider),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat bubble
// ─────────────────────────────────────────────────────────────────────────────

class _ChatBubble extends StatelessWidget {
  final ChatMessageModel message;
  final bool isFromPatient;

  const _ChatBubble({
    required this.message,
    required this.isFromPatient,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          isFromPatient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: 3,
          bottom: 3,
          left: isFromPatient ? 60 : 0,
          right: isFromPatient ? 0 : 60,
        ),
        child: Column(
          crossAxisAlignment: isFromPatient
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isFromPatient
                    ? const LinearGradient(
                        colors: [_C.sentBubble1, _C.sentBubble2],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isFromPatient ? null : _C.receivedBubble,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isFromPatient ? 18 : 4),
                  bottomRight: Radius.circular(isFromPatient ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.messageText,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isFromPatient
                      ? Colors.white
                      : _C.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(message.timestamp),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: _C.textMuted,
                  ),
                ),
                if (isFromPatient) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead
                        ? Icons.done_all_rounded
                        : Icons.done_rounded,
                    size: 13,
                    color: message.isRead ? _C.accent : _C.textMuted,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Input bar
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final VoidCallback? onSend;
  final bool isSending;

  const _InputBar({
    required this.controller,
    this.onSend,
    this.isSending = false,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) setState(() => _hasText = has);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: _C.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F4F8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: widget.controller,
                maxLines: null,
                enabled: widget.onSend != null,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: _C.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: widget.onSend != null
                      ? 'Type a message...'
                      : 'Chat not available yet',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: _C.textMuted,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                ),
                textInputAction: TextInputAction.newline,
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          AnimatedScale(
            scale: _hasText ? 1.0 : 0.85,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutBack,
            child: GestureDetector(
              onTap: _hasText && !widget.isSending ? widget.onSend : null,
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _hasText
                      ? const LinearGradient(
                          colors: [_C.primary, _C.accent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _hasText ? null : _C.textMuted.withOpacity(0.3),
                ),
                child: widget.isSending
                    ? const Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// State screens
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(
          color: _C.primary,
          strokeWidth: 2.5,
        ),
      );
}

class _WaitingView extends StatelessWidget {
  const _WaitingView();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  size: 42,
                  color: _C.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Waiting for Doctor',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your doctor will open the chat from\nthe appointment screen.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _C.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _C.primary.withOpacity(0.08),
                ),
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 42,
                  color: _C.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Start the Conversation',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Send a message to begin your\nconsultation session.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _C.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      );
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});
  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            message,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFFE05C5C),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
}