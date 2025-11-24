import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/p2p_create_offer_screen.dart';
import 'screens/p2p_deal_details_screen.dart';
import 'screens/p2p_deals_history_screen.dart';

class P2PScreen extends StatefulWidget {
  const P2PScreen({super.key});

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String _selectedSide = 'buy'; // buy = купить, sell = продать
  String _selectedAsset = 'USDT';
  String _selectedFiat = 'EUR';
  String _selectedPayment = 'Любой';
  String _fiatAmount = '';

  final List<String> _assets = ['USDT', 'BTC', 'ETH'];
  final List<String> _fiats = ['EUR', 'USD', 'UAH'];
  final List<String> _payments = ['Любой', 'SEPA', 'Revolut', 'Wise', 'Cash'];

  final List<Map<String, dynamic>> _market = [
    {
      'id': '1',
      'trader': 'R1_Trader_1',
      'success': 98,
      'deals': 324,
      'available': 1500.0,
      'min': 50.0,
      'max': 1000.0,
      'asset': 'USDT',
      'fiat': 'EUR',
      'price': 0.93,
      'payments': ['SEPA', 'Revolut', 'Wise'],
      'side': 'sell'
    },
    {
      'id': '2',
      'trader': 'EuroSwap',
      'success': 96,
      'deals': 812,
      'available': 5000.0,
      'min': 100.0,
      'max': 2000.0,
      'asset': 'USDT',
      'fiat': 'EUR',
      'price': 0.931,
      'payments': ['Bank Transfer', 'SEPA'],
      'side': 'sell'
    },
  ];

  final List<Map<String, dynamic>> _myOffers = [
    {
      'id': 'm1',
      'side': 'buy',
      'asset': 'USDT',
      'fiat': 'EUR',
      'price': 0.94,
      'available': 2000.0,
      'min': 100.0,
      'max': 1500.0,
      'payments': ['SEPA', 'Revolut'],
      'active': true,
    },
    {
      'id': 'm2',
      'side': 'sell',
      'asset': 'BTC',
      'fiat': 'EUR',
      'price': 65000,
      'available': 0.3,
      'min': 0.01,
      'max': 0.2,
      'payments': ['SEPA'],
      'active': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text("P2P"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const P2PDealsHistoryScreen(deals: []),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const P2PCreateOfferScreen(),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: "Витрина"),
            Tab(text: "Мои объявления"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMarketTab(),
          _buildMyOffersTab(),
        ],
      ),
    );
  }

  // --------------------- MARKET TAB ---------------------
  Widget _buildMarketTab() {
    return Column(
      children: [
        const SizedBox(height: 10),

        // BUY / SELL SWITCH
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _sideButton("Купить", "buy"),
            const SizedBox(width: 10),
            _sideButton("Продать", "sell"),
          ],
        ),
        const SizedBox(height: 12),

        // FILTERS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _dropdown(_assets, _selectedAsset, (v) => setState(() => _selectedAsset = v))),
                  const SizedBox(width: 12),
                  Expanded(child: _dropdown(_fiats, _selectedFiat, (v) => setState(() => _selectedFiat = v))),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _inputField(
                      "Например, 500",
                          (v) => setState(() => _fiatAmount = v),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown(_payments, _selectedPayment, (v) => setState(() => _selectedPayment = v)),
                  )
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _market.length,
            itemBuilder: (_, i) => _offerCard(_market[i]),
          ),
        ),
      ],
    );
  }

  Widget _sideButton(String text, String key) => Expanded(
    child: GestureDetector(
      onTap: () => setState(() => _selectedSide = key),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _selectedSide == key ? AppColors.accent : Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: _selectedSide == key ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
  );

  Widget _dropdown(List<String> items, String value, Function(String) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: AppColors.backgroundDark,
        underline: const SizedBox(),
        isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
        onChanged: (v) => onChange(v!),
        items: items.map((e) => DropdownMenuItem(
          value: e,
          child: Text(e, style: const TextStyle(color: Colors.white)),
        )).toList(),
      ),
    );
  }

  Widget _inputField(String hint, Function(String) onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: onChange,
        style: const TextStyle(color: Colors.white),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white38),
        ),
      ),
    );
  }

  Widget _offerCard(Map<String, dynamic> offer) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => P2PDealDetailsScreen(deal: offer),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white12,
                  child: Text(
                    offer['trader'][0],
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['trader'],
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        "${offer['deals']} сделок • ${offer['success']}% успеха",
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${offer['price']} ${offer['fiat']}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "1 ${offer['asset']} = ${offer['price']} ${offer['fiat']}",
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              "Доступно: ${offer['available']} ${offer['asset']}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              "Лимиты: ${offer['min']} – ${offer['max']} ${offer['fiat']}",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              children: offer['payments'].map<Widget>((p) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    p,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedSide == 'buy' ? "Купить ${offer['asset']}" : "Продать ${offer['asset']}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // ---------------- MY OFFERS -----------------
  Widget _buildMyOffersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _myOffers.length,
      itemBuilder: (_, i) => _myOfferCard(_myOffers[i]),
    );
  }

  Widget _myOfferCard(Map<String, dynamic> offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            offer['side'] == 'buy'
                ? "Ты покупаешь ${offer['asset']} за ${offer['fiat']}"
                : "Ты продаёшь ${offer['asset']} за ${offer['fiat']}",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text("Цена: ${offer['price']} ${offer['fiat']}", style: const TextStyle(color: Colors.white70)),
          Text("Доступно: ${offer['available']} ${offer['asset']}", style: const TextStyle(color: Colors.white70)),
          Text("Лимиты: ${offer['min']} – ${offer['max']} ${offer['fiat']}", style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: offer['payments']
                .map<Widget>((p) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(p, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              IconButton(
                icon: Icon(Icons.edit, color: Colors.white70),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {},
              )
            ],
          )
        ],
      ),
    );
  }
}
