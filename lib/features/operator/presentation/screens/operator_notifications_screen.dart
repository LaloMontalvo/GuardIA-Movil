import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';

/// Centro de notificaciones del Operador con tabs
class OperatorNotificationsScreen extends StatefulWidget {
  const OperatorNotificationsScreen({super.key});

  @override
  State<OperatorNotificationsScreen> createState() => _OperatorNotificationsScreenState();
}

class _OperatorNotificationsScreenState extends State<OperatorNotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _notifications = [
    _Notif('1', 'Incidente: sospechoso', 'Persona merodeando Zona A', 'incidente', 'Hace 10 min', 'Zona A', false),
    _Notif('2', 'Alerta de pánico', 'Un operador activó alerta en Zona C', 'pánico', 'Hace 20 min', 'Zona C', false),
    _Notif('3', 'Mantenimiento', 'Se realizará mantenimiento mañana', 'sistema', 'Hace 1h', '', true),
    _Notif('4', 'Incidente: ruido', 'Ruido excesivo reportado en Zona B', 'incidente', 'Hace 2h', 'Zona B', true),
    _Notif('5', 'Actualización', 'Nueva versión de GuardIA disponible', 'sistema', 'Hace 5h', '', true),
    _Notif('6', 'Incidente: accidente', 'Choque menor reportado', 'incidente', 'Ayer', 'Zona A', true),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_Notif> _filterByTab(int index) {
    return switch (index) {
      1 => _notifications.where((n) => n.type == 'incidente').toList(),
      2 => _notifications.where((n) => n.type == 'sistema').toList(),
      3 => _notifications.where((n) => n.type == 'pánico').toList(),
      _ => _notifications,
    };
  }

  IconData _getIcon(String type) => switch (type) {
        'incidente' => Icons.warning_amber_rounded,
        'sistema' => Icons.info_outline_rounded,
        'pánico' => Icons.emergency_rounded,
        _ => Icons.notifications_rounded,
      };

  Color _getColor(String type) => switch (type) {
        'incidente' => Colors.orange,
        'sistema' => Colors.grey,
        'pánico' => Colors.red,
        _ => AppColors.primaryBlue,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final unreadCount = _notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () => setState(() {
                for (var n in _notifications) {
                  n.isRead = true;
                }
              }),
              icon: const Icon(Icons.done_all_rounded, size: 18),
              label: Text('$unreadCount'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
              ),
            ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Incidentes'),
            Tab(text: 'Sistema'),
            Tab(text: 'Pánico'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(4, (tabIndex) {
          final filtered = _filterByTab(tabIndex);
          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.withValues(alpha: 0.08),
                    ),
                    child: Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey.shade400),
                  ),
                  const SizedBox(height: 16),
                  const Text('Sin notificaciones'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final notif = filtered[index];
              final color = _getColor(notif.type);

              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                builder: (ctx, v, child) => Opacity(
                  opacity: v,
                  child: Transform.translate(offset: Offset(0, 12 * (1 - v)), child: child),
                ),
                child: Dismissible(
                  key: Key(notif.id),
                  background: Container(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFF43A047)]),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.visibility_rounded, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => setState(() {
                    notif.isRead = true;
                  }),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? theme.cardColor
                          : (notif.type == 'pánico'
                              ? Colors.red.withValues(alpha: 0.06)
                              : theme.colorScheme.primary.withValues(alpha: 0.04)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: notif.isRead
                            ? theme.dividerColor.withValues(alpha: 0.06)
                            : (notif.type == 'pánico'
                                ? Colors.red.withValues(alpha: 0.2)
                                : theme.colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            color.withValues(alpha: 0.15),
                            color.withValues(alpha: 0.05),
                          ]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(_getIcon(notif.type), color: color, size: 20),
                      ),
                      title: Text(notif.title,
                          style: TextStyle(
                              fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 14)),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(notif.body,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            if (notif.zone.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(notif.zone,
                                    style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(notif.time,
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.grey.shade500, fontSize: 11)),
                          if (!notif.isRead) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: notif.type == 'pánico'
                                      ? [Colors.red, Colors.redAccent]
                                      : [AppColors.primaryBlue, AppColors.accentCyan],
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
                      onTap: () {
                        setState(() => notif.isRead = true);
                        context.push('/operator-notification-detail/${notif.id}');
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

class _Notif {
  final String id, title, body, type, time, zone;
  bool isRead;
  _Notif(this.id, this.title, this.body, this.type, this.time, this.zone, this.isRead);
}
