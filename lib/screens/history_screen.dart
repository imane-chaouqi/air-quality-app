import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_sidebar.dart';
import 'visualization_screen.dart';

class HistoryScreen extends StatelessWidget {
  final String userName;
  final String userEmail;

  const HistoryScreen({
    super.key,
    this.userName = 'Siham Mahis',
    this.userEmail = 'siham@mail.com',
  });

  @override
  Widget build(BuildContext context) {
    final historyData = [
      {'date': '10/11', 'heure': '14:30', 'pm25': '28', 'temp': '22°C', 'hum': '55%'},
      {'date': '09/11', 'heure': '19:20', 'pm25': '35', 'temp': '21°C', 'hum': '60%'},
      {'date': '08/11', 'heure': '16:45', 'pm25': '18', 'temp': '23°C', 'hum': '52%'},
      {'date': '07/11', 'heure': '20:10', 'pm25': '41', 'temp': '20°C', 'hum': '58%'},
      {'date': '06/11', 'heure': '17:25', 'pm25': '25', 'temp': '22°C', 'hum': '59%'},
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          AppSidebar(
            currentRoute: 'historique',
            userName: userName,
            userEmail: userEmail,
          ),
          Expanded(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text(
                  'Historique',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                centerTitle: true,
              ),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryDark.withOpacity(0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Historique des mesures',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 16),
                            Table(
                              // Ajustement des proportions pour éviter le chevauchement PM2.5 / T°
                              columnWidths: const {
                                0: FlexColumnWidth(1.1),
                                1: FlexColumnWidth(1.1),
                                2: FlexColumnWidth(1.3),
                                3: FlexColumnWidth(0.9),
                                4: FlexColumnWidth(1.0),
                              },
                              children: [
                                const TableRow(
                                  children: [
                                    Text('Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryTeal)),
                                    Text('Heure', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryTeal)),
                                    Text('PM2.5', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryTeal)),
                                    Text('T°', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryTeal)),
                                    Text('Hum.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryTeal)),
                                  ],
                                ),
                                const TableRow(children: [SizedBox(height: 10), SizedBox(height: 10), SizedBox(height: 10), SizedBox(height: 10), SizedBox(height: 10)]),
                                for (var item in historyData)
                                  TableRow(
                                    children: [
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item['date']!, style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary))),
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item['heure']!, style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary))),
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item['pm25']!, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryDark))),
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item['temp']!, style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary))),
                                      Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(item['hum']!, style: const TextStyle(fontSize: 11.5, color: AppColors.textPrimary))),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VisualizationScreen(
                                  userName: userName,
                                  userEmail: userEmail,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.softTealBg,
                            foregroundColor: AppColors.primaryTeal,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            side: BorderSide(color: AppColors.primaryTeal.withOpacity(0.3), width: 1),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Visualisation',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}