import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shamsi_date/shamsi_date.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JavidRealEstateApp());
}

class JavidRealEstateApp extends StatelessWidget {
  const JavidRealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'املاک جاوید',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        primaryColor: const Color(0xFF1E3A5F),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
      ),
      home: const LoginScreen(),
    );
  }
}

// ------------------ مدل‌های داده ------------------
class Property {
  String id;
  String ownerName;
  String ownerPhone;
  String ownerAddress;
  String dealType;
  String propertyType;
  String address;
  String area;
  String rooms;
  String yearBuilt;
  String floor;
  String totalPrice;
  String pricePerMeter;
  String deposit;
  String rent;
  String notes; // <-- فیلد توضیحات اضافه شد
  bool isContracted;
  String tenantName;
  String startDate;
  String endDate;

  Property({
    required this.id,
    required this.ownerName,
    required this.ownerPhone,
    required this.ownerAddress,
    required this.dealType,
    required this.propertyType,
    required this.address,
    required this.area,
    required this.rooms,
    required this.yearBuilt,
    required this.floor,
    required this.totalPrice,
    required this.pricePerMeter,
    required this.deposit,
    required this.rent,
    this.notes = '', // <-- مقدار پیش‌فرض
    this.isContracted = false,
    this.tenantName = '',
    this.startDate = '',
    this.endDate = '',
  });
}

class Applicant {
  String id;
  String name;
  String phone;
  String requestType; // خرید، فروش، اجاره
  String propertyType;
  String area;
  String deposit;
  String rent;
  String price;
  String region;
  String address;
  String propDetails;
  String notes; // <-- فیلد توضیحات اضافه شد
  bool isContracted;

  Applicant({
    required this.id,
    required this.name,
    required this.phone,
    required this.requestType,
    required this.propertyType,
    required this.area,
    this.deposit = '',
    this.rent = '',
    this.price = '',
    this.region = '',
    this.address = '',
    this.propDetails = '',
    this.notes = '', // <-- مقدار پیش‌فرض
    this.isContracted = false,
  });
}

// لیست‌های سراسری برای ذخیره اطلاعات در حافظه (موقت)
List<Property> properties = [];
List<Applicant> applicants = [];

// ------------------ ۱. صفحه ورود ------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    if (_passwordController.text == '1234') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز عبور اشتباه است!'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.home_work, size: 100, color: Color(0xFF1E3A5F)),
                const SizedBox(height: 20),
                const Text('املاک جاوید', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
                const SizedBox(height: 40),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'رمز عبور را وارد کنید',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
                    onPressed: _login,
                    child: const Text('ورود به برنامه', style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ ۲. داشبورد اصلی ------------------
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});
  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('املاک جاوید', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1E3A5F),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: [
            PropertiesListScreen(onRefresh: _refresh),
            ApplicantsListScreen(onRefresh: _refresh),
            ContractsListScreen(onRefresh: _refresh),
            PropertyFormScreen(onRefresh: _refresh, onBack: () => setState(() => _currentIndex = 0)),
            ApplicantFormScreen(onRefresh: _refresh, onBack: () => setState(() => _currentIndex = 1)),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF1E3A5F),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'املاک'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'خواهان‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'قراردادها'),
            BottomNavigationBarItem(icon: Icon(Icons.add_home), label: 'ثبت ملک'),
            BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'ثبت خواهان'),
          ],
        ),
      ),
    );
  }
}

// ------------------ ۳. لیست املاک (با نمایش توضیحات در جزئیات) ------------------
class PropertiesListScreen extends StatelessWidget {
  final VoidCallback onRefresh;
  const PropertiesListScreen({super.key, required this.onRefresh});

  void _showDetails(BuildContext context, Property p) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(p.dealType + ' - ' + p.propertyType),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('مالک: ${p.ownerName} - ${p.ownerPhone}'),
              Text('آدرس: ${p.address}'),
              Text('متراژ: ${p.area} - خواب: ${p.rooms} - سال ساخت: ${p.yearBuilt} - طبقه: ${p.floor}'),
              if (p.dealType == 'اجاره') Text('رهن: ${p.deposit} | اجاره: ${p.rent}'),
              if (p.dealType != 'اجاره') Text('قیمت کل: ${p.totalPrice} | قیمت متری: ${p.pricePerMeter}'),
              if (p.notes.isNotEmpty) ...[
                const Divider(),
                const Text('توضیحات:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(p.notes),
              ],
              if (p.isContracted) ...[
                const Divider(),
                Text('مستاجر/خریدار: ${p.tenantName}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                Text('شروع: ${p.startDate} - پایان: ${p.endDate}'),
              ]
            ],
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('بستن'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Property>> grouped = {'اجاره': [], 'فروش': [], 'پیش‌فروش': []};
    for (var p in properties) {
      if (grouped.containsKey(p.dealType)) {
        grouped[p.dealType]!.add(p);
      } else {
        grouped[p.dealType] = [p];
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((entry) {
        if (entry.value.isEmpty) return const SizedBox();
        return ExpansionTile(
          title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          initiallyExpanded: true,
          children: entry.value.map((p) {
            Color borderColor = p.isContracted ? Colors.green : Colors.red;
            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: borderColor, width: 2),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: ListTile(
                onTap: () => _showDetails(context, p),
                title: Text('${p.propertyType} - ${p.address}'),
                subtitle: Text(p.isContracted 
                  ? '${p.ownerName} و ${p.tenantName} - $p.startDate تا $p.endDate' 
                  : 'مالک: ${p.ownerName} (قرارداد بسته نشده)'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    properties.remove(p);
                    onRefresh();
                  },
                ),
              ),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// ------------------ ۴. لیست خواهان‌ها (نمایش توضیحات) ------------------
class ApplicantsListScreen extends StatelessWidget {
  final VoidCallback onRefresh;
  const ApplicantsListScreen({super.key, required this.onRefresh});

  void _contractDialog(BuildContext context, Applicant a) {
    final TextEditingController dateStart = TextEditingController();
    final TextEditingController dateEnd = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ثبت به عنوان قرارداد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: dateStart, decoration: const InputDecoration(labelText: 'تاریخ شروع')),
            TextField(controller: dateEnd, decoration: const InputDecoration(labelText: 'تاریخ پایان')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('انصراف')),
          ElevatedButton(
            onPressed: () {
              a.isContracted = true;
              properties.add(Property(
                id: DateTime.now().toString(),
                ownerName: 'نامشخص', 
                ownerPhone: 'نامشخص',
                ownerAddress: '',
                dealType: a.requestType,
                propertyType: a.propertyType,
                address: a.address,
                area: a.area,
                rooms: '',
                yearBuilt: '',
                floor: '',
                totalPrice: a.price,
                pricePerMeter: '',
                deposit: a.deposit,
                rent: a.rent,
                notes: a.notes, // انتقال توضیحات به قرارداد
                isContracted: true,
                tenantName: a.name,
                startDate: dateStart.text,
                endDate: dateEnd.text,
              ));
              onRefresh();
              Navigator.pop(ctx);
            },
            child: const Text('ثبت'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, List<Applicant>>> grouped = {};
    for (var a in applicants) {
      grouped.putIfAbsent(a.requestType, () => {});
      grouped[a.requestType]!.putIfAbsent(a.propertyType, () => []);
      grouped[a.requestType]![a.propertyType]!.add(a);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: grouped.entries.map((mainEntry) {
        return ExpansionTile(
          title: Text(mainEntry.key, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E3A5F))),
          initiallyExpanded: true,
          children: mainEntry.value.entries.map((subEntry) {
            return ExpansionTile(
              title: Text(subEntry.key, style: const TextStyle(color: Colors.grey)),
              children: subEntry.value.map((a) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    title: Text(a.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('تلفن: ${a.phone}'),
                        if (a.notes.isNotEmpty) Text('توضیحات: ${a.notes}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {
                          applicants.remove(a);
                          onRefresh();
                        }),
                        if (!a.isContracted)
                          IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => _contractDialog(context, a)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
    );
  }
}

// ------------------ ۵. لیست قراردادها ------------------
class ContractsListScreen extends StatelessWidget {
  final VoidCallback onRefresh;
  const ContractsListScreen({super.key, required this.onRefresh});

  Future<void> _sendSms(String phoneNumber, String endDate) async {
    final String message = 'مالک محترم و مستأجر گرامی، با سلام و احترام؛ به اطلاع می‌رساند مدت قرارداد اجاره ملک شما در تاریخ $endDate به پایان می‌رسد. خواهشمند است جهت هماهنگی و تعیین شرایط تمدید قرارداد، در اسرع وقت با مشاور املاک جاوید تماس حاصل فرمایید. با سپاس';
    final Uri smsUri = Uri.parse('sms:$phoneNumber?body=$message');
    if (!await launchUrl(smsUri)) {
      throw Exception('Could not launch $smsUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    final contracts = properties.where((p) => p.isContracted).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (contracts.isEmpty) const Center(child: Text('هیچ قراردادی ثبت نشده است.')),
        ...contracts.map((c) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Colors.green, width: 2)),
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${c.ownerName} و ${c.tenantName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('شروع: ${c.startDate} - پایان: ${c.endDate}'),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('ویرایش')),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => _sendSms(c.ownerPhone, c.endDate), 
                        icon: const Icon(Icons.sms, color: Colors.white), 
                        label: const Text('پیامک', style: TextStyle(color: Colors.white))
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// ------------------ ۶. فرم ثبت ملک (با فیلد توضیحات) ------------------
class PropertyFormScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  const PropertyFormScreen({super.key, required this.onRefresh, required this.onBack});
  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  String dealType = 'اجاره';
  String propertyType = 'واحد مسکونی';
  final TextEditingController ownerName = TextEditingController();
  final TextEditingController ownerPhone = TextEditingController();
  final TextEditingController ownerAddress = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController area = TextEditingController();
  final TextEditingController rooms = TextEditingController();
  final TextEditingController yearBuilt = TextEditingController();
  final TextEditingController floor = TextEditingController();
  final TextEditingController totalPrice = TextEditingController();
  final TextEditingController pricePerMeter = TextEditingController();
  final TextEditingController deposit = TextEditingController();
  final TextEditingController rent = TextEditingController();
  final TextEditingController notes = TextEditingController(); // کنترلر توضیحات

  void _submit() {
    properties.add(Property(
      id: DateTime.now().toString(),
      ownerName: ownerName.text,
      ownerPhone: ownerPhone.text,
      ownerAddress: ownerAddress.text,
      dealType: dealType,
      propertyType: propertyType,
      address: address.text,
      area: area.text,
      rooms: rooms.text,
      yearBuilt: yearBuilt.text,
      floor: floor.text,
      totalPrice: totalPrice.text,
      pricePerMeter: pricePerMeter.text,
      deposit: deposit.text,
      rent: rent.text,
      notes: notes.text, // ثبت توضیحات
    ));
    widget.onRefresh();
    widget.onBack();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ملک ثبت شد!')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('اطلاعات مالک'),
          _inputField('نام و نام خانوادگی مالک', ownerName),
          const SizedBox(height: 12),
          _inputField('شماره تلفن مالک', ownerPhone, isNumber: true),
          const SizedBox(height: 12),
          _inputField('آدرس مالک', ownerAddress),
          const SizedBox(height: 20),
          _sectionTitle('اطلاعات ملک'),
          Row(
            children: [
              Expanded(child: _dropdownField('نوع معامله', ['اجاره', 'فروش', 'پیش‌فروش'], dealType, (val) => setState(() => dealType = val!))),
              const SizedBox(width: 12),
              Expanded(child: _dropdownField('نوع ملک', ['واحد مسکونی', 'ویلایی', 'مغازه', 'انبار', 'زمین'], propertyType, (val) => setState(() => propertyType = val!))),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('آدرس دقیق ملک', address),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _inputField('متراژ', area, isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('تعداد خواب', rooms, isNumber: true)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _inputField('سال ساخت', yearBuilt, isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('طبقه', floor, isNumber: true)),
            ],
          ),
          const SizedBox(height: 20),
          _sectionTitle('اطلاعات مالی'),
          if (dealType == 'اجاره') ...[
            Row(
              children: [
                Expanded(child: _inputField('رهن (تومان)', deposit, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('اجاره (تومان)', rent, isNumber: true)),
              ],
            ),
          ] else ...[
            Row(
              children: [
                Expanded(child: _inputField('قیمت کل', totalPrice, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('قیمت هر متر', pricePerMeter, isNumber: true)),
              ],
            ),
          ],
          const SizedBox(height: 20),
          _sectionTitle('توضیحات'),
          TextField(
            controller: notes,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'هرگونه توضیحات اضافه...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
              onPressed: _submit,
              child: const Text('ثبت اطلاعات ملک', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ ۷. فرم ثبت خواهان (با فیلد توضیحات) ------------------
class ApplicantFormScreen extends StatefulWidget {
  final VoidCallback onRefresh;
  final VoidCallback onBack;
  const ApplicantFormScreen({super.key, required this.onRefresh, required this.onBack});
  @override
  State<ApplicantFormScreen> createState() => _ApplicantFormScreenState();
}

class _ApplicantFormScreenState extends State<ApplicantFormScreen> {
  String requestType = 'خرید';
  String propertyType = 'واحد مسکونی';
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController area = TextEditingController();
  final TextEditingController deposit = TextEditingController();
  final TextEditingController rent = TextEditingController();
  final TextEditingController price = TextEditingController();
  final TextEditingController region = TextEditingController();
  final TextEditingController address = TextEditingController();
  final TextEditingController propDetails = TextEditingController();
  final TextEditingController notes = TextEditingController(); // کنترلر توضیحات

  void _submit() {
    applicants.add(Applicant(
      id: DateTime.now().toString(),
      name: name.text,
      phone: phone.text,
      requestType: requestType,
      propertyType: propertyType,
      area: area.text,
      deposit: deposit.text,
      rent: rent.text,
      price: price.text,
      region: region.text,
      address: address.text,
      propDetails: propDetails.text,
      notes: notes.text, // ثبت توضیحات
    ));
    widget.onRefresh();
    widget.onBack();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خواهان ثبت شد!')));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('مشخصات خواهان'),
          _inputField('نام و نام خانوادگی', name),
          const SizedBox(height: 12),
          _inputField('شماره تلفن', phone, isNumber: true),
          const SizedBox(height: 20),
          _sectionTitle('درخواست مورد نظر'),
          Row(
            children: [
              Expanded(child: _dropdownField('خواسته', ['خرید', 'فروش', 'اجاره'], requestType, (val) => setState(() => requestType = val!))),
              const SizedBox(width: 12),
              Expanded(child: _dropdownField('نوع کاربری', ['واحد مسکونی', 'ویلایی', 'تجاری', 'اداری', 'صنعتی'], propertyType, (val) => setState(() => propertyType = val!))),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('متراژ مورد نیاز', area, isNumber: true),
          const SizedBox(height: 12),

          if (requestType == 'اجاره') ...[
            Row(
              children: [
                Expanded(child: _inputField('مبلغ رهن', deposit, isNumber: true)),
                const SizedBox(width: 12),
                Expanded(child: _inputField('مبلغ اجاره', rent, isNumber: true)),
              ],
            ),
            const SizedBox(height: 12),
            _inputField('منطقه و محدوده مورد نظر', region),
          ] else if (requestType == 'خرید') ...[
            _inputField('حداکثر بودجه', price, isNumber: true),
            const SizedBox(height: 12),
            _inputField('منطقه و محدوده مورد نظر', region),
          ] else if (requestType == 'فروش') ...[
            _inputField('آدرس ملک', address),
            const SizedBox(height: 12),
            _inputField('مشخصات ملک', propDetails),
          ],

          const SizedBox(height: 20),
          _sectionTitle('توضیحات'),
          TextField(
            controller: notes,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'هرگونه توضیحات اضافه...',
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
              onPressed: _submit,
              child: const Text('ثبت اطلاعات خواهان', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ ویجت‌های کمکی ------------------
Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12.0),
    child: Row(
      children: [
        Container(width: 4, height: 20, color: const Color(0xFF1E3A5F)),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
      ],
    ),
  );
}

Widget _inputField(String label, TextEditingController controller, {bool isNumber = false}) {
  return TextField(
    controller: controller,
    keyboardType: isNumber ? TextInputType.number : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    ),
  );
}

Widget _dropdownField(String label, List<String> items, String currentValue, Function(String?) onChanged) {
  return DropdownButtonFormField<String>(
    value: currentValue,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
    ),
    items: items.map((val) => DropdownMenuItem(value: val, child: Text(val, style: const TextStyle(fontSize: 14)))).toList(),
    onChanged: onChanged,
  );
}
