import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'records_controller.dart';
import '../../core/theme/app_colors.dart';

class RecordsView extends GetView<RecordsController> {
  const RecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('기록 확인')),
      body: Obx(() {
        if (controller.records.isEmpty) {
          return const Center(child: Text('아직 집중 기록이 없습니다. 파이팅!', style: TextStyle(color: AppColors.textLight)));
        }

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // 요약 (연속 집중)
            Row(
              children: [
                Expanded(child: _buildStatCard('🔥 현재 연속', '${controller.currentStreak.value}일')),
                const SizedBox(width: 16),
                Expanded(child: _buildStatCard('🌟 최대 연속', '${controller.maxStreak.value}일')),
              ],
            ),
            const SizedBox(height: 20),

            // 달력 위젯
            Card(
               child: Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TableCalendar(
                    firstDay: DateTime.utc(2020, 1, 1),
                    lastDay: DateTime.utc(2030, 12, 31),
                    focusedDay: DateTime.now(),
                    headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    calendarStyle: const CalendarStyle(
                       todayDecoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                       selectedDecoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                    ),
                    calendarBuilders: CalendarBuilders(
                       markerBuilder: (context, date, events) {
                          // Find records matching date
                          final hasRecord = controller.records.any((record) => 
                              record.date.year == date.year && 
                              record.date.month == date.month && 
                              record.date.day == date.day
                          );

                          if (hasRecord) {
                              return Positioned(
                                 bottom: 1,
                                 child: Container(
                                     decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary),
                                     width: 6.0,
                                     height: 6.0,
                                 ),
                              );
                          }
                          return null;
                       }
                    ),
                 ),
               ),
            ),
            const SizedBox(height: 20),

            // 차트 영역 (월간 - 임시로 최근 7일 그래프 표시)
            const Text('최근 7일 집중 시간 (분)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
               height: 200,
               child: Card(
                  child: Padding(
                     padding: const EdgeInsets.all(16.0),
                     child: BarChart(_buildChartData()),
                  )
               ),
            ),

            const SizedBox(height: 20),
            
            // 카테고리별 시간
            const Text('카테고리별 시간 내역', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Card(
               child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _groupedRecords().keys.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                      final category = _groupedRecords().keys.elementAt(index);
                      final seconds = _groupedRecords()[category]!;
                      final timeStr = '${(seconds ~/ 60)}분 ${seconds % 60}초';
                      
                      return ListTile(
                          title: Text(category),
                          trailing: Text(timeStr, style: const TextStyle(fontWeight: FontWeight.bold)),
                      );
                  },
               ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 14)),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.text)),
          ],
        ),
      ),
    );
  }

  Map<String, int> _groupedRecords() {
    Map<String, int> map = {};
    for (var r in controller.records) {
       map[r.category] = (map[r.category] ?? 0) + r.focusDurationSeconds;
    }
    return map;
  }

  BarChartData _buildChartData() {
     // 최근 7일치 데이터 집계
     DateTime now = DateTime.now();
     List<BarChartGroupData> barGroups = [];
     
     for (int i = 6; i >= 0; i--) {
        DateTime targetDate = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
        
        int dailySeconds = 0;
        for (var r in controller.records) {
           if (r.date.year == targetDate.year && r.date.month == targetDate.month && r.date.day == targetDate.day) {
             dailySeconds += r.focusDurationSeconds;
           }
        }
        
        barGroups.add(
           BarChartGroupData(
             x: 6 - i, // 0 to 6
             barRods: [
               BarChartRodData(
                 toY: (dailySeconds / 60).toDouble(), // 분 단위
                 color: AppColors.primary,
                 width: 16,
                 borderRadius: BorderRadius.circular(4),
               ),
             ],
           )
        );
     }

     return BarChartData(
        alignment: BarChartAlignment.spaceAround,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: barGroups,
        titlesData: FlTitlesData(
           topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
           bottomTitles: AxisTitles(
             sideTitles: SideTitles(
               showTitles: true,
               getTitlesWidget: (value, meta) {
                 final idx = value.toInt(); // 0 is 6 days ago, 6 is today
                 final dt = now.subtract(Duration(days: 6 - idx));
                 return Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: Text(DateFormat('M/d').format(dt), style: const TextStyle(fontSize: 10)),
                 );
               },
             )
           )
        ),
     );
  }
}
