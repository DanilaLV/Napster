import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../data/models/settings.dart';
import '../../shared/providers.dart';

class IapService {
  IapService(this.ref);

  final Ref ref;
  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  ProductDetails? _productDetails;
  bool _isAvailable = false;
  bool _isOwned = false;
  bool _initialised = false;

  static const _productId = 'napster_pro_unlock';

  bool get isOwned => _isOwned;
  bool get isAvailable => _isAvailable;
  ProductDetails? get product => _productDetails;

  Future<void> initialize() async {
    if (_initialised) return;
    _isAvailable = await _iap.isAvailable();
    if (!_isAvailable) {
      _initialised = true;
      return;
    }
    final purchaseStream = _iap.purchaseStream;
    _subscription = purchaseStream.listen(_onPurchaseUpdated);
    await _queryProducts();
    await _restorePastPurchases();
    _initialised = true;
  }

  Future<void> _queryProducts() async {
    final response = await _iap.queryProductDetails({_productId});
    if (response.error != null) {
      debugPrint('IAP error: ${response.error}');
      return;
    }
    if (response.productDetails.isNotEmpty) {
      _productDetails = response.productDetails.first;
    }
  }

  Future<void> _restorePastPurchases() async {
    final query = await _iap.queryPastPurchases();
    for (final purchase in query.pastPurchases) {
      if (purchase.productID == _productId) {
        await _verifyAndComplete(purchase);
        _isOwned = true;
        await ref.read(settingsProvider.notifier).setProUnlocked(true);
      }
    }
  }

  Future<void> buy() async {
    final product = _productDetails;
    if (product == null) return;
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchases) {
    for (final purchase in purchases) {
      if (purchase.productID != _productId) {
        continue;
      }
      switch (purchase.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndComplete(purchase);
          _isOwned = true;
          ref.read(settingsProvider.notifier).setProUnlocked(true);
          break;
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          break;
      }
    }
  }

  Future<void> _verifyAndComplete(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) {
      return;
    }
    await _iap.completePurchase(purchase);
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
  }
}

final iapServiceProvider = Provider<IapService>((ref) {
  final service = IapService(ref);
  ref.onDispose(service.dispose);
  return service;
});
