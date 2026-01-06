import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

void main() {
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Chi Tiêu',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
        fontFamily: 'Roboto',
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.dark,
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Models
class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isExpense;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
  });

  Transaction copyWith({
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    bool? isExpense,
  }) {
    return Transaction(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
    );
  }
}

enum DateFilter { all, today, week, month, year }

// Login Page
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  // Danh sách tài khoản mẫu (username: password)
  static final Map<String, String> _accounts = {
    'admin': 'admin123',
    'user': 'user123',
    'demo': 'demo123',
  };

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutQuart),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: EdgeInsets.all(16),
      ),
    );
  }

  void _handleAuth() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Kiểm tra các trường có rỗng không
    if (username.isEmpty || password.isEmpty) {
      _showMessage('Vui lòng điền đầy đủ thông tin', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    // Giả lập delay network
    await Future.delayed(Duration(milliseconds: 800));

    if (_isLogin) {
      // Xử lý đăng nhập
      if (_accounts.containsKey(username)) {
        if (_accounts[username] == password) {
          _showMessage('Đăng nhập thành công!');
          await Future.delayed(Duration(milliseconds: 500));

          Navigator.of(context).pushReplacement(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomePage(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          );
        } else {
          _showMessage('Mật khẩu không đúng', isError: true);
        }
      } else {
        _showMessage('Tài khoản không tồn tại', isError: true);
      }
    } else {
      // Xử lý đăng ký
      if (password.length < 6) {
        _showMessage('Mật khẩu phải có ít nhất 6 ký tự', isError: true);
      } else if (password != confirmPassword) {
        _showMessage('Mật khẩu xác nhận không khớp', isError: true);
      } else if (_accounts.containsKey(username)) {
        _showMessage('Tên đăng nhập đã tồn tại', isError: true);
      } else {
        // Đăng ký thành công
        _accounts[username] = password;
        _showMessage('Đăng ký thành công! Vui lòng đăng nhập');
        setState(() {
          _isLogin = true;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Container(
                  width: isSmallScreen ? size.width * 0.9 : 450,
                  margin: EdgeInsets.all(20),
                  padding: EdgeInsets.all(isSmallScreen ? 24 : 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        _isLogin ? 'Đăng Nhập' : 'Đăng Ký',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF667eea),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Tên đăng nhập',
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFF667eea),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          prefixIcon: Icon(
                            Icons.lock,
                            color: Color(0xFF667eea),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Color(0xFF667eea),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!_isLogin)
                        Column(
                          children: [
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Xác nhận mật khẩu',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: Color(0xFF667eea),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Color(0xFF667eea),
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF667eea),
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: Size(double.infinity, 50),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                _isLogin ? 'ĐĂNG NHẬP' : 'ĐĂNG KÝ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      SizedBox(height: 15),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isLogin = !_isLogin;
                            _confirmPasswordController.clear();
                          });
                        },
                        child: Text(
                          _isLogin
                              ? 'Chưa có tài khoản? Đăng ký'
                              : 'Đã có tài khoản? Đăng nhập',
                          style: TextStyle(color: Color(0xFF667eea)),
                        ),
                      ),
                      if (_isLogin) ...[
                        SizedBox(height: 20),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Tài khoản demo',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade900,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'admin / admin123\nuser / user123\ndemo / demo123',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue.shade800,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  List<Transaction> _transactions = [];
  int _selectedIndex = 0;
  double _budget = 5000000;
  DateFilter _dateFilter = DateFilter.all;

  late AnimationController _fabController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fabController, curve: Curves.easeOut));
    _fabController.forward();

    // Sample data
    _transactions = [
      Transaction(
        id: '1',
        title: 'Lương tháng 1',
        amount: 15000000,
        date: DateTime.now().subtract(Duration(days: 5)),
        category: 'Lương',
        isExpense: false,
      ),
      Transaction(
        id: '2',
        title: 'Mua sắm',
        amount: 500000,
        date: DateTime.now().subtract(Duration(days: 2)),
        category: 'Mua sắm',
        isExpense: true,
      ),
      Transaction(
        id: '3',
        title: 'Ăn uống',
        amount: 300000,
        date: DateTime.now().subtract(Duration(days: 1)),
        category: 'Ăn uống',
        isExpense: true,
      ),
      Transaction(
        id: '4',
        title: 'Cafe',
        amount: 50000,
        date: DateTime.now(),
        category: 'Ăn uống',
        isExpense: true,
      ),
      Transaction(
        id: '5',
        title: 'Xăng xe',
        amount: 200000,
        date: DateTime.now().subtract(Duration(days: 35)),
        category: 'Di chuyển',
        isExpense: true,
      ),
    ];
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  List<Transaction> get _filteredTransactions {
    final now = DateTime.now();
    switch (_dateFilter) {
      case DateFilter.today:
        return _transactions.where((t) {
          return t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day;
        }).toList();
      case DateFilter.week:
        final weekAgo = now.subtract(Duration(days: 7));
        return _transactions.where((t) => t.date.isAfter(weekAgo)).toList();
      case DateFilter.month:
        return _transactions.where((t) {
          return t.date.year == now.year && t.date.month == now.month;
        }).toList();
      case DateFilter.year:
        return _transactions.where((t) => t.date.year == now.year).toList();
      case DateFilter.all:
      default:
        return _transactions;
    }
  }

  double get totalIncome {
    return _filteredTransactions
        .where((t) => !t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpense {
    return _filteredTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance => totalIncome - totalExpense;

  void _addTransaction(Transaction transaction) {
    setState(() {
      _transactions.insert(0, transaction);
    });
  }

  void _updateTransaction(Transaction transaction) {
    setState(() {
      final index = _transactions.indexWhere((t) => t.id == transaction.id);
      if (index != -1) {
        _transactions[index] = transaction;
      }
    });
  }

  void _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((t) => t.id == id);
    });
  }

  void _showAddTransactionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTransactionSheet(onAdd: _addTransaction),
    );
  }

  void _showEditTransactionDialog(Transaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EditTransactionSheet(
        transaction: transaction,
        onUpdate: _updateTransaction,
      ),
    );
  }

  String _getFilterLabel() {
    switch (_dateFilter) {
      case DateFilter.today:
        return 'Hôm nay';
      case DateFilter.week:
        return 'Tuần này';
      case DateFilter.month:
        return 'Tháng này';
      case DateFilter.year:
        return 'Năm này';
      case DateFilter.all:
      default:
        return 'Tất cả';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    final pages = [
      _buildDashboard(isSmallScreen),
      _buildTransactionsList(isSmallScreen),
      _buildStatistics(isSmallScreen),
      _buildBudget(isSmallScreen),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Quản Lý Chi Tiêu',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
          ),
        ),
        elevation: 0,
        actions: [
          if (_selectedIndex == 1)
            PopupMenuButton<DateFilter>(
              icon: Icon(Icons.filter_list, color: Colors.white),
              onSelected: (filter) {
                setState(() {
                  _dateFilter = filter;
                });
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: DateFilter.all, child: Text('Tất cả')),
                PopupMenuItem(value: DateFilter.today, child: Text('Hôm nay')),
                PopupMenuItem(value: DateFilter.week, child: Text('Tuần này')),
                PopupMenuItem(
                  value: DateFilter.month,
                  child: Text('Tháng này'),
                ),
                PopupMenuItem(value: DateFilter.year, child: Text('Năm này')),
              ],
            ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: Duration(milliseconds: 300),
        child: pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xFF667eea),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Tổng quan',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Giao dịch'),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Thống kê',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance),
              label: 'Ngân sách',
            ),
          ],
        ),
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabAnimation,
        child: FloatingActionButton.extended(
          onPressed: _showAddTransactionDialog,
          icon: Icon(Icons.add),
          label: Text('Thêm'),
          backgroundColor: Color(0xFF667eea),
        ),
      ),
    );
  }

  Widget _buildDashboard(bool isSmallScreen) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBalanceCard(isSmallScreen),
          SizedBox(height: 20),
          _buildQuickStats(isSmallScreen),
          SizedBox(height: 20),
          Text(
            'Giao dịch gần đây',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ..._transactions.take(5).map((t) => _buildTransactionItem(t)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF667eea).withOpacity(0.5),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Số dư hiện tại',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            NumberFormat.currency(locale: 'vi', symbol: '₫').format(balance),
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 28 : 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Thu nhập',
            totalIncome,
            Icons.arrow_downward,
            Colors.green,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            'Chi tiêu',
            totalExpense,
            Icons.arrow_upward,
            Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    double amount,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 8),
              Text(title, style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            NumberFormat.currency(locale: 'vi', symbol: '₫').format(amount),
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(bool isSmallScreen) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.grey[100],
          child: Row(
            children: [
              Icon(Icons.filter_list, color: Color(0xFF667eea), size: 20),
              SizedBox(width: 8),
              Text(
                'Lọc: ${_getFilterLabel()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF667eea),
                ),
              ),
              Spacer(),
              Text(
                '${_filteredTransactions.length} giao dịch',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: _filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 80, color: Colors.grey[300]),
                      SizedBox(height: 16),
                      Text(
                        'Không có giao dịch nào',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _filteredTransactions.length,
                  itemBuilder: (context, index) =>
                      _buildTransactionItem(_filteredTransactions[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    return Dismissible(
      key: Key(transaction.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return true; // Delete
        } else if (direction == DismissDirection.startToEnd) {
          _showEditTransactionDialog(transaction);
          return false; // Don't delete, just edit
        }
        return false;
      },
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 20),
        child: Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteTransaction(transaction.id),
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 2,
        child: ListTile(
          contentPadding: EdgeInsets.all(16),
          leading: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: transaction.isExpense
                  ? Colors.red.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.isExpense ? Icons.arrow_upward : Icons.arrow_downward,
              color: transaction.isExpense ? Colors.red : Colors.green,
            ),
          ),
          title: Text(
            transaction.title,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${transaction.category} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
            style: TextStyle(color: Colors.grey),
          ),
          trailing: Text(
            '${transaction.isExpense ? '-' : '+'}${NumberFormat.currency(locale: 'vi', symbol: '₫').format(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: transaction.isExpense ? Colors.red : Colors.green,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics(bool isSmallScreen) {
    return StatisticsPage(transactions: _transactions);
  }

  Widget _buildCategoryItem(String category, double amount, double total) {
    final percentage =
        total > 0 ? (amount / total * 100).toStringAsFixed(1) : '0.0';
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  NumberFormat.currency(
                    locale: 'vi',
                    symbol: '₫',
                  ).format(amount),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildBudget(bool isSmallScreen) {
    final spentPercentage =
        _budget > 0 ? (totalExpense / _budget * 100).clamp(0, 100) : 0.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ngân sách tháng',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  'Ngân sách',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(height: 10),
                Text(
                  NumberFormat.currency(
                    locale: 'vi',
                    symbol: '₫',
                  ).format(_budget),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                LinearProgressIndicator(
                  value: spentPercentage / 100,
                  backgroundColor: Colors.white30,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Đã chi: ${spentPercentage.toStringAsFixed(1)}%',
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(
                      'Còn lại: ${NumberFormat.currency(locale: 'vi', symbol: '₫').format(_budget - totalExpense)}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final controller = TextEditingController(
                text: _budget.toString(),
              );
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Đặt ngân sách'),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Số tiền',
                      suffixText: '₫',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _budget = double.tryParse(controller.text) ?? _budget;
                        });
                        Navigator.pop(context);
                      },
                      child: Text('Lưu'),
                    ),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF667eea),
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
            child: Text(
              'Thay đổi ngân sách',
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

// Add Transaction Sheet
class AddTransactionSheet extends StatefulWidget {
  final Function(Transaction) onAdd;

  const AddTransactionSheet({super.key, required this.onAdd});

  @override
  _AddTransactionSheetState createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends State<AddTransactionSheet> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedCategory = 'Ăn uống';
  bool _isExpense = true;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Giải trí',
    'Lương',
    'Khác',
  ];

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Thêm giao dịch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTypeButton('Chi tiêu', true)),
                SizedBox(width: 10),
                Expanded(child: _buildTypeButton('Thu nhập', false)),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: '₫',
              ),
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty) {
                  widget.onAdd(
                    Transaction(
                      id: DateTime.now().toString(),
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      date: _selectedDate,
                      category: _selectedCategory,
                      isExpense: _isExpense,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667eea),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Thêm giao dịch',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isExpense) {
    final isSelected = _isExpense == isExpense;
    return GestureDetector(
      onTap: () => setState(() => _isExpense = isExpense),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF667eea) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Edit Transaction Sheet
class EditTransactionSheet extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction) onUpdate;

  const EditTransactionSheet({
    super.key,
    required this.transaction,
    required this.onUpdate,
  });

  @override
  _EditTransactionSheetState createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends State<EditTransactionSheet> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late String _selectedCategory;
  late bool _isExpense;
  late DateTime _selectedDate;

  final List<String> _categories = [
    'Ăn uống',
    'Mua sắm',
    'Di chuyển',
    'Giải trí',
    'Lương',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.transaction.title);
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _selectedCategory = widget.transaction.category;
    _isExpense = widget.transaction.isExpense;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sửa giao dịch',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildTypeButton('Chi tiêu', true)),
                SizedBox(width: 10),
                Expanded(child: _buildTypeButton('Thu nhập', false)),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            SizedBox(height: 15),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số tiền',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: '₫',
              ),
            ),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: InputDecoration(
                labelText: 'Danh mục',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
            ),
            SizedBox(height: 15),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(
                  DateFormat('dd/MM/yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty &&
                    _amountController.text.isNotEmpty) {
                  widget.onUpdate(
                    widget.transaction.copyWith(
                      title: _titleController.text,
                      amount: double.parse(_amountController.text),
                      date: _selectedDate,
                      category: _selectedCategory,
                      isExpense: _isExpense,
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF667eea),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              child: Text(
                'Cập nhật giao dịch',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeButton(String label, bool isExpense) {
    final isSelected = _isExpense == isExpense;
    return GestureDetector(
      onTap: () => setState(() => _isExpense = isExpense),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF667eea) : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Pie Chart Painter

class PieChartPainter extends CustomPainter {
  final Map<String, double> data;
  final List<Color> colors = [
    Color(0xFF667eea),
    Color(0xFF764ba2),
    Color(0xFFf093fb),
    Color(0xFF4facfe),
    Color(0xFF43e97b),
    Color(0xFFfa709a),
  ];

  PieChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2.5;
    final total = data.values.fold(0.0, (sum, value) => sum + value);

    if (total == 0) return;

    double startAngle = -math.pi / 2;
    int colorIndex = 0;

    data.forEach((category, amount) {
      final sweepAngle = (amount / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[colorIndex % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final outlinePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        outlinePaint,
      );

      startAngle += sweepAngle;
      colorIndex++;
    });

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(PieChartPainter oldDelegate) => true;
}

enum TimeFilter { week, month, year }

enum TypeFilter { expense, income }

class StatisticsPage extends StatefulWidget {
  final List<Transaction> transactions;

  const StatisticsPage({super.key, required this.transactions});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  TimeFilter _timeFilter = TimeFilter.month;
  TypeFilter _typeFilter = TypeFilter.expense;

  Map<String, double> _filteredData() {
    final now = DateTime.now();

    bool inRange(Transaction t) {
      if (_timeFilter == TimeFilter.week) {
        return t.date.isAfter(now.subtract(const Duration(days: 7)));
      }
      if (_timeFilter == TimeFilter.month) {
        return t.date.year == now.year && t.date.month == now.month;
      }
      return t.date.year == now.year;
    }

    final data = <String, double>{};

    for (var t in widget.transactions) {
      if (!inRange(t)) continue;
      if (_typeFilter == TypeFilter.expense && !t.isExpense) continue;
      if (_typeFilter == TypeFilter.income && t.isExpense) continue;

      data[t.category] = (data[t.category] ?? 0) + t.amount;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    final data = _filteredData();
    final total = data.values.fold(0.0, (a, b) => a + b);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          /// ===== TIME FILTER =====
          SegmentedButton<TimeFilter>(
            segments: const [
              ButtonSegment(value: TimeFilter.week, label: Text('Tuần')),
              ButtonSegment(value: TimeFilter.month, label: Text('Tháng')),
              ButtonSegment(value: TimeFilter.year, label: Text('Năm')),
            ],
            selected: {_timeFilter},
            onSelectionChanged: (v) {
              setState(() => _timeFilter = v.first);
            },
          ),

          const SizedBox(height: 12),

          /// ===== TYPE FILTER =====
          SegmentedButton<TypeFilter>(
            segments: const [
              ButtonSegment(value: TypeFilter.expense, label: Text('Chi tiêu')),
              ButtonSegment(value: TypeFilter.income, label: Text('Thu nhập')),
            ],
            selected: {_typeFilter},
            onSelectionChanged: (v) {
              setState(() => _typeFilter = v.first);
            },
          ),

          const SizedBox(height: 24),

          /// ===== PIE CHART =====
          if (data.isNotEmpty)
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: CustomPaint(painter: PieChartPainter(data)),
              ),
            )
          else
            const Center(
              child: Text(
                'Không có dữ liệu',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          const SizedBox(height: 24),

          /// ===== DETAILS =====
          ...data.entries.map((e) {
            final percent =
                total == 0 ? 0 : (e.value / total * 100).toStringAsFixed(1);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                title: Text(e.key),
                subtitle: Text('$percent%'),
                trailing: Text(
                  NumberFormat.currency(
                    locale: 'vi',
                    symbol: '₫',
                  ).format(e.value),
                  style: TextStyle(
                    color: _typeFilter == TypeFilter.expense
                        ? Colors.red
                        : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
