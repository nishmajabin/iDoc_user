// /// State for [SlotSelectionCubit].
// ///
// /// This cubit owns exactly one piece of UI-level state: whether Razorpay has
// /// been initialised yet.  All appointment/payment *business* state continues
// /// to live in [AppointmentBloc] and [PaymentBloc] respectively.
// ///
// /// Keeping the cubit state minimal means BlocBuilder rebuilds are essentially
// /// zero-cost — the cubit only emits twice per screen lifetime (init → ready).
// class SlotSelectionState {
//   /// True once [PaymentService.initializeRazorpay] has been called
//   /// successfully and the screen is safe to accept user interaction.
//   final bool isRazorpayInitialized;

//   const SlotSelectionState({this.isRazorpayInitialized = false});

//   SlotSelectionState copyWith({bool? isRazorpayInitialized}) =>
//       SlotSelectionState(
//         isRazorpayInitialized:
//             isRazorpayInitialized ?? this.isRazorpayInitialized,
//       );

//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is SlotSelectionState &&
//           other.isRazorpayInitialized == isRazorpayInitialized;

//   @override
//   int get hashCode => isRazorpayInitialized.hashCode;
// }