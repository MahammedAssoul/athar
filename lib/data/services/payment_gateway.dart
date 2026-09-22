/// Payment result from a payment gateway.
class PaymentResult {
  const PaymentResult({required this.success, required this.reference});

  final bool success;

  /// Unique transaction reference issued by the gateway/backend.
  final String reference;
}

/// Payment gateway abstraction.
///
/// The UI never talks to a specific provider — it only depends on this
/// interface. Switching providers (e.g. a Libyan payment provider) is a
/// matter of swapping the implementation in `AppDependencies`.
///
/// SECURITY: implementations must never store card numbers, CVV or PIN,
/// and must never log sensitive payment information.
abstract class PaymentGateway {
  /// Processes a payment for [amount] using [method].
  ///
  /// [method] is a provider-agnostic identifier (e.g. `card`,
  /// `applePay`, `bankTransfer`). Returns a [PaymentResult] with a
  /// unique transaction reference on success.
  Future<PaymentResult> pay({required double amount, required String method});
}

/// Mock payment gateway used when `isMock == true`.
///
/// Simulates processing time and can produce success or failure for
/// demo purposes. Never touches real payment data.
class MockPaymentGateway implements PaymentGateway {
  const MockPaymentGateway();

  /// Simulates a payment. Set [shouldFail] to simulate failure.
  Future<PaymentResult> processPayment({
    required double amount,
    required String method,
    bool shouldFail = false,
  }) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    if (shouldFail) {
      return const PaymentResult(success: false, reference: '');
    }
    return PaymentResult(
      success: true,
      reference: 'ATH-${DateTime.now().millisecondsSinceEpoch}',
    );
  }

  @override
  Future<PaymentResult> pay({required double amount, required String method}) {
    // Simulate occasional failure for demo purposes (1 in 5 attempts).
    final shouldFail = amount.round() % 5 == 4;
    return processPayment(
      amount: amount,
      method: method,
      shouldFail: shouldFail,
    );
  }
}

/// Real payment gateway used when `isMock == false`.
///
/// Phase 4: delegates to the backend payment endpoint. The backend is
/// responsible for talking to the actual payment provider available in
/// Libya. This class never sees or stores card details.
class RealPaymentGateway implements PaymentGateway {
  const RealPaymentGateway();

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String method,
  }) async {
    // Phase 4: call the backend payment endpoint via ApiClient.
    // The backend returns a unique transaction reference.
    throw UnimplementedError(
      'RealPaymentGateway requires a backend payment endpoint. '
      'Set isMock = true to use the mock gateway.',
    );
  }
}
