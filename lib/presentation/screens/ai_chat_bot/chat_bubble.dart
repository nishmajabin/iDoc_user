// import 'package:flutter/material.dart';
// import 'package:idoc_user/core/constants/color.dart';
// import 'package:idoc_user/presentation/screens/ai_chat_bot/chat_message.dart';
// import 'typing_indicator.dart';

// class ChatBubble extends StatelessWidget {
//   final MedicalChatMessage message;
//   final bool isStreaming;

//   const ChatBubble({
//     super.key,
//     required this.message,
//     this.isStreaming = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(
//         left: message.isUser ? 60 : 16,
//         right: message.isUser ? 16 : 60,
//         top: 4,
//         bottom: 4,
//       ),
//       child: Column(
//         crossAxisAlignment:
//             message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           if (!message.isUser) _buildAiLabel(),
//           const SizedBox(height: 4),
//           _buildBubble(context),
//           const SizedBox(height: 4),
//           _buildTimestamp(),
//         ],
//       ),
//     );
//   }

//   Widget _buildAiLabel() {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 24,
//           height: 24,
//           decoration:  BoxDecoration(
//             shape: BoxShape.circle,
//             color: AppColors.primaryColor,
//           ),
//           child: const Icon(
//             Icons.medical_services_rounded,
//             color: Colors.white,
//             size: 13,
//           ),
//         ),
//         const SizedBox(width: 6),
//          Text(
//           'MedBot',
//           style: TextStyle(
//             fontSize: 11,
//             fontWeight: FontWeight.w600,
//             color: AppColors.skipColor,
//             letterSpacing: 0.3,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildBubble(BuildContext context) {
//     final isAiEmpty = message.isAssistant && message.content.isEmpty;
//     final hasImage = message.hasImage;

//     return Container(
//       constraints: BoxConstraints(
//         maxWidth: MediaQuery.of(context).size.width * 0.75,
//       ),
//       decoration: BoxDecoration(
//         color: message.isError
//             ? AppColors.errorBubble
//             : message.isUser
//                 ? AppColors.userBubble
//                 : AppColors.aiBubble,
//         borderRadius: BorderRadius.only(
//           topLeft: const Radius.circular(20),
//           topRight: const Radius.circular(20),
//           bottomLeft: message.isUser
//               ? const Radius.circular(20)
//               : const Radius.circular(4),
//           bottomRight: message.isUser
//               ? const Radius.circular(4)
//               : const Radius.circular(20),
//         ),
//         border: message.isError
//             ? Border.all(color: AppColors.errorText.withOpacity(0.3), width: 1)
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // ── Image thumbnail ───────────────────────────────────────────
//           if (hasImage) _ImageThumbnail(imageBytes: message.imageBytes!),

//           // ── Error content ─────────────────────────────────────────────
//           if (message.isError)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Icon(
//                     Icons.error_outline_rounded,
//                     color: AppColors.errorText,
//                     size: 16,
//                   ),
//                   const SizedBox(width: 8),
//                   Flexible(
//                     child: Text(
//                       message.content,
//                       style: const TextStyle(
//                         fontSize: 14,
//                         height: 1.4,
//                         color: AppColors.errorText,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             )
//           // ── Typing indicator (empty AI bubble while streaming) ────────
//           else if (isAiEmpty && isStreaming)
//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: TypingIndicator(),
//             )
//           // ── Normal text content ───────────────────────────────────────
//           else if (message.content.isNotEmpty)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//               child: SelectableText(
//                 message.content,
//                 style: TextStyle(
//                   fontSize: 15,
//                   height: 1.45,
//                   color: message.isUser
//                       ? AppColors.userBubbleText
//                       : AppColors.aiBubbleText,
//                   fontWeight: FontWeight.w400,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTimestamp() {
//     final hour = message.timestamp.hour.toString().padLeft(2, '0');
//     final minute = message.timestamp.minute.toString().padLeft(2, '0');
//     final hasImg = message.hasImage && message.content.isEmpty;
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         if (hasImg)
//            Icon(Icons.image_outlined, size: 11, color: AppColors.skipColor),
//         if (hasImg) const SizedBox(width: 3),
//         Text(
//           '$hour:$minute',
//           style:  TextStyle(
//             fontSize: 10,
//             color: AppColors.timestampColor,
//             letterSpacing: 0.2,
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ── Internal image thumbnail widget ──────────────────────────────────────────

// class _ImageThumbnail extends StatelessWidget {
//   final dynamic imageBytes; // Uint8List

//   const _ImageThumbnail({required this.imageBytes});

//   @override
//   Widget build(BuildContext context) {
//     return Stack(
//       children: [
//         Image.memory(
//           imageBytes,
//           width: double.infinity,
//           fit: BoxFit.cover,
//           errorBuilder: (_, __, ___) => Container(
//             height: 120,
//             color: AppColors.dividerColor,
//             child:  Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 color: AppColors.skipColor,
//               ),
//             ),
//           ),
//         ),
//         // Subtle gradient overlay at the bottom so text on top is readable
//         Positioned(
//           bottom: 0,
//           left: 0,
//           right: 0,
//           child: Container(
//             height: 32,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Colors.transparent,
//                   Colors.black.withOpacity(0.18),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }