import 'package:flutter/material.dart';

class AddTokenScreen extends StatefulWidget {
  final void Function(Map<String, dynamic>)? onTokenAdded;

  const AddTokenScreen({super.key, this.onTokenAdded});

  @override
  State<AddTokenScreen> createState() => _AddTokenScreenState();
}

class _AddTokenScreenState extends State<AddTokenScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedNetwork;
  Map<String, String>? _selectedToken;

  final _contractController = TextEditingController();

  /// Реальные сети, как на биржах (код + описание)
  final List<Map<String, String>> _networks = [
    {'name': 'ERC20', 'full': 'Ethereum Network'},
    {'name': 'TRC20', 'full': 'Tron Network'},
    {'name': 'BEP20', 'full': 'BNB Smart Chain'},
    {'name': 'SOL', 'full': 'Solana Network'},
    {'name': 'TON', 'full': 'TON Network'},
  ];

  /// Топ-10 монет
  final List<Map<String, String>> _popularTokens = const [
    {'name': 'Bitcoin', 'symbol': 'BTC'},
    {'name': 'Ethereum', 'symbol': 'ETH'},
    {'name': 'Tether', 'symbol': 'USDT'},
    {'name': 'USD Coin', 'symbol': 'USDC'},
    {'name': 'BNB', 'symbol': 'BNB'},
    {'name': 'Solana', 'symbol': 'SOL'},
    {'name': 'XRP', 'symbol': 'XRP'},
    {'name': 'Toncoin', 'symbol': 'TON'},
    {'name': 'Dogecoin', 'symbol': 'DOGE'},
    {'name': 'TRON', 'symbol': 'TRX'},
  ];

  @override
  void dispose() {
    _contractController.dispose();
    super.dispose();
  }

  void _saveToken() {
    if (_selectedNetwork == null || _selectedToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выбери сеть и криптовалюту'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final newToken = <String, dynamic>{
      'name': _selectedToken!['name'],
      'symbol': _selectedToken!['symbol'],
      'network': _selectedNetwork!, // ERC20 / TRC20 / BEP20 / SOL / TON
      'balance': 0.0,
      'fiat': 0.0,
      'address': _contractController.text.trim(), // на будущее
    };

    if (widget.onTokenAdded != null) {
      widget.onTokenAdded!(newToken);
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pop(newToken);
    }
  }

  /// Модалка выбора сети с поиском
  Future<void> _openNetworkSelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF050816),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String query = '';
        List<Map<String, String>> filtered =
        List<Map<String, String>>.from(_networks);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void _updateFilter(String value) {
              setModalState(() {
                query = value.toLowerCase().trim();
                filtered = _networks.where((net) {
                  final text =
                  '${net['name']} ${net['full']}'.toLowerCase();
                  return text.contains(query);
                }).toList();
              });
            }

            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // полоска сверху
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Выбери сеть',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: _updateFilter,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        hintText: 'Поиск (ERC20, TRC20, Solana...)',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF111827),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF374151),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF374151),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Color(0xFF1F2937),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final net = filtered[index];
                          return ListTile(
                            title: Text(
                              net['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              net['full']!,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedNetwork = net['name']; // ERC20 и т.д.
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Модалка выбора монеты с поиском
  Future<void> _openTokenSelector() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF050816),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        String query = '';
        List<Map<String, String>> filtered =
        List<Map<String, String>>.from(_popularTokens);

        return StatefulBuilder(
          builder: (context, setModalState) {
            void _updateFilter(String value) {
              setModalState(() {
                query = value.toLowerCase().trim();
                filtered = _popularTokens.where((token) {
                  final name = token['name']!.toLowerCase();
                  final symbol = token['symbol']!.toLowerCase();
                  return name.contains(query) || symbol.contains(query);
                }).toList();
              });
            }

            return FractionallySizedBox(
              heightFactor: 0.8,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Text(
                      'Выбери монету',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      onChanged: _updateFilter,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.white54,
                        ),
                        hintText: 'Поиск (BTC, USDT, Toncoin...)',
                        hintStyle: const TextStyle(
                          color: Colors.white38,
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: const Color(0xFF111827),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF374151),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF374151),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(
                          color: Color(0xFF1F2937),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final token = filtered[index];
                          final name = token['name']!;
                          final symbol = token['symbol']!;
                          return ListTile(
                            title: Text(
                              '$name ($symbol)',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedToken = token;
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      appBar: AppBar(
        backgroundColor: const Color(0xFF050816),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Добавить токен',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Сеть',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _openNetworkSelector,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: _inputDecoration('Выберите сеть'),
                  child: Text(
                    _selectedNetwork ?? 'Выберите сеть',
                    style: TextStyle(
                      color: _selectedNetwork == null
                          ? Colors.white38
                          : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Криптовалюта',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _openTokenSelector,
                borderRadius: BorderRadius.circular(14),
                child: InputDecorator(
                  decoration: _inputDecoration('Выберите монету'),
                  child: Text(
                    _selectedToken == null
                        ? 'Выберите монету'
                        : '${_selectedToken!['name']} (${_selectedToken!['symbol']})',
                    style: TextStyle(
                      color: _selectedToken == null
                          ? Colors.white38
                          : Colors.white,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Технические данные (необязательно)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contractController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration('Адрес контракта / Mint'),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveToken,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Сохранить токен',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: const Color(0xFF111827),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF374151)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6366F1)),
      ),
    );
  }
}
