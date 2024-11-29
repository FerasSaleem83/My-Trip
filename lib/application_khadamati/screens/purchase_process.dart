// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_trip/style/appbar.dart';

class PurchaseProcess extends StatefulWidget {
  final List<Map<String, dynamic>> selectedProducts;
  final String storeName;
  final String currentStoreId;
  final double deliveryFee;
  final double tax;
  final double tip;
  final double support;

  const PurchaseProcess({
    super.key,
    required this.selectedProducts,
    this.deliveryFee = 1.0,
    this.tax = 0.0,
    this.tip = 0.25,
    this.support = 0.25,
    required this.storeName,
    required this.currentStoreId,
  });

  @override
  State<PurchaseProcess> createState() => _PurchaseProcessState();
}

class _PurchaseProcessState extends State<PurchaseProcess> {
  String selectedPaymentMethod = 'choose_payment_method'.tr();
  String userId = FirebaseAuth.instance.currentUser!.uid;

  void _showPaymentMethodSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.grey,
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedPaymentMethod = 'upon_delivery'.tr();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: const Icon(
                Icons.handshake,
                color: Colors.black,
              ),
              label: Text('upon_delivery'.tr(),
                  style: const TextStyle(
                    color: Colors.black,
                  )),
            ),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  selectedPaymentMethod = 'pay_online'.tr();
                });
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              icon: const Icon(
                Icons.wallet,
                color: Colors.black,
              ),
              label: Text(
                'pay_online'.tr(),
                style: const TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendOrder() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('information')
        .doc(userId)
        .get();

    double wallet = userDoc['wallet'].toDouble() ?? 0.0;

    double finalPrice = widget.selectedProducts.fold(
            0.0, (double sum, item) => sum + item['price'] * item['quantity']) +
        widget.deliveryFee +
        widget.tax +
        widget.tip +
        widget.support;

    if (finalPrice > wallet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'the_wallet_balance_is_not_sufficient_to_complete_the_purchase'
                  .tr()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> products = widget.selectedProducts
        .map((product) => {
              'name': product['name'],
              'quantity': product['quantity'],
              'price': product['price'],
              'total_price': product['price'] * product['quantity'],
              'image_url': product['image'],
            })
        .toList();

    List<String> productImages = widget.selectedProducts
        .map((product) => product['image'] as String)
        .toList();

    Map<String, dynamic> orderData = {
      'activate': true,
      'store_name': widget.storeName,
      'delivery_fee': widget.deliveryFee,
      'tax': widget.tax,
      'tip': widget.tip,
      'support': widget.support,
      'payment_method': selectedPaymentMethod,
      'total_price':
          products.fold(0.0, (double sum, item) => sum + item['total_price']),
      'final_price': finalPrice,
      'order_time': DateTime.now(),
      'products': products,
      'store_id': widget.currentStoreId,
      'images': productImages,
      'driverLongitude': 0,
      'driverLatitude': 0,
    };

    try {
      DocumentReference orderRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('my_orders')
          .add(orderData);

      await orderRef.update({'order_id': orderRef.id});

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('information')
          .doc(userId)
          .set(
        {
          'order_online': true,
          'wallet': FieldValue.increment(-finalPrice),
          'point': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('the_request_has_been_sent_successfully'.tr()),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'something_went_wrong'.tr()}: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = widget.selectedProducts.fold(
        0,
        (double sum, product) =>
            sum + (product['price'] * product['quantity']));
    double finalPrice = totalPrice +
        widget.deliveryFee +
        widget.tax +
        widget.tip +
        widget.support;

    return Scaffold(
      appBar: StyleAppBarKhdamati(
          title: Image.asset(
        'assets/image/khdamati-logo.png',
        height: 50,
      )),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Expanded(
              child: Card(
                shape: Border.all(
                  width: 4,
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'invoice'.tr(),
                        style: const TextStyle(fontSize: 25),
                      ),
                      const Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        thickness: 3.0,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text('${'timing'.tr()}: ${DateTime.now()}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                    '${'restaurant_name'.tr()}: ${widget.storeName}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Text('number'.tr())),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          flex: 2,
                                          child: Text('product_name'.tr())),
                                      const SizedBox(width: 5),
                                      Expanded(child: Text('quantity'.tr())),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          flex: 2, child: Text('price'.tr())),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 2,
                                        child: Text('total_price'.tr()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Card(
                            child: ListView.builder(
                              itemCount: widget.selectedProducts.length,
                              itemBuilder: (context, index) {
                                final product = widget.selectedProducts[index];
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                          width: 50,
                                          child: Text('${index + 1}')),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          flex: 2,
                                          child: Text(product['name'])),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          child: Text(
                                        ' ${product['quantity']}',
                                      )),
                                      const SizedBox(width: 5),
                                      Expanded(
                                          flex: 2,
                                          child: Text(
                                              '${(product['price']).toStringAsFixed(2)} ${'currency'.tr()}')),
                                      const SizedBox(width: 5),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                            ' ${(product['price'] * product['quantity']).toStringAsFixed(2)} ${'currency'.tr()}'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${'payment_method'.tr()}: ',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          selectedPaymentMethod ==
                                                  'choose_payment_method'.tr()
                                              ? TextButton(
                                                  onPressed: () {
                                                    _showPaymentMethodSnackBar(
                                                        context);
                                                  },
                                                  child: Text(
                                                      selectedPaymentMethod),
                                                )
                                              : Row(
                                                  children: [
                                                    IconButton(
                                                      icon: Image.asset(
                                                        'assets/image/edit.png',
                                                        width: 25,
                                                        height: 25,
                                                      ),
                                                      onPressed: () {
                                                        _showPaymentMethodSnackBar(
                                                            context);
                                                      },
                                                    ),
                                                    Text(
                                                      selectedPaymentMethod,
                                                      style: const TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              child: Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${'total_price'.tr()}: ',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            '${totalPrice.toStringAsFixed(2)} ${'currency'.tr()}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${'delivery_fees'.tr()}: ',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            '${widget.deliveryFee.toStringAsFixed(2)} ${'currency'.tr()}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${'tax'.tr()}: ',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            '${widget.tax.toStringAsFixed(2)} ${'currency'.tr()}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${'gratuity'.tr()}: ',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            '${widget.tip.toStringAsFixed(2)} ${'currency'.tr()}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${'support_tourism'.tr()}: ',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                          ),
                                          Text(
                                            '${widget.support.toStringAsFixed(2)} ${'currency'.tr()}',
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                            '${'final_total'.tr()}: ${finalPrice.toStringAsFixed(2)} ${'currency'.tr()}',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _sendOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('complete_the_purchase'.tr()),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
