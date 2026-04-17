import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/services/payment_service.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_bloc.dart';
import 'package:idoc_user/logic/blocs/appointment/appointment_event.dart';
import 'package:idoc_user/logic/blocs/payment/payment_bloc.dart';
import 'package:idoc_user/logic/blocs/payment/payment_event.dart';

/// Owns every side-effect that was previously inside
/// [_SlotSelectionScreenState.initState] and [dispose]:
///
///  1. Fetches all slots for the given doctor (replaces the
///     [FetchAllAvailableSlotsEvent] call in initState).
///  2. Initialises the Razorpay SDK and wires its callbacks to
///     [PaymentBloc] (replaces the [_paymentBloc.paymentService.initializeRazorpay]
///     call in initState).
///  3. Disposes the Razorpay instance automatically when the BlocProvider
///     removes this Cubit from the tree (replaces the [dispose] override).
///
/// The widget tree stays purely declarative — no [StatefulWidget] needed.
class SlotCubit extends Cubit<SlotCubitState> {
  final PaymentService _paymentService;
  final PaymentBloc _paymentBloc;
  final AppointmentBloc _appointmentBloc;
  final String _doctorId;

  SlotCubit({
    required PaymentService paymentService,
    required PaymentBloc paymentBloc,
    required AppointmentBloc appointmentBloc,
    required String doctorId,
  })  : _paymentService = paymentService,
        _paymentBloc = paymentBloc,
        _appointmentBloc = appointmentBloc,
        _doctorId = doctorId,
        super(const SlotCubitInitial());

  /// Call once from [BlocProvider.create].
  /// Mirrors the original [initState] body exactly.
  void initialize() {
    // 1️⃣  Trigger the initial slot fetch (was the first call in initState).
    _appointmentBloc.add(FetchAllAvailableSlotsEvent(doctorId: _doctorId));

    // 2️⃣  Wire Razorpay callbacks → PaymentBloc events
    //     (was the second call in initState).
    _paymentService.initializeRazorpay(
      onSuccess: (response) {
        _paymentBloc.add(
          PaymentSuccessEvent(
            paymentId: response.paymentId ?? '',
            orderId: response.orderId ?? '',
            signature: response.signature ?? '',
          ),
        );
      },
      onFailure: (response) {
        _paymentBloc.add(
          PaymentFailureEvent(
            code: response.code ?? 0,
            message: response.message ?? 'Payment failed',
          ),
        );
      },
      onCancel: () => _paymentBloc.add(const PaymentCancelledEvent()),
    );

    emit(const SlotCubitReady());
  }

  /// Automatically called by [BlocProvider] when the screen leaves the tree.
  /// Mirrors the original [dispose] override.
  @override
  Future<void> close() {
    _paymentService.dispose();
    return super.close();
  }
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class SlotCubitState {
  const SlotCubitState();
}

/// Initial state before [SlotCubit.initialize] is called.
class SlotCubitInitial extends SlotCubitState {
  const SlotCubitInitial();
}

/// Razorpay is initialised and slots are being fetched.
/// The screen is fully ready for user interaction.
class SlotCubitReady extends SlotCubitState {
  const SlotCubitReady();
}
