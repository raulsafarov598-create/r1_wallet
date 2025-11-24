import 'package:flutter/material.dart';
import '../theme.dart';

/// ===== МОДЕЛИ И ДЕМО-ДАННЫЕ ===============================================

class P2PAd {
  final String id;
  final bool isBuyAd; // true = объявление "Куплю USDT", false = "Продам USDT"
  final String traderName;
  final int dealsCount;
  final int successPercent;
  final double availableAmount; // в USDT
  final double price; // цена за 1 USDT в фиате
  final double minLimit; // в фиате (EUR)
  final double maxLimit; // в фиате (EUR)
  final List<String> payments;
  final String asset;
  final String fiat;
  final bool isMine;

  const P2PAd({
    required this.id,
    required this.isBuyAd,
    required this.traderName,
    required this.dealsCount,
    required this.successPercent,
    required this.availableAmount,
    required this.price,
    required this.minLimit,
    required this.maxLimit,
    required this.payments,
    this.asset = 'USDT',
    this.fiat = 'EUR',
    this.isMine = false,
  });
}

class P2PDeal {
  final String id;
  final P2PAd ad;
  final bool iSellCrypto; // true = я продаю крипту, false = я покупаю крипту
  final double fiatAmount;
  final double cryptoAmount;
  final String paymentMethod;
  String status; // Создана / Оплачено / Завершено / Отменена
  final DateTime createdAt;

  P2PDeal({
    required this.id,
    required this.ad,
    required this.iSellCrypto,
    required this.fiatAmount,
    required this.cryptoAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
  });
}

// Демонстрационные объявления (как на скринах)
final List<P2PAd> _demoAds = [
  P2PAd(
    id: 'ad1',
    isBuyAd: true, // трейдер покупает USDT, пользователь продаёт
    traderName: 'R1_Trader_1',
    dealsCount: 324,
    successPercent: 98,
    availableAmount: 1500,
    price: 0.93,
    minLimit: 50,
    maxLimit: 1000,
    payments: ['SEPA', 'Revolut', 'Wise'],
  ),
  P2PAd(
    id: 'ad2',
    isBuyAd: true,
    traderName: 'EuroSwap',
    dealsCount: 812,
    successPercent: 96,
    availableAmount: 5000,
    price: 0.931,
    minLimit: 100,
    maxLimit: 2000,
    payments: ['Bank Transfer', 'SEPA'],
  ),
  // Пара своих объявлений для вкладки "Мои объявления"
  P2PAd(
    id: 'my1',
    isBuyAd: false,
    traderName: 'R1_Exchange',
    dealsCount: 120,
    successPercent: 99,
    availableAmount: 3000,
    price: 0.945,
    minLimit: 100,
    maxLimit: 1000,
    payments: ['SEPA'],
    isMine: true,
  ),
  P2PAd(
    id: 'my2',
    isBuyAd: true,
    traderName: 'R1_Exchange',
    dealsCount: 120,
    successPercent: 99,
    availableAmount: 2000,
    price: 0.93,
    minLimit: 50,
    maxLimit: 300,
    payments: ['Revolut'],
    isMine: true,
  ),
];

// История сделок хранится в памяти пока живёт приложение
final List<P2PDeal> _demoDeals = [];

/// ===== ГЛАВНЫЙ ЭКРАН P2P ===================================================

class P2PScreen extends StatefulWidget {
  const P2PScreen({Key? key}) : super(key: key);

  @override
  State<P2PScreen> createState() => _P2PScreenState();
}

class _P2PScreenState extends State<P2PScreen> with TickerProviderStateMixin {
  late TabController _rootTabs; // Витрина / Мои объявления
  bool _buyMode = true; // true = "Купить" (я покупаю USDT), false = "Продать"
  String _selectedAsset = 'USDT';
  String _selectedFiat = 'EUR';
  String _paymentFilter = 'Любой';

  final List<String> _assets = ['USDT', 'BTC', 'ETH'];
  final List<String> _fiats = ['EUR', 'USD', 'UAH', 'PLN'];
  final List<String> _allPayments = [
    'Любой',
    'SEPA',
    'Revolut',
    'Wise',
    'Bank Transfer',
    'Cash'
  ];

  @override
  void initState() {
    super.initState();
    _rootTabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _rootTabs.dispose();
    super.dispose();
  }

  List<P2PAd> _filteredMarketAds() {
    return _demoAds.where((ad) {
      if (ad.isMine) return false; // на витрине только чужие

      // фильтр по типу сделки
      if (_buyMode) {
        // я хочу КУПИТЬ USDT -> мне нужны объявления, где трейдер ПРОДАЁТ
        if (!ad.isBuyAd) {
          // на самом деле это наоборот, но в демо оставим так, чтобы
          // кнопка была "Продать USDT", как на скрине
        }
      } else {
        // я хочу ПРОДАТЬ USDT -> мне нужны объявления, где трейдер ПОКУПАЕТ
        // (в демо не заморачиваемся, просто показываем те же)
      }

      if (ad.asset != _selectedAsset) return false;
      if (ad.fiat != _selectedFiat) return false;
      if (_paymentFilter != 'Любой' && !ad.payments.contains(_paymentFilter)) {
        return false;
      }
      return true;
    }).toList();
  }

  List<P2PAd> _myAds() {
    return _demoAds.where((ad) => ad.isMine).toList();
  }

  void _openDealHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const P2PDealsHistoryScreen(),
      ),
    );
  }

  void _openCreateAd() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const P2PCreateAdScreen(),
      ),
    );
  }

  void _openOffer(P2PAd ad) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => P2POfferTakeScreen(
          ad: ad,
          buyMode: _buyMode,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ads = _filteredMarketAds();
    final myAds = _myAds();

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('P2P'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Мои сделки',
            icon: const Icon(Icons.history),
            onPressed: _openDealHistory,
          ),
          IconButton(
            tooltip: 'Создать объявление',
            icon: const Icon(Icons.add_circle_outline),
            onPressed: _openCreateAd,
          ),
        ],
        bottom: TabBar(
          controller: _rootTabs,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Витрина'),
            Tab(text: 'Мои объявления'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _rootTabs,
        children: [
          // ===== ВИТРИНА ====================================================
          Column(
            children: [
              const SizedBox(height: 8),
              _buildBuySellToggle(),
              const SizedBox(height: 12),
              _buildFilters(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'Результаты',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const Spacer(),
                    Text(
                      '${ads.length} оффер(ов)',
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: ads.length,
                  itemBuilder: (context, index) {
                    final ad = ads[index];
                    return _buildAdCard(ad, onTap: () => _openOffer(ad));
                  },
                ),
              ),
            ],
          ),

          // ===== МОИ ОБЪЯВЛЕНИЯ ============================================
          ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myAds.length,
            itemBuilder: (context, index) {
              final ad = myAds[index];
              return _buildMyAdCard(ad);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBuySellToggle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _buyMode = true);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: _buyMode ? AppColors.accent : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Купить',
                    style: TextStyle(
                      color: _buyMode ? Colors.white : Colors.white70,
                      fontWeight:
                          _buyMode ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() => _buyMode = false);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    color: !_buyMode ? AppColors.accent : Colors.transparent,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Продать',
                    style: TextStyle(
                      color: !_buyMode ? Colors.white : Colors.white70,
                      fontWeight:
                          !_buyMode ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Актив',
                  value: _selectedAsset,
                  items: _assets,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedAsset = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdown(
                  label: 'Фиат',
                  value: _selectedFiat,
                  items: _fiats,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedFiat = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDropdown(
            label: 'Оплата',
            value: _paymentFilter,
            items: _allPayments,
            onChanged: (v) {
              if (v == null) return;
              setState(() => _paymentFilter = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surfaceDark,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdCard(P2PAd ad, {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.surfaceDark,
                child: Text(
                  ad.traderName.isNotEmpty ? ad.traderName[0] : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.traderName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${ad.dealsCount} сделок · ${ad.successPercent}% успеха',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Доступно: ${ad.availableAmount.toStringAsFixed(2)} ${ad.asset}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Лимиты: ${ad.minLimit.toStringAsFixed(2)} – ${ad.maxLimit.toStringAsFixed(2)} ${ad.fiat}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: ad.payments
                          .map(
                            (p) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceDark,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                p,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${ad.price.toStringAsFixed(3)} ${ad.fiat}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: onTap,
                    child: Text(
                      _buyMode ? 'Продать ${ad.asset}' : 'Купить ${ad.asset}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMyAdCard(P2PAd ad) {
    final bool active = true; // в демо всегда активно
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ad.isBuyAd ? 'ПОКУПАЮ ${ad.asset}' : 'ПРОДАЮ ${ad.asset}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Цена: ${ad.price.toStringAsFixed(3)} ${ad.fiat} за 1 ${ad.asset}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Лимиты: ${ad.minLimit.toStringAsFixed(0)} – ${ad.maxLimit.toStringAsFixed(0)} ${ad.fiat}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            'Оплата: ${ad.payments.join(', ')}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: active ? Colors.green.shade700 : Colors.orange.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                active ? 'Активно' : 'Выключено',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===== ЭКРАН ВЗЯТИЯ ОФФЕРА ================================================

class P2POfferTakeScreen extends StatefulWidget {
  final P2PAd ad;
  final bool buyMode; // true = на главном экране был режим "Купить"

  const P2POfferTakeScreen({
    Key? key,
    required this.ad,
    required this.buyMode,
  }) : super(key: key);

  @override
  State<P2POfferTakeScreen> createState() => _P2POfferTakeScreenState();
}

class _P2POfferTakeScreenState extends State<P2POfferTakeScreen> {
  final TextEditingController _fiatController = TextEditingController();
  double _fiatValue = 0;
  double _cryptoValue = 0;

  @override
  void dispose() {
    _fiatController.dispose();
    super.dispose();
  }

  void _onFiatChanged(String v) {
    final parsed = double.tryParse(v.replaceAll(',', '.')) ?? 0;
    setState(() {
      _fiatValue = parsed;
      _cryptoValue =
          widget.ad.price > 0 ? parsed / widget.ad.price : 0;
    });
  }

  void _confirm() {
    if (_fiatValue <= 0) return;

    final deal = P2PDeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ad: widget.ad,
      iSellCrypto: widget.buyMode, // если я выбирал "Купить", то продавец я
      fiatAmount: _fiatValue,
      cryptoAmount: _cryptoValue,
      paymentMethod:
          widget.ad.payments.isNotEmpty ? widget.ad.payments.first : 'SEPA',
      status: 'Создана',
      createdAt: DateTime.now(),
    );

    _demoDeals.insert(0, deal);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => P2PDealScreen(deal: deal),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ad = widget.ad;
    final title = widget.buyMode ? 'Продать ${ad.asset}' : 'Купить ${ad.asset}';

    final withinLimits =
        _fiatValue >= ad.minLimit && _fiatValue <= ad.maxLimit;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: Text(title),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdHeader(ad),
            const SizedBox(height: 24),
            const Text(
              'Сумма сделки',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _fiatController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Введите сумму в EUR',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                ),
                onChanged: _onFiatChanged,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Минимум: ${ad.minLimit.toStringAsFixed(2)} ${ad.fiat} · Максимум: ${ad.maxLimit.toStringAsFixed(2)} ${ad.fiat}',
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 24),
            const Text(
              'Итог сделки',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(14),
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  _buildSummaryRow(
                    'Ты платишь',
                    '${_fiatValue.toStringAsFixed(2)} ${ad.fiat}',
                  ),
                  const Divider(color: Colors.white12),
                  _buildSummaryRow(
                    'Ты получаешь',
                    '${_cryptoValue.toStringAsFixed(6)} ${ad.asset}',
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Комиссии, точная сумма и реквизиты будут показаны на шаге подтверждения.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: withinLimits && _fiatValue > 0
                      ? AppColors.accent
                      : Colors.grey.shade700,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: withinLimits && _fiatValue > 0 ? _confirm : null,
                child: Text(
                  'Подтвердить: $title',
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdHeader(P2PAd ad) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.surfaceDark,
            child: Text(
              ad.traderName.isNotEmpty ? ad.traderName[0] : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ad.traderName,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  '${ad.dealsCount} сделок · ${ad.successPercent}% успеха',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'Доступно: ${ad.availableAmount.toStringAsFixed(2)} ${ad.asset}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Лимиты: ${ad.minLimit.toStringAsFixed(2)} – ${ad.maxLimit.toStringAsFixed(2)} ${ad.fiat}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: ad.payments
                      .map(
                        (p) => Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            p,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${ad.price.toStringAsFixed(3)} ${ad.fiat}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                '1 ${ad.asset} = ${ad.price.toStringAsFixed(3)} ${ad.fiat}',
                style:
                    const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ],
    );
  }
}

/// ===== ЭКРАН ДЕТАЛЕЙ СДЕЛКИ + РЕКВИЗИТЫ ====================================

class P2PDealScreen extends StatefulWidget {
  final P2PDeal deal;

  const P2PDealScreen({Key? key, required this.deal}) : super(key: key);

  @override
  State<P2PDealScreen> createState() => _P2PDealScreenState();
}

class _P2PDealScreenState extends State<P2PDealScreen> {
  void _setStatus(String s) {
    setState(() {
      widget.deal.status = s;
    });
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Создана':
        return Colors.orange;
      case 'Оплачено':
        return Colors.blueAccent;
      case 'Завершено':
        return Colors.green;
      case 'Отменена':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.deal;
    final ad = d.ad;

    final title = d.iSellCrypto ? 'Ты продаёшь ${ad.asset}' : 'Ты покупаешь ${ad.asset}';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Сделка P2P'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // шапка сделки
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Контрагент: ${ad.traderName}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Сумма: ${d.fiatAmount.toStringAsFixed(2)} ${ad.fiat} · ${d.cryptoAmount.toStringAsFixed(6)} ${ad.asset}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    'Цена: ${ad.price.toStringAsFixed(3)} ${ad.fiat} за 1 ${ad.asset}',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${d.createdAt.day.toString().padLeft(2, '0')}.${d.createdAt.month.toString().padLeft(2, '0')} · '
                    '${d.createdAt.hour.toString().padLeft(2, '0')}:${d.createdAt.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                        color: Colors.white60, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: ad.payments
                        .map(
                          (p) => Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 11),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor(d.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        d.status,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 11),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Реквизиты для оплаты',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Способ оплаты: ${d.paymentMethod}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Получатель: R1 Exchange OÜ\n'
                    'IBAN: BE12 3456 7890 1234\n'
                    'BIC: KREDBEBB\n'
                    'Назначение: P2P 1763843585045',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'В реальном приложении здесь будут твои настоящие реквизиты (IBAN / карта / Revolut и т.д.).',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _setStatus('Оплачено'),
                child: const Text('Я оплатил'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () => _setStatus('Отменена'),
                child: const Text('Отменить сделку'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ===== ЭКРАН ИСТОРИИ СДЕЛОК ===============================================

class P2PDealsHistoryScreen extends StatelessWidget {
  const P2PDealsHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Мои сделки P2P'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _demoDeals.length,
        itemBuilder: (context, index) {
          final d = _demoDeals[index];
          final ad = d.ad;
          final title =
              d.iSellCrypto ? 'Ты продаёшь ${ad.asset}' : 'Ты покупаешь ${ad.asset}';
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Контрагент: ${ad.traderName}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Сумма: ${d.fiatAmount.toStringAsFixed(2)} ${ad.fiat} · ${d.cryptoAmount.toStringAsFixed(6)} ${ad.asset}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  'Цена: ${ad.price.toStringAsFixed(3)} ${ad.fiat} за 1 ${ad.asset}',
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '${d.createdAt.day.toString().padLeft(2, '0')}.${d.createdAt.month.toString().padLeft(2, '0')} · '
                  '${d.createdAt.hour.toString().padLeft(2, '0')}:${d.createdAt.minute.toString().padLeft(2, '0')}',
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 11),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Завершено',
                      style:
                          TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ===== ЭКРАН СОЗДАНИЯ ОБЪЯВЛЕНИЯ ==========================================

class P2PCreateAdScreen extends StatefulWidget {
  const P2PCreateAdScreen({Key? key}) : super(key: key);

  @override
  State<P2PCreateAdScreen> createState() => _P2PCreateAdScreenState();
}

class _P2PCreateAdScreenState extends State<P2PCreateAdScreen> {
  bool _buyAd = true;
  String _asset = 'USDT';
  String _fiat = 'EUR';
  double _price = 0.95;
  double _available = 1000;
  double _min = 50;
  double _max = 1500;
  final Set<String> _payments = {'SEPA', 'Revolut'};
  bool _active = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        title: const Text('Создать объявление'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSegmentButton(
                  label: 'Купить',
                  selected: _buyAd,
                  onTap: () => setState(() => _buyAd = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSegmentButton(
                  label: 'Продать',
                  selected: !_buyAd,
                  onTap: () => setState(() => _buyAd = false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownSimple(
                  label: 'Крипто актив',
                  value: _asset,
                  items: const ['USDT', 'BTC', 'ETH'],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _asset = v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownSimple(
                  label: 'Фиат',
                  value: _fiat,
                  items: const ['EUR', 'USD', 'UAH', 'PLN'],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _fiat = v);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNumberField(
            label: 'Цена за 1 $_asset ($_fiat)',
            hint: 'Например, 0.95',
            initial: _price,
            onChanged: (v) =>
                setState(() => _price = v),
          ),
          const SizedBox(height: 12),
          _buildNumberField(
            label: 'Доступно ($_asset)',
            hint: 'Например, 1000',
            initial: _available,
            onChanged: (v) =>
                setState(() => _available = v),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildNumberField(
                  label: 'Минимум ($_fiat)',
                  hint: 'Например, 50',
                  initial: _min,
                  onChanged: (v) =>
                      setState(() => _min = v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildNumberField(
                  label: 'Максимум ($_fiat)',
                  hint: 'Например, 1500',
                  initial: _max,
                  onChanged: (v) =>
                      setState(() => _max = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Способы оплаты',
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildPaymentChip('SEPA'),
              _buildPaymentChip('Bank Transfer'),
              _buildPaymentChip('Revolut'),
              _buildPaymentChip('Wise'),
              _buildPaymentChip('Cash'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Switch(
                value: _active,
                activeColor: AppColors.accent,
                onChanged: (v) => setState(() => _active = v),
              ),
              const SizedBox(width: 8),
              const Text(
                'Активное объявление',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                // В демо просто закрываем экран
                Navigator.of(context).pop();
              },
              child: const Text('Создать объявление'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(40),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSimple({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.surfaceDark,
              iconEnabledColor: Colors.white70,
              style: const TextStyle(color: Colors.white),
              items: items
                  .map(
                    (e) => DropdownMenuItem(
                      value: e,
                      child: Text(e),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required String hint,
    required double initial,
    required ValueChanged<double> onChanged,
  }) {
    final controller =
        TextEditingController(text: initial.toString());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.white54),
              border: InputBorder.none,
            ),
            onChanged: (v) {
              final parsed = double.tryParse(v.replaceAll(',', '.')) ?? 0;
              onChanged(parsed);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentChip(String label) {
    final selected = _payments.contains(label);
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          if (selected) {
            _payments.remove(label);
          } else {
            _payments.add(label);
          }
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              selected ? AppColors.accent : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

