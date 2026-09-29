import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/db/repositories.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/charts.dart';

class SleepTab extends ConsumerWidget {
  const SleepTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sleepsAsync = ref.watch(sleepsProvider);
    final sleeps = sleepsAsync.valueOrNull ?? [];
    final today = du.DateUtils.today();
    final todaySleep = sleeps.where((s) => s.date == today).toList();

    // 近7天趋势（按日期升序）
    final now = DateTime.now();
    final labels = <String>[];
    final values = <double>[];
    for (var i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = du.DateUtils.format(d);
      labels.add(du.DateUtils.weekdayNameZh(d.weekday));
      final match = sleeps.where((s) => s.date == key).toList();
      values.add(match.isEmpty ? 0 : match.first.durationMin / 60.0);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _SleepSummaryCard(sleeps: sleeps, todaySleep: todaySleep),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle(title: '近 7 天睡眠时长（小时）'),
              const SizedBox(height: 12),
              SimpleLineChart(values: values, labels: labels, color: AppColors.sleep),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: SectionTitle(title: '睡眠记录')),
            TextButton.icon(
              onPressed: () => _showAddSleep(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('记录'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (sleeps.isEmpty)
          const EmptyState(icon: Icons.bedtime_outlined, message: '暂无睡眠记录')
        else
          for (final s in sleeps)
            SectionCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: AppColors.sleep.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: const Icon(Icons.bedtime_outlined, color: AppColors.sleep, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(s.date, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('${s.sleepTime} → ${s.wakeTime} · 睡眠 ${_fmtDuration(s.durationMin)}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.textHint),
                    onPressed: () async {
                      await Repositories.deleteSleep(s.id);
                      ref.invalidate(sleepsProvider);
                    },
                  ),
                ],
              ),
            ),
      ],
    );
  }

  String _fmtDuration(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    return h > 0 ? '$h小时$m分' : '$m分';
  }

  void _showAddSleep(BuildContext context, WidgetRef ref) {
    _SleepForm.show(context, ref, null);
  }
}

class _SleepSummaryCard extends StatelessWidget {
  final List<Sleep> sleeps;
  final List<Sleep> todaySleep;
  const _SleepSummaryCard({required this.sleeps, required this.todaySleep});

  @override
  Widget build(BuildContext context) {
    final avg7 = sleeps.isEmpty ? 0 : sleeps.map((s) => s.durationMin).reduce((a, b) => a + b) / sleeps.length;
    final lastNight = todaySleep.isEmpty ? null : todaySleep.first;
    return Row(
      children: [
        Expanded(child: StatCard(label: '昨晚睡眠', value: lastNight == null ? '—' : _fmt(lastNight.durationMin), color: AppColors.sleep, icon: Icons.bedtime_outlined)),
        const SizedBox(width: 12),
        Expanded(child: StatCard(label: '平均睡眠', value: avg7 == 0 ? '—' : _fmt(avg7.round()), color: AppColors.sleep, icon: Icons.timeline_outlined)),
      ],
    );
  }

  String _fmt(int min) {
    final h = min ~/ 60;
    final m = min % 60;
    return h > 0 ? '$h时$m分' : '$m分';
  }
}

class _SleepForm extends StatefulWidget {
  final Sleep? existing;
  const _SleepForm({this.existing});

  static void show(BuildContext context, WidgetRef ref, Sleep? existing) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _SleepForm(existing: existing),
    ).then((_) => ref.invalidate(sleepsProvider));
  }

  @override
  State<_SleepForm> createState() => _SleepFormState();
}

class _SleepFormState extends State<_SleepForm> {
  TimeOfDay sleepTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay wakeTime = const TimeOfDay(hour: 7, minute: 0);
  double quality = 3;
  final noteCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final dur = du.DateUtils.sleepMinutes(
      DateTime(2000, 1, 1, sleepTime.hour, sleepTime.minute),
      DateTime(2000, 1, 1, wakeTime.hour, wakeTime.minute),
    );
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('记录睡眠', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: '入睡时间',
                  time: sleepTime,
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: sleepTime);
                    if (t != null) setState(() => sleepTime = t);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: '起床时间',
                  time: wakeTime,
                  onTap: () async {
                    final t = await showTimePicker(context: context, initialTime: wakeTime);
                    if (t != null) setState(() => wakeTime = t);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text('睡眠时长：${dur ~/ 60}小时${dur % 60}分', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.sleep)),
          const SizedBox(height: 12),
          const Text('睡眠质量', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Slider(
            value: quality,
            min: 1,
            max: 5,
            divisions: 4,
            label: quality.round().toString(),
            activeColor: AppColors.sleep,
            onChanged: (v) => setState(() => quality = v),
          ),
          TextField(controller: noteCtrl, decoration: const InputDecoration(hintText: '备注（可选）')),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                await Repositories.saveSleep(Sleep(
                  id: 0,
                  date: du.DateUtils.today(),
                  sleepTime: '${sleepTime.hour.toString().padLeft(2, '0')}:${sleepTime.minute.toString().padLeft(2, '0')}',
                  wakeTime: '${wakeTime.hour.toString().padLeft(2, '0')}:${wakeTime.minute.toString().padLeft(2, '0')}',
                  durationMin: dur,
                  quality: quality.round(),
                  note: noteCtrl.text.trim(),
                ));
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('保存'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final TimeOfDay time;
  final VoidCallback onTap;
  const _TimeField({required this.label, required this.time, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.divider),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
            Text('${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
