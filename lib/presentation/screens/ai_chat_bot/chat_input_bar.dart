import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:idoc_user/core/constants/color.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputBar extends StatefulWidget {
  final void Function(String message, {Uint8List? imageBytes}) onSend;
  final bool isLoading;

  /// Currently pending image (managed by BLoC, passed in for display)
  final Uint8List? pendingImage;

  /// Called when user taps × to remove the pending image
  final VoidCallback? onImageRemoved;

  const ChatInputBar({
    super.key,
    required this.onSend,
    this.isLoading = false,
    this.pendingImage,
    this.onImageRemoved,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _picker = ImagePicker();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final has = _controller.text.trim().isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  bool get _canSend =>
      (_hasText || widget.pendingImage != null) && !widget.isLoading;

  void _send() {
    if (!_canSend) return;
    final text = _controller.text.trim();
    // Allow sending image without text — use a default prompt in that case
    final effectiveText =
        text.isNotEmpty ? text : 'Please analyze this medical image.';
    widget.onSend(effectiveText, imageBytes: widget.pendingImage);
    _controller.clear();
    _focusNode.requestFocus();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      // Bubble image bytes up so BLoC stores them in state
      widget.onSend('__IMAGE_SELECTED__', imageBytes: bytes);
    } catch (_) {
      // Permission denied or picker cancelled — ignore silently
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Text(
                'Attach Image',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
               Text(
                'Upload a medical image for AI analysis',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.skipColor,
                ),
              ),
              const SizedBox(height: 20),
              _SourceTile(
                icon: Icons.photo_library_rounded,
                label: 'Choose from Gallery',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              _SourceTile(
                icon: Icons.camera_alt_rounded,
                label: 'Take a Photo',
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Pending image preview strip ─────────────────────────────
            if (widget.pendingImage != null)
              _ImagePreviewStrip(
                imageBytes: widget.pendingImage!,
                onRemove: widget.onImageRemoved,
              ),

            // ── Input row ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Image attach button
                  _AttachButton(
                    onTap: widget.isLoading ? null : _showImageSourceSheet,
                    hasImage: widget.pendingImage != null,
                  ),

                  const SizedBox(width: 8),

                  // Text field
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      decoration: BoxDecoration(
                        color: AppColors.bgColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.dividerColor,
                          width: 1.5,
                        ),
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        style:  TextStyle(
                          fontSize: 15,
                          color: AppColors.labelTextColor,
                          height: 1.4,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.pendingImage != null
                              ? 'Ask about this image...'
                              : 'Ask me about your health...',
                          hintStyle:  TextStyle(
                            color: AppColors.skipColor,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _send(),
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Send button
                  _SendButton(
                    canSend: _canSend,
                    isLoading: widget.isLoading,
                    onTap: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _ImagePreviewStrip extends StatelessWidget {
  final dynamic imageBytes;
  final VoidCallback? onRemove;

  const _ImagePreviewStrip({required this.imageBytes, this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Stack(
        alignment: Alignment.topRight,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.memory(
              imageBytes,
              height: 120,
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
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black54,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ),
          // Label badge
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, color: Colors.white, size: 12),
                  SizedBox(width: 4),
                  Text(
                    'Image attached',
                    style: TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool hasImage;

  const _AttachButton({this.onTap, required this.hasImage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hasImage
              ? AppColors.accent.withOpacity(0.15)
              : AppColors.bgColor,
          border: Border.all(
            color: hasImage ? AppColors.accent : AppColors.dividerColor,
            width: 1.5,
          ),
        ),
        child: Icon(
          hasImage ? Icons.image_rounded : Icons.add_photo_alternate_outlined,
          color: hasImage ? AppColors.accent : AppColors.skipColor,
          size: 20,
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool canSend;
  final bool isLoading;
  final VoidCallback onTap;

  const _SendButton({
    required this.canSend,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: canSend ? AppColors.primaryColor : AppColors.dividerColor,
        boxShadow: canSend
            ? [
                BoxShadow(
                  color: AppColors.primaryColor.withOpacity(0.35),
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
          onTap: canSend ? onTap : null,
          child: Center(
            child: isLoading
                ?  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.skipColor,
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
    );
  }
}

class _SourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.dividerColor),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.primaryColor, size: 22),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style:  TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.labelTextColor,
              ),
            ),
            const Spacer(),
             Icon(
              Icons.chevron_right_rounded,
              color: AppColors.skipColor,
            ),
          ],
        ),
      ),
    );
  }
}