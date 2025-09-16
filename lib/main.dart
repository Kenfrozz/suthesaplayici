import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const SutHesaplayiciApp());
}

class SutHesaplayiciApp extends StatelessWidget {
  const SutHesaplayiciApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Süt Hesaplayıcı',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const SutHesaplayiciHomePage(),
    );
  }
}

class SutHesaplayiciHomePage extends StatefulWidget {
  const SutHesaplayiciHomePage({super.key});

  @override
  State<SutHesaplayiciHomePage> createState() => _SutHesaplayiciHomePageState();
}

class _SutHesaplayiciHomePageState extends State<SutHesaplayiciHomePage> {
  final TextEditingController _inputController = TextEditingController();
  final DateTime _selectedDate = DateTime.now();
  final List<Map<String, dynamic>> _kayitlar = [];
  final List<Map<String, dynamic>> _odemeler = [];
  int _selectedTabIndex = 0;
  double _litreFiyati = 10.0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Verileri yükle
  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Süt kayıtlarını yükle
    final kayitlarJson = prefs.getString('kayitlar') ?? '[]';
    final kayitlarList = jsonDecode(kayitlarJson) as List;
    _kayitlar.clear();
    for (var item in kayitlarList) {
      _kayitlar.add({
        'tarih': DateTime.parse(item['tarih']),
        'miktar': item['miktar'],
        'toplamFiyat': item['toplamFiyat'],
      });
    }

    // Ödeme kayıtlarını yükle
    final odemelerJson = prefs.getString('odemeler') ?? '[]';
    final odemelerList = jsonDecode(odemelerJson) as List;
    _odemeler.clear();
    for (var item in odemelerList) {
      _odemeler.add({
        'tarih': DateTime.parse(item['tarih']),
        'miktar': item['miktar'],
      });
    }

    // Litre fiyatını yükle
    _litreFiyati = prefs.getDouble('litreFiyati') ?? 10.0;

    setState(() {});
  }

  // Verileri kaydet
  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Süt kayıtlarını kaydet
    final kayitlarJson = jsonEncode(_kayitlar.map((kayit) => {
      'tarih': kayit['tarih'].toIso8601String(),
      'miktar': kayit['miktar'],
      'toplamFiyat': kayit['toplamFiyat'],
    }).toList());
    await prefs.setString('kayitlar', kayitlarJson);

    // Ödeme kayıtlarını kaydet
    final odemelerJson = jsonEncode(_odemeler.map((odeme) => {
      'tarih': odeme['tarih'].toIso8601String(),
      'miktar': odeme['miktar'],
    }).toList());
    await prefs.setString('odemeler', odemelerJson);

    // Litre fiyatını kaydet
    await prefs.setDouble('litreFiyati', _litreFiyati);
  }

  void _sutMiktariSec(double miktar) {
    setState(() {
      _inputController.text = miktar.toString();
    });
  }

  Future<void> _kayitEkle() async {
    if (_inputController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir miktar girin!')),
      );
      return;
    }

    double miktar = double.tryParse(_inputController.text) ?? 0;
    double toplamFiyat = miktar * _litreFiyati;

    setState(() {
      _kayitlar.add({
        'tarih': _selectedDate,
        'miktar': miktar,
        'toplamFiyat': toplamFiyat,
      });
      _inputController.clear();
    });

    await _saveData();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt eklendi!')),
      );
    }
  }

  Widget _buildAnaSayfa() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Tarih gösterimi
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  'TARİH',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${_inputController.text.isEmpty ? "0" : _inputController.text} LİTRE',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_inputController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    '${((double.tryParse(_inputController.text) ?? 0) * _litreFiyati).toStringAsFixed(2)} TL',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Input alanı
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Input',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black, width: 2),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Hızlı seçim butonları
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.8, // Daha küçük boyut için oran
            children: [
              for (double miktar in [1, 2, 2.5, 3, 4, 5])
                GestureDetector(
                  onTap: () => _sutMiktariSec(miktar),
                  child: SizedBox(
                    height: 80,
                    child: Image.asset(
                      'assets/images/${miktar == 2.5 ? "2_5" : miktar.toInt()}L.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!, width: 1),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.local_drink,
                                size: 20,
                                color: Colors.blue,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$miktar L',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Kaydet butonu
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _kayitEkle,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.green, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'KAYDET',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKayitlar() {
    // Tüm kayıtları birleştir ve tarihe göre sırala
    List<Map<String, dynamic>> tumKayitlar = [];

    // Süt kayıtlarını ekle
    for (var kayit in _kayitlar) {
      tumKayitlar.add({
        'tip': 'sut',
        'tarih': kayit['tarih'],
        'miktar': kayit['miktar'],
        'toplamFiyat': kayit['toplamFiyat'],
      });
    }

    // Ödeme kayıtlarını ekle
    for (var odeme in _odemeler) {
      tumKayitlar.add({
        'tip': 'odeme',
        'tarih': odeme['tarih'],
        'miktar': odeme['miktar'],
      });
    }

    // Tarihe göre en yeniden en eskiye sırala
    tumKayitlar.sort((a, b) => (b['tarih'] as DateTime).compareTo(a['tarih'] as DateTime));

    return tumKayitlar.isEmpty
        ? const Center(
            child: Text(
              'Henüz kayıt yok',
              style: TextStyle(fontSize: 18),
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tumKayitlar.length,
            itemBuilder: (context, index) {
              final kayit = tumKayitlar[index];
              final tarih = kayit['tarih'] as DateTime;
              final isSutKayit = kayit['tip'] == 'sut';

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                color: isSutKayit ? null : Colors.green[50],
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isSutKayit ? Colors.blue : Colors.green,
                    child: Icon(
                      isSutKayit ? Icons.local_drink : Icons.payments,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    isSutKayit
                        ? '${kayit['miktar']} Litre - ${kayit['toplamFiyat'].toStringAsFixed(2)} TL'
                        : 'Ödeme: ${kayit['miktar'].toStringAsFixed(2)} TL',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${tarih.day}/${tarih.month}/${tarih.year} - ${tarih.hour.toString().padLeft(2, '0')}:${tarih.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: isSutKayit
                      ? const Icon(Icons.add, color: Colors.blue)
                      : const Icon(Icons.remove, color: Colors.green),
                ),
              );
            },
          );
  }

  Widget _buildHesaplama() {
    DateTime now = DateTime.now();
    DateTime oneWeekAgo = now.subtract(const Duration(days: 7));
    DateTime oneMonthAgo = DateTime(now.year, now.month - 1, now.day);

    // Son hafta toplam
    double haftalikToplam = _kayitlar
        .where((kayit) => (kayit['tarih'] as DateTime).isAfter(oneWeekAgo))
        .fold(0.0, (toplam, kayit) => toplam + kayit['toplamFiyat']);

    // Son ay toplam
    double aylikToplam = _kayitlar
        .where((kayit) => (kayit['tarih'] as DateTime).isAfter(oneMonthAgo))
        .fold(0.0, (toplam, kayit) => toplam + kayit['toplamFiyat']);

    // Toplam ödemeler
    double toplamOdemeler = _odemeler.fold(0.0, (toplam, odeme) => toplam + odeme['miktar']);

    // Bekleyen ödeme
    double bekleyenOdeme = aylikToplam - toplamOdemeler;

    final TextEditingController odemeController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hesaplama',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Son hafta kartı
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.date_range, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Son Hafta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${haftalikToplam.toStringAsFixed(2)} TL',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Son ay kartı
          Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Son Ay',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${aylikToplam.toStringAsFixed(2)} TL',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Bekleyen ödeme kartı
          Card(
            color: bekleyenOdeme > 0 ? Colors.orange[50] : Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        bekleyenOdeme > 0 ? Icons.pending_actions : Icons.check_circle,
                        color: bekleyenOdeme > 0 ? Colors.orange[700] : Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Bekleyen Ödeme',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: bekleyenOdeme > 0 ? Colors.orange[700] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${bekleyenOdeme.toStringAsFixed(2)} TL',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: bekleyenOdeme > 0 ? Colors.orange[700] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Ödeme ekleme
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ödeme Ekle',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: odemeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Ödeme Miktarı (TL)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.payments),
                      suffixText: 'TL',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (odemeController.text.isNotEmpty) {
                          double odemeMiktari = double.tryParse(odemeController.text) ?? 0;
                          if (odemeMiktari > 0) {
                            setState(() {
                              _odemeler.add({
                                'miktar': odemeMiktari,
                                'tarih': DateTime.now(),
                              });
                              odemeController.clear();
                            });

                            await _saveData();

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${odemeMiktari.toStringAsFixed(2)} TL ödeme eklendi!')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Ödeme Ekle',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAyarlar() {
    final TextEditingController fiyatController = TextEditingController(
      text: _litreFiyati.toString(),
    );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ayarlar',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1 Litre Süt Fiyatı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: fiyatController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Fiyat (TL)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      suffixText: 'TL',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _litreFiyati = double.tryParse(fiyatController.text) ?? 10.0;
                        });

                        await _saveData();

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fiyat güncellendi!')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Kaydet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[400]!),
            ),
            child: Column(
              children: [
                const Icon(Icons.info_outline, size: 32, color: Colors.blue),
                const SizedBox(height: 8),
                Text(
                  'Güncel fiyat: ${_litreFiyati.toStringAsFixed(2)} TL/Litre',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 0 ? Colors.black : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(6),
                            bottomLeft: Radius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Ana sayfa',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTabIndex == 0 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 1 ? Colors.black : Colors.transparent,
                        ),
                        child: Text(
                          'Kayıtlar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTabIndex == 1 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 2 ? Colors.black : Colors.transparent,
                        ),
                        child: Text(
                          'Hesaplama',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTabIndex == 2 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedTabIndex = 3),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _selectedTabIndex == 3 ? Colors.black : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(6),
                            bottomRight: Radius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Ayarlar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _selectedTabIndex == 3 ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _selectedTabIndex == 0
                  ? _buildAnaSayfa()
                  : _selectedTabIndex == 1
                      ? _buildKayitlar()
                      : _selectedTabIndex == 2
                          ? _buildHesaplama()
                          : _buildAyarlar(),
            ),
          ],
        ),
      ),
    );
  }
}