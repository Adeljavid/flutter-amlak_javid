import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const RealEstateApp());
}

class RealEstateApp extends StatelessWidget {
  const RealEstateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مشاور املاک',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        primaryColor: const Color(0xFF1E3A5F),
        textTheme: GoogleFonts.vazirmatnTextTheme(), // فونت فارسی
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A5F)),
      ),
      home: const MainDashboard(),
    );
  }
}

// صفحه اصلی با منوی پایین
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const PropertiesListScreen(),
    const ApplicantsScreen(),
    const PropertyFormScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نرم‌افزار املاک', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF1E3A5F),
          centerTitle: true,
        ),
        body: _pages[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF1E3A5F),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'املاک'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'خواهان‌ها'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'ثبت جدید'),
          ],
        ),
      ),
    );
  }
}

// ۱. صفحه لیست املاک
class PropertiesListScreen extends StatelessWidget {
  const PropertiesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_work, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('هنوز ملکی ثبت نشده است', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ۲. صفحه خواهان‌ها (متقاضیان)
class ApplicantsScreen extends StatelessWidget {
  const ApplicantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_search, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('لیست خواهان‌ها خالی است', style: TextStyle(fontSize: 18, color: Colors.grey)),
        ],
      ),
    );
  }
}

// ۳. صفحه فرم ثبت ملک (کامل شده)
class PropertyFormScreen extends StatefulWidget {
  const PropertyFormScreen({super.key});

  @override
  State<PropertyFormScreen> createState() => _PropertyFormScreenState();
}

class _PropertyFormScreenState extends State<PropertyFormScreen> {
  String dealType = 'اجاره';
  String propertyType = 'واحد مسکونی (آپارتمان)';

  final List<String> amenities = ['پارکینگ', 'انباری', 'آسانسور', 'بالکن', 'استخر', 'سونا', 'جکوزی', 'درب ریموت', 'آیفون تصویری', 'کولر گازی', 'شوفاژ', 'پکیج'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('اطلاعات پایه'),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: dealType,
                  decoration: _inputDecoration('نوع معامله'),
                  items: ['اجاره', 'فروش', 'پیش‌فروش'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => setState(() => dealType = val!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: propertyType,
                  decoration: _inputDecoration('نوع ملک'),
                  items: ['واحد مسکونی (آپارتمان)', 'خانه ویلایی', 'مغازه', 'انبار', 'زمین'].map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                  onChanged: (val) => setState(() => propertyType = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          _buildSectionTitle('مشخصات'),
          Row(
            children: [
              Expanded(child: TextFormField(decoration: _inputDecoration('متراژ (متر)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: _inputDecoration('سال ساخت'), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: _inputDecoration('تعداد خواب'), keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('امکانات'),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: amenities.map((amenity) => SizedBox(
                width: 100,
                child: CheckboxListTile(
                  title: Text(amenity, style: const TextStyle(fontSize: 13)),
                  value: false,
                  onChanged: (bool? value) {},
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('اطلاعات مالی'),
          Row(
            children: [
              Expanded(child: TextFormField(decoration: _inputDecoration(dealType == 'اجاره' ? 'رهن (تومان)' : 'قیمت کل (تومان)'), keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: TextFormField(decoration: _inputDecoration(dealType == 'اجاره' ? 'اجاره ماهیانه' : 'قیمت هر متر'), keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 30),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A5F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اطلاعات ملک ثبت شد!')));
              },
              child: const Text('ثبت اطلاعات ملک', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(width: 4, height: 20, color: const Color(0xFF1E3A5F)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 2)),
    );
  }
}
