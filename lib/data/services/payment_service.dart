import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  final FirebaseFirestore _firestore;
  late final Razorpay _razorpay = Razorpay();

  static const _keyId = 'rzp_test_SBbwVVANK2l1pJ';
  static const _keySecret = 'OT6TVYNS3qrtK8pOLrX4F0T9';

  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function()? _onCancel;

  PaymentService(this._firestore);

  void initializeRazorpay({
    required Function(PaymentSuccessResponse) onSuccess,
    required Function(PaymentFailureResponse) onFailure,
    required Function() onCancel,
  }) {
    _onSuccess = onSuccess;
    _onFailure = onFailure;
    _onCancel = onCancel;
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (_) {});
  }

  void _handlePaymentSuccess(PaymentSuccessResponse r) => _onSuccess?.call(r);

  void _handlePaymentError(PaymentFailureResponse r) =>
      r.code == Razorpay.PAYMENT_CANCELLED ? _onCancel?.call() : _onFailure?.call(r);

  static int _toPaise(double amount) => (amount * 100).toInt();

  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String receipt,
  }) async {
    final paise = _toPaise(amount);
    await _firestore.collection('razorpay_orders').doc().set({
      'orderId': receipt,
      'amount': paise,
      'amountInRupees': amount,
      'currency': 'INR',
      'receipt': receipt,
      'status': 'created',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return {'orderId': receipt, 'amount': paise, 'currency': 'INR', 'receipt': receipt};
  }

  Future<void> openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String contact,
    required String email,
    required String description,
  }) async {
    _razorpay.open({
      'key': _keyId,
      'amount': _toPaise(amount),
      'currency': 'INR',
      'name': 'iDoc Consultancy',
      'description': description,
      'prefill': {'contact': contact, 'email': email, 'name': name},
      'theme': {'color': '#00D4FF'},
      'notes': {'booking_id': orderId},
    });
  }


  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final query = await _firestore.collection('razorpay_orders')
          .where('orderId', isEqualTo: orderId).limit(1).get();
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.update({
          'status': 'paid',
          'paymentId': paymentId,
          'paidAt': FieldValue.serverTimestamp(),
        });
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  String generateSignature(String orderId, String paymentId) =>
      Hmac(sha256, utf8.encode(_keySecret))
          .convert(utf8.encode('$orderId|$paymentId'))
          .toString();

  Future<Map<String, dynamic>?> getPaymentDetails(String orderId) async {
    try {
      final query = await _firestore.collection('razorpay_orders')
          .where('orderId', isEqualTo: orderId).limit(1).get();
      return query.docs.isNotEmpty ? query.docs.first.data() : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) =>
      _firestore.collection('refund_requests').add({
        'paymentId': paymentId,
        'amount': amount,
        'amountInPaise': _toPaise(amount),
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

  void dispose() => _razorpay.clear();
}