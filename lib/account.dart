import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  String username = '';
  String email = '';
  double wallet = 0;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadAccount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadAccount();
  }

  Future<void> loadAccount() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ?? 'SteamUser';
      email = prefs.getString('email') ?? 'user@steam.com';
      wallet = prefs.getDouble('wallet') ?? 0;
      loading = false;
    });
  }

  InputDecoration steamInput(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Color(0xFF8F98A0)),
      filled: true,
      fillColor: Color(0xFF2A3F5A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: Color(0xFF66C0F4)),
      ),
    );
  }

  Future<void> showEditProfileDialog() async {
    TextEditingController nameCtrl = TextEditingController(text: username);
    TextEditingController emailCtrl = TextEditingController(text: email);

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Color(0xFF16202D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: TextStyle(color: Colors.white),
              decoration: steamInput('Username'),
            ),
            SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.emailAddress,
              decoration: steamInput('Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Color(0xFF8F98A0))),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty ||
                  emailCtrl.text.trim().isEmpty) {
                return;
              }

              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('username', nameCtrl.text.trim());
              await prefs.setString('email', emailCtrl.text.trim());

              setState(() {
                username = nameCtrl.text.trim();
                email = emailCtrl.text.trim();
              });

              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF66C0F4)),
            child: Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> showDepositDialog() async {
    TextEditingController amountCtrl = TextEditingController();
    List<double> quickAmounts = [100, 250, 500, 1000, 2500, 5000];

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setInner) => AlertDialog(
          backgroundColor: Color(0xFF16202D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Color(0xFF66C0F4)),
              SizedBox(width: 10),
              Text(
                'Deposit Funds',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current balance: ₱${wallet.toStringAsFixed(2)}',
                style: TextStyle(color: Color(0xFF8F98A0), fontSize: 13),
              ),
              SizedBox(height: 14),
              Text(
                'Quick amounts:',
                style: TextStyle(color: Color(0xFF8F98A0), fontSize: 12),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: quickAmounts.map((amt) {
                  return GestureDetector(
                    onTap: () {
                      amountCtrl.text = amt.toStringAsFixed(0);
                      setInner(() {});
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A3F5A),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: Color(0xFF4C6B8A),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        '₱${amt.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Color(0xFF66C0F4),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 14),
              Text(
                'Or enter custom amount:',
                style: TextStyle(color: Color(0xFF8F98A0), fontSize: 12),
              ),
              SizedBox(height: 8),
              TextField(
                controller: amountCtrl,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setInner(() {}),
                decoration: steamInput('Amount (₱)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: Color(0xFF8F98A0))),
            ),
            ElevatedButton(
              onPressed: () async {
                double amt = double.tryParse(amountCtrl.text.trim()) ?? 0;
                if (amt <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid amount.'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final prefs = await SharedPreferences.getInstance();
                double newWallet = wallet + amt;
                await prefs.setDouble('wallet', newWallet);

                setState(() {
                  wallet = newWallet;
                });

                if (mounted) {
                  Navigator.pop(context);
                  await showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: Color(0xFF16202D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
                          SizedBox(width: 10),
                          Text(
                            'Deposit Successful',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                      content: Text(
                        'Successfully added ₱${amt.toStringAsFixed(2)} to your wallet.\n\nNew balance: ₱${newWallet.toStringAsFixed(2)}',
                        style: TextStyle(color: Color(0xFF8F98A0), height: 1.5),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'OK',
                            style: TextStyle(color: Color(0xFF66C0F4)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF66C0F4),
              ),
              child: Text('Deposit', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileTile(IconData icon, String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF66C0F4), size: 20),
          SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(color: Color(0xFF8F98A0), fontSize: 11),
              ),
              SizedBox(height: 2),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1B2838),
      appBar: AppBar(
        backgroundColor: Color(0xFF171D25),
        title: Row(
          children: [
            Icon(Icons.whatshot, color: Color(0xFF66C0F4)),
            SizedBox(width: 8),
            Text(
              'Steam',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Icon(Icons.notifications_outlined, color: Colors.white),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: Color(0xFF66C0F4)))
          : SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: 12),
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF1A4A7A), Color(0xFF66C0F4)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Color(0xFF66C0F4),
                            width: 2.5,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 52,
                        ),
                      ),
                      GestureDetector(
                        onTap: showEditProfileDialog,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Color(0xFF4C6B8A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Color(0xFF1B2838),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    username,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(color: Color(0xFF8F98A0), fontSize: 14),
                  ),
                  SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A4A7A), Color(0xFF16202D)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Color(0xFF2A3F5A), width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.account_balance_wallet,
                              color: Color(0xFF66C0F4),
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Steam Wallet',
                              style: TextStyle(
                                color: Color(0xFF8F98A0),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          '₱${wallet.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: showDepositDialog,
                            icon: Icon(Icons.add, size: 18),
                            label: Text('Add Funds'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF4C6B8A),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0xFF16202D),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF2A3F5A), width: 0.5),
                    ),
                    child: Column(
                      children: [
                        buildProfileTile(
                          Icons.person_outline,
                          'Username',
                          username,
                        ),
                        Divider(color: Color(0xFF2A3F5A), height: 1),
                        buildProfileTile(Icons.email_outlined, 'Email', email),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: showEditProfileDialog,
                      icon: Icon(Icons.edit_outlined, color: Color(0xFF66C0F4)),
                      label: Text(
                        'Edit Profile',
                        style: TextStyle(color: Color(0xFF66C0F4)),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 13),
                        side: BorderSide(color: Color(0xFF66C0F4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
