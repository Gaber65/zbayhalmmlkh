/// App-level payment status. Named [AppPaymentStatus] to avoid conflict
/// with the Moyasar SDK's own [PaymentStatus] export.
enum AppPaymentStatus { paid, failed, cancelled, pending }
