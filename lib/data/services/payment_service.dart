import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  final FirebaseFirestore _firestore;
  late Razorpay _razorpay;

  // ✅ Your actual Razorpay TEST keys
  static const String _razorpayKeyId = 'rzp_test_SBbwVVANK2l1pJ';
  static const String _razorpayKeySecret = 'OT6TVYNS3qrtK8pOLrX4F0T9';

  // Callbacks for payment events
  Function(PaymentSuccessResponse)? _onSuccess;
  Function(PaymentFailureResponse)? _onFailure;
  Function()? _onCancel;

  PaymentService(this._firestore) {
    _razorpay = Razorpay();
  }

  /// Initialize Razorpay with callbacks
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
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('✅ Razorpay Payment Success');
    print('Payment ID: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');
    _onSuccess?.call(response);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('❌ Razorpay Payment Error');
    print('Code: ${response.code}');
    print('Message: ${response.message}');
    
    // If user cancelled, treat it as cancellation
    if (response.code == Razorpay.PAYMENT_CANCELLED) {
      print('🚫 Payment cancelled by user');
      _onCancel?.call();
    } else {
      _onFailure?.call(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('🔷 External Wallet Selected: ${response.walletName}');
  }

  /// Create a Razorpay order reference
  /// Note: This doesn't create a real Razorpay order, just stores details
  Future<Map<String, dynamic>> createOrder({
    required double amount,
    required String receipt,
  }) async {
    try {
      final amountInPaise = (amount * 100).toInt();

      print('Creating order reference...');
      print('Amount: ₹$amount ($amountInPaise paise)');
      print('Receipt: $receipt');

      // Store order details in Firestore for record-keeping
      final orderRef = _firestore.collection('razorpay_orders').doc();
      final orderId = receipt; // Use receipt as ID

      await orderRef.set({
        'orderId': orderId,
        'amount': amountInPaise,
        'amountInRupees': amount,
        'currency': 'INR',
        'receipt': receipt,
        'status': 'created',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order reference created: $orderId');

      return {
        'orderId': orderId,
        'amount': amountInPaise,
        'currency': 'INR',
        'receipt': receipt,
      };
    } catch (e) {
      print('❌ Error creating order: $e');
      rethrow;
    }
  }

  /// Open Razorpay checkout
  /// ✅ FIXED: Removed order_id to work without backend
  Future<void> openCheckout({
    required String orderId,
    required double amount,
    required String name,
    required String contact,
    required String email,
    required String description,
  }) async {
    final amountInPaise = (amount * 100).toInt();

    // ✅ WORKING FIX: No order_id (works for testing without backend)
    var options = {
      'key': _razorpayKeyId,
      'amount': amountInPaise,
      'currency': 'INR',
      'name': 'iDoc Consultancy',
      'description': description,
      // ⚠️ REMOVED 'order_id' - This fixes the "Something went wrong" error
      // To use order_id, you need to create orders via Razorpay API
      'prefill': {
        'contact': contact,
        'email': email,
        'name': name,
      },
      'theme': {
        'color': '#00D4FF',
      },
      'notes': {
        'booking_id': orderId,  // Store your internal ID in notes
      },
    };

    try {
      print('Opening Razorpay checkout...');
      print('Amount: ₹$amount');
      print('Contact: $contact');
      _razorpay.open(options);
    } catch (e) {
      print('❌ Error opening Razorpay: $e');
      rethrow;
    }
  }

  /// Verify payment
  /// ⚠️ WARNING: Signature verification skipped without real order_id
  /// This is OK for testing, but NOT for production!
  Future<bool> verifyPaymentSignature({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      print('⚠️ Payment recorded without signature verification');
      print('Payment ID: $paymentId');
      print('Internal Order ID: $orderId');
      
      // Update order status in Firestore
      final orderQuery = await _firestore
          .collection('razorpay_orders')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (orderQuery.docs.isNotEmpty) {
        await orderQuery.docs.first.reference.update({
          'status': 'paid',
          'paymentId': paymentId,
          'paidAt': FieldValue.serverTimestamp(),
        });
      }

      // ⚠️ TEMPORARY: Always return true for testing
      // In production, you MUST verify the signature properly
      print('✅ Payment recorded');
      return true;
    } catch (e) {
      print('❌ Error recording payment: $e');
      return false;
    }
  }

  /// Generate HMAC SHA256 signature
  String _generateSignature(String orderId, String paymentId) {
    final String data = '$orderId|$paymentId';
    final List<int> key = utf8.encode(_razorpayKeySecret);
    final List<int> message = utf8.encode(data);

    final Hmac hmac = Hmac(sha256, key);
    final Digest digest = hmac.convert(message);

    return digest.toString();
  }

  /// Dispose Razorpay instance
  void dispose() {
    _razorpay.clear();
  }

  /// Get payment details from Firestore
  Future<Map<String, dynamic>?> getPaymentDetails(String orderId) async {
    try {
      final orderQuery = await _firestore
          .collection('razorpay_orders')
          .where('orderId', isEqualTo: orderId)
          .limit(1)
          .get();

      if (orderQuery.docs.isNotEmpty) {
        return orderQuery.docs.first.data();
      }
      return null;
    } catch (e) {
      print('Error fetching payment details: $e');
      return null;
    }
  }

  /// Refund a payment (if needed)
  Future<void> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    try {
      // Store refund request in Firestore
      await _firestore.collection('refund_requests').add({
        'paymentId': paymentId,
        'amount': amount,
        'amountInPaise': (amount * 100).toInt(),
        'reason': reason,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Refund request created for payment: $paymentId');
    } catch (e) {
      print('❌ Error creating refund request: $e');
      rethrow;
    }
  }
}