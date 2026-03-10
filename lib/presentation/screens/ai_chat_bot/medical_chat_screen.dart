import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/ai_chat_bloc.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/ai_chat_event.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/ai_chat_state.dart';
import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOUR PALETTE — derived from your AppColors theme
// Replace these with your actual AppColors references if you prefer.
// ─────────────────────────────────────────────────────────────────────────────
class _C {
  static const bg = Color(0xFF0D1B2A);           // deep navy — main background
  static const surface = Color(0xFF152536);       // card / bubble surface
  static const userBubble = Color(0xFF1A6EFF);    // brand blue for user messages
  static const aiBubble = Color(0xFF1E2F40);      // dark teal for AI messages
  static const accent = Color(0xFF37BBFF);        // light blue accent
  static const textPrimary = Color(0xFFEEF4FB);   // near-white text
  static const textSecondary = Color(0xFF7A94A8); // muted text / timestamps
  static const inputBg = Color(0xFF1A2B3C);       // text field background
  static const divider = Color(0xFF1E3245);       // border / divider
  static const errorBg = Color(0xFF2D1418);       // error bubble background
  static const errorText = Color(0xFFFF6B6B);     // error text
  static const shimmerBase = Color(0xFF1E3245);
  static const shimmerHighlight = Color(0xFF2A4A6A);
}

class MedicalChatScreen extends StatefulWidget {
  const MedicalChatScreen({super.key});

  @override
  State<MedicalChatScreen> createState() => _MedicalChatScreenState();
}

class _MedicalChatScreenState extends State<MedicalChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  final _imagePicker = ImagePicker();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _pickImage(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: _C.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ImageSourceSheet(
        onGallery: () async {
          Navigator.pop(context);
          final file = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 85,
            maxWidth: 1280,
          );
          if (file != null && context.mounted) {
            final bytes = await file.readAsBytes();
            context.read<MedicalChatBloc>().add(ImageAttachedEvent(bytes));
          }
        },
        onCamera: () async {
          Navigator.pop(context);
          final file = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 85,
            maxWidth: 1280,
          );
          if (file != null && context.mounted) {
            final bytes = await file.readAsBytes();
            context.read<MedicalChatBloc>().add(ImageAttachedEvent(bytes));
          }
        },
      ),
    );
  }

  void _sendMessage(BuildContext context) {
    final bloc = context.read<MedicalChatBloc>();
    final state = bloc.state;
    final text = _textController.text.trim();

    if (state.pendingImage != null) {
      bloc.add(SendMedicalImageEvent(
        imageBytes: state.pendingImage!,
        caption: text.isNotEmpty ? text : null,
      ));
    } else if (text.isNotEmpty) {
      bloc.add(SendMedicalTextEvent(text));
    } else {
      return;
    }

    _textController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.bg,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // ── Messages list ─────────────────────────────────────────────
          Expanded(
            child: BlocConsumer<MedicalChatBloc, MedicalChatState>(
              listener: (context, state) {
                if (state is MedicalChatLoaded || state is MedicalChatError) {
                  _scrollToBottom();
                }
              },
              builder: (context, state) {
                final messages = state.messages;
                final isLoading = state is MedicalChatLoading;

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isLoading && index == messages.length) {
                      return const _ThinkingBubble();
                    }
                    return _MessageBubble(
                      message: messages[index],
                      key: ValueKey(messages[index].id),
                    );
                  },
                );
              },
            ),
          ),

          // ── Pending image preview ─────────────────────────────────────
          BlocBuilder<MedicalChatBloc, MedicalChatState>(
            builder: (context, state) {
              if (state.pendingImage == null) return const SizedBox.shrink();
              return _PendingImagePreview(
                imageBytes: state.pendingImage!,
                onRemove: () =>
                    context.read<MedicalChatBloc>().add(const ImageRemovedEvent()),
              );
            },
          ),

          // ── Input bar ─────────────────────────────────────────────────
          BlocBuilder<MedicalChatBloc, MedicalChatState>(
            builder: (context, state) {
              final isLoading = state is MedicalChatLoading;
              final hasPendingImage = state.pendingImage != null;
              return _InputBar(
                controller: _textController,
                focusNode: _focusNode,
                isLoading: isLoading,
                hasPendingImage: hasPendingImage,
                onAttach: () => _pickImage(context),
                onSend: () => _sendMessage(context),
              );
            },
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _C.surface,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: _C.textPrimary, size: 20),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF1A6EFF), Color(0xFF37BBFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _C.accent.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Medical AI',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: 0.3,
                ),
              ),
              Row(
                children: [
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFF2ECC71)),
                  SizedBox(width: 5),
                  Text(
                    'Online',
                    style: TextStyle(
                      color: _C.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        BlocBuilder<MedicalChatBloc, MedicalChatState>(
          builder: (context, state) {
            if (state.messages.length <= 1) return const SizedBox.shrink();
            return IconButton(
              tooltip: 'Clear conversation',
              icon: const Icon(Icons.delete_outline_rounded,
                  color: _C.textSecondary, size: 22),
              onPressed: () => _showClearConfirm(context),
            );
          },
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _C.divider),
      ),
    );
  }

  void _showClearConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _C.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Clear conversation?',
            style: TextStyle(
                color: _C.textPrimary, fontWeight: FontWeight.w700)),
        content: const Text(
          'All messages will be deleted.',
          style: TextStyle(color: _C.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: _C.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              context
                  .read<MedicalChatBloc>()
                  .add(const ClearMedicalChatEvent());
              Navigator.pop(context);
            },
            child: const Text('Clear',
                style: TextStyle(
                    color: _C.errorText, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final MedicalChatMessage message;

  const _MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(
        left: isUser ? 56 : 0,
        right: isUser ? 0 : 56,
        bottom: 10,
      ),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isUser) _buildAiLabel(),
          const SizedBox(height: 4),
          _buildBubble(context),
          const SizedBox(height: 4),
          _buildTimestamp(),
        ],
      ),
    );
  }

  Widget _buildAiLabel() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF1A6EFF), Color(0xFF37BBFF)],
            ),
          ),
          child: const Icon(Icons.health_and_safety_rounded,
              color: Colors.white, size: 12),
        ),
        const SizedBox(width: 6),
        const Text(
          'MedBot',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _C.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildBubble(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78),
      decoration: BoxDecoration(
        color: message.isError
            ? _C.errorBg
            : message.isUser
                ? _C.userBubble
                : _C.aiBubble,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft:
              message.isUser ? const Radius.circular(20) : const Radius.circular(4),
          bottomRight:
              message.isUser ? const Radius.circular(4) : const Radius.circular(20),
        ),
        border: message.isError
            ? Border.all(color: _C.errorText.withOpacity(0.3))
            : message.isUser
                ? null
                : Border.all(color: _C.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image thumbnail
          if (message.hasImage)
            Stack(
              children: [
                Image.memory(
                  message.imageBytes!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 140,
                    color: _C.divider,
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: _C.textSecondary),
                    ),
                  ),
                ),
                // Gradient overlay at bottom of image
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.25),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

          // Error icon + text
          if (message.isError && message.hasText)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded,
                      color: _C.errorText, size: 16),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      message.text!,
                      style: const TextStyle(
                        color: _C.errorText,
                        fontSize: 14,
                        height: 1.45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )

          // Normal text
          else if (message.hasText)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: SelectableText(
                message.text!,
                style: TextStyle(
                  color: message.isUser
                      ? Colors.white
                      : _C.textPrimary,
                  fontSize: 14.5,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    if (message.timestamp == null) return const SizedBox.shrink();
    final h = message.timestamp!.hour.toString().padLeft(2, '0');
    final m = message.timestamp!.minute.toString().padLeft(2, '0');
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.hasImage)
          const Icon(Icons.image_outlined, size: 10, color: _C.textSecondary),
        if (message.hasImage) const SizedBox(width: 3),
        Text(
          '$h:$m',
          style: const TextStyle(
            fontSize: 10,
            color: _C.textSecondary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// THINKING / LOADING BUBBLE  (shimmer-style animated dots)
// ─────────────────────────────────────────────────────────────────────────────

class _ThinkingBubble extends StatefulWidget {
  const _ThinkingBubble();

  @override
  State<_ThinkingBubble> createState() => _ThinkingBubbleState();
}

class _ThinkingBubbleState extends State<_ThinkingBubble>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _anims;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _anims = _controllers
        .map((c) => Tween<double>(begin: 0, end: -7).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();
    _animate();
  }

  void _animate() async {
    while (mounted) {
      for (int i = 0; i < 3; i++) {
        if (!mounted) return;
        _controllers[i].forward();
        await Future.delayed(const Duration(milliseconds: 140));
      }
      await Future.delayed(const Duration(milliseconds: 300));
      for (final c in _controllers) {
        if (mounted) c.reverse();
      }
      await Future.delayed(const Duration(milliseconds: 350));
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(right: 8),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF1A6EFF), Color(0xFF37BBFF)],
              ),
            ),
            child: const Icon(Icons.health_and_safety_rounded,
                color: Colors.white, size: 12),
          ),
          // Bubble
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              color: _C.aiBubble,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: _C.divider),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _anims[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _anims[i].value),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _C.accent,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PENDING IMAGE PREVIEW STRIP
// ─────────────────────────────────────────────────────────────────────────────

class _PendingImagePreview extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onRemove;

  const _PendingImagePreview(
      {required this.imageBytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              imageBytes,
              height: 110,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: onRemove,
            child: Container(
              margin: const EdgeInsets.all(6),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.65),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
          // Badge
          Positioned(
            bottom: 7,
            left: 10,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, color: Colors.white, size: 11),
                  SizedBox(width: 4),
                  Text('Image attached',
                      style: TextStyle(color: Colors.white, fontSize: 11)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INPUT BAR
// ─────────────────────────────────────────────────────────────────────────────

class _InputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isLoading;
  final bool hasPendingImage;
  final VoidCallback onAttach;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.focusNode,
    required this.isLoading,
    required this.hasPendingImage,
    required this.onAttach,
    required this.onSend,
  });

  @override
  State<_InputBar> createState() => _InputBarState();
}

class _InputBarState extends State<_InputBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      final h = widget.controller.text.trim().isNotEmpty;
      if (h != _hasText) setState(() => _hasText = h);
    });
  }

  bool get _canSend => (_hasText || widget.hasPendingImage) && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _C.surface,
        border: const Border(top: BorderSide(color: _C.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ── Attach button ────────────────────────────────────────
              _CircleButton(
                onTap: widget.isLoading ? null : widget.onAttach,
                tooltip: 'Attach image',
                isActive: widget.hasPendingImage,
                child: Icon(
                  widget.hasPendingImage
                      ? Icons.image_rounded
                      : Icons.add_photo_alternate_outlined,
                  color: widget.hasPendingImage ? _C.accent : _C.textSecondary,
                  size: 20,
                ),
              ),

              const SizedBox(width: 8),

              // ── Text field ───────────────────────────────────────────
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    style: const TextStyle(
                      color: _C.textPrimary,
                      fontSize: 14.5,
                      height: 1.4,
                    ),
                    decoration: InputDecoration(
                      hintText: widget.hasPendingImage
                          ? 'Describe this image (optional)...'
                          : 'Ask a medical question...',
                      hintStyle: const TextStyle(
                        color: _C.textSecondary,
                        fontSize: 14,
                      ),
                      filled: true,
                      fillColor: _C.inputBg,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: _C.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: const BorderSide(color: _C.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide:
                            const BorderSide(color: _C.accent, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => widget.onSend(),
                    textInputAction: TextInputAction.newline,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── Send button ──────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _canSend
                      ? const LinearGradient(
                          colors: [Color(0xFF1A6EFF), Color(0xFF37BBFF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _canSend ? null : _C.divider,
                  boxShadow: _canSend
                      ? [
                          BoxShadow(
                            color: _C.accent.withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : null,
                ),
                child: Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _canSend ? widget.onSend : null,
                    child: Center(
                      child: widget.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _C.textSecondary,
                              ),
                            )
                          : const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// IMAGE SOURCE SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _ImageSourceSheet extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _ImageSourceSheet(
      {required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attach Medical Image',
            style: TextStyle(
              color: _C.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Upload a photo for AI medical analysis',
            style: TextStyle(color: _C.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _SheetTile(
            icon: Icons.photo_library_rounded,
            label: 'Choose from Gallery',
            onTap: onGallery,
          ),
          const SizedBox(height: 10),
          _SheetTile(
            icon: Icons.camera_alt_rounded,
            label: 'Take a Photo',
            onTap: onCamera,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _C.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A6EFF), Color(0xFF37BBFF)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Text(label,
                style: const TextStyle(
                    color: _C.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: _C.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE CIRCLE BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _CircleButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  final bool isActive;

  const _CircleButton({
    required this.child,
    this.onTap,
    this.tooltip,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? _C.accent.withOpacity(0.15) : _C.inputBg,
        border: Border.all(
          color: isActive ? _C.accent : _C.divider,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Center(child: child),
        ),
      ),
    );
  }
}