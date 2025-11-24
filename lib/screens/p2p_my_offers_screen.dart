import 'package:flutter/material.dart';

class P2PMyOffersScreen extends StatefulWidget {
  const P2PMyOffersScreen({super.key});

  @override
  State<P2PMyOffersScreen> createState() => _P2PMyOffersScreenState();
}

class _P2PMyOffersScreenState extends State<P2PMyOffersScreen> {
  List<Map<String, dynamic>> myOffers = [
    {
      "id": "offer_001",
      "type": "buy",
      "asset": "USDT",
      "fiat": "EUR",
      "price": 0.93,
      "limits": "100 – 1500 EUR",
      "active": true,
      "payment": "SEPA",
    },
    {
      "id": "offer_002",
      "type": "sell",
      "asset": "USDT",
      "fiat": "EUR",
      "price": 0.945,
      "limits": "50 – 400 EUR",
      "active": false,
      "payment": "Revolut",
    }
  ];

  void toggleOffer(String id) {
    setState(() {
      final index = myOffers.indexWhere((o) => o["id"] == id);
      myOffers[index]["active"] = !myOffers[index]["active"];
    });
  }

  void deleteOffer(String id) {
    setState(() {
      myOffers.removeWhere((o) => o["id"] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Мои объявления"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/createOffer');
            },
          )
        ],
      ),
      body: myOffers.isEmpty
          ? const Center(
              child: Text(
                "У вас нет объявлений",
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            )
          : ListView.builder(
              itemCount: myOffers.length,
              itemBuilder: (context, index) {
                final offer = myOffers[index];
                final isActive = offer["active"] == true;

                return Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${offer["type"] == "buy" ? "КУПЛЮ" : "ПРОДАМ"} ${offer["asset"]}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Цена: ${offer["price"]} ${offer["fiat"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Лимиты: ${offer["limits"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        "Оплата: ${offer["payment"]}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          // ON/OFF
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => toggleOffer(offer["id"]),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    isActive ? Colors.orange : Colors.green,
                              ),
                              child: Text(
                                isActive ? "Выключить" : "Включить",
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // DELETE
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => deleteOffer(offer["id"]),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text(
                                "Удалить",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                );
              },
            ),
    );
  }
}

