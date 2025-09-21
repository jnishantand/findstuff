import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;



class PaymentPage extends StatefulWidget {
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  Future<void> makePayment() async {
    try {
      // 1️⃣ Ask your backend to create a PaymentIntent
      final response = await http.post(
          Uri.parse("http://192.168.1.2:3000/create-payment-intent") // replace with your backend URL
      );

      final data = jsonDecode(response.body);

      // 2️⃣ Init payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data["clientSecret"],
          merchantDisplayName: "Test Shop",
        ),
      );

      // 3️⃣ Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Payment Successful ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Stripe Test Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: makePayment,
          child: Text("Pay \$10"),
        ),
      ),
    );
  }
}
// app.post("/create-payment-intent", async (req, res) => {
// try {
// const paymentIntent = await stripe.paymentIntents.create({
// amount: 1000, // = $10.00
// currency: "usd",
// payment_method_types: ["card"],
// });
// res.json({ clientSecret: paymentIntent.client_secret });
// } catch (err) {
// res.status(500).json({ error: err.message });
// }
// });
//
// // Start server
// app.listen(3000, "0.0.0.0", () => console.log("Server running on port 3000"));

