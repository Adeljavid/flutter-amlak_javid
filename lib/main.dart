import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shamsi_date/shamsi_date.dart'; // اضافه شدن تاریخ شمسی

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
        textTheme: GoogleFonts.vazirmatnTextTheme(),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
      ),
      home: const LoginScreen(),
    );
  }
}

// ------------------ ۱. صفحه ورود ------------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    if (isLoggedIn) {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String savedPassword = prefs.getString('password') ?? '1234'; // رمز پیش فرض 1234

    if (_passwordController.text == savedPassword) {
      await prefs.setBool('isLoggedIn', true);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainDashboard()));
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('رمز عبور اشتباه است!'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

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
          children: const [
            PropertiesListScreen(),
            ApplicantsListScreen(),
            PropertyFormScreen(),
            ApplicantFormScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF1E3A5F),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'املاک'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'خواهان‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.add_home), label: 'ثبت ملک'),
            BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'ثبت خواهان'),
          ],
        ),
      ),
    );
  }
}

// ------------------ ۳. صفحه لیست املاک (با دکمه پیامک داینامیک) ------------------
class PropertiesListScreen extends StatelessWidget {
  const PropertiesListScreen({super.key});

  // تابع ارسال پیامک: حالا تاریخ پایان رو از خود ملک می‌گیره
  Future<void> _sendSms(String phoneNumber, String endDate) async {
    final String message = 'مالک محترم و مستأجر گرامی، با سلام و احترام؛ به اطلاع می‌رساند مدت قرارداد اجاره ملک شما در تاریخ $endDate به پایان می‌رسد. خواهشمند است جهت هماهنگی و تعیین شرایط تمدید قرارداد، در اسرع وقت با مشاور املاک جاوید تماس حاصل فرمایید. با سپاس';
    final Uri smsUri = Uri.parse('sms:$phoneNumber?body=$message');
    
    if (!await launchUrl(smsUri)) {
      throw Exception('Could not launch $smsUri');
    }
  }

  @override
  Widget build(BuildContext context) {
    // دیتای تستی برای نمایش (در دیتابیس واقعی، این‌ها از Supabase خونده میشن)
    const String testEndDate = '1404/05/12'; 
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('واحد مسکونی - سعادت آباد', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Icon(Icons.more_vert),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('رهن: ۵۰۰,۰۰۰,۰۰۰ | اجاره: ۲۰,۰۰۰,۰۰۰', style: TextStyle(color: Colors.grey)),
                const Divider(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('شروع: 1403/01/01'),
                    Text('پایان: $testEndDate', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('ویرایش'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      // دکمه پیامک، تاریخ همون ملک رو به تابع می‌فرسته
                      onPressed: () => _sendSms('09123456789', testEndDate), 
                      icon: const Icon(Icons.sms, size: 18, color: Colors.white),
                      label: const Text('ارسال پیامک', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

// ------------------ ۴. صفحه لیست خواهان‌ها ------------------
class ApplicantsListScreen extends StatelessWidget {
  const ApplicantsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('لیست خواهان‌ها خالی است. از تب ثبت خواهان اضافه کنید.'));
  }
}

// ------------------ ۵. فرم ثبت ملک (با تاریخ ثبت خودکار) ------------------
class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  String dealType = 'اجاره';
  // گرفتن تاریخ امروز به صورت خودکار
  final now = Jalali.now();
final String todayDate = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // نمایش تاریخ ثبت در بالای فرم
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('ثبت ملک جدید'),
              Text('تاریخ ثبت: $todayDate', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),

          _sectionTitle('اطلاعات مالک'),
          _inputField('نام و نام خانوادگی مالک'),
          const SizedBox(height: 12),
          _inputField('شماره تلفن مالک', isNumber: true),
          const SizedBox(height: 12),
          _inputField('آدرس مالک'),
          const SizedBox(height: 20),

          _sectionTitle('اطلاعات ملک'),
          Row(
            children: [
              Expanded(child: _dropdownField('نوع معامله', ['اجاره', 'فروش', 'پیش‌فروش'], dealType, (val) => setState(() => dealType = val!))),
              const SizedBox(width: 12),
              Expanded(child: _dropdownField('نوع ملک', ['واحد مسکونی', 'ویلایی', 'مغازه', 'انبار', 'زمین'], 'واحد مسکونی', (val) {})),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('آدرس دقیق ملک'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _inputField('متراژ', isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('تعداد خواب', isNumber: true)),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle('اطلاعات قرارداد'),
          Row(
            children: [
              Expanded(child: _inputField('تاریخ شروع قرارداد')),
              const SizedBox(width: 12),
              Expanded(child: _inputField('تاریخ پایان قرارداد')),
            ],
          ),
          const SizedBox(height: 20),

          _sectionTitle('اطلاعات مالی'),
          Row(
            children: [
              Expanded(child: _inputField(dealType == 'اجاره' ? 'رهن (تومان)' : 'قیمت کل (تومان)', isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _inputField(dealType == 'اجاره' ? 'اجاره ماهیانه (تومان)' : 'قیمت هر متر (تومان)', isNumber: true)),
            ],
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ملک ثبت شد!')));
              },
              child: const Text('ثبت اطلاعات ملک', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }
}

// ------------------ ۶. فرم ثبت خواهان (با تاریخ ثبت خودکار) ------------------
class ApplicantFormScreen extends StatefulWidget {
  const ApplicantFormScreen({super.key});

  @override
  State<ApplicantFormScreen> createState() => _ApplicantFormScreenState();
}

class _ApplicantFormScreenState extends State<ApplicantFormScreen> {
  final now = Jalali.now();
final String todayDate = '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('ثبت خواهان جدید'),
              Text('تاریخ ثبت: $todayDate', style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),

          _sectionTitle('مشخصات خواهان'),
          _inputField('نام و نام خانوادگی'),
          const SizedBox(height: 12),
          _inputField('شماره تلفن', isNumber: true),
          const SizedBox(height: 12),
          _inputField('آدرس'),
          const SizedBox(height: 20),

          _sectionTitle('درخواست مورد نظر'),
          Row(
            children: [
              Expanded(child: _dropdownField('خواسته', ['خرید', 'اجاره'], 'خرید', (val) {})),
              const SizedBox(width: 12),
              Expanded(child: _dropdownField('نوع کاربری', ['مسکونی', 'ویلایی', 'تجاری', 'اداری', 'صنعتی'], 'مسکونی', (val) {})),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _inputField('متراژ مورد نیاز', isNumber: true)),
              const SizedBox(width: 12),
              Expanded(child: _inputField('حداکثر بودجه / رهن', isNumber: true)),
            ],
          ),
          const SizedBox(height: 12),
          _inputField('منطقه و محدوده مورد نظر'),
          const SizedBox(height: 12),
          _inputField('توضیحات اضافه'),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A5F)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('خواهان ثبت شد!')));
              },
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

Widget _inputField(String label, {bool isNumber = false}) {
  return TextField(
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
