import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';

/// Centro de notificaciones in-app — Premium
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notifications = [
    _MockNotif(id: '1', title: 'Alerta de intrusión', body: 'Movimiento detectado en Entrada Principal', type: 'alert', time: '5 min', isRead: false),
    _MockNotif(id: '2', title: 'Cámara offline', body: 'Pasillo Norte se ha desconectado', type: 'camera', time: '15 min', isRead: false),
    _MockNotif(id: '3', title: 'Alerta crítica', body: 'Posible incendio detectado en Recepción', type: 'alert', time: '30 min', isRead: true),
    _MockNotif(id: '4', title: 'Sistema actualizado', body: 'GuardIA v1.1 disponible', type: 'system', time: '1h', isRead: true),
    _MockNotif(id: '5', title: 'Alerta de movimiento', body: 'Movimiento en Estacionamiento', type: 'alert', time: '2h', isRead: true),
    _MockNotif(id: '6', title: 'Cámara restaurada', body: 'Salida Emergencia vuelve en línea', type: 'camera', time: '3h', isRead: true),
    _MockNotif(id: '7', title: 'Mantenimiento programado', body: 'Cámaras de Zona B tendrán mantenimiento mañana', type: 'system', time: '5h', isRead: true),
  ];

  void _markAllRead() {
    setState(() { for (var n in _notifications) n.isRead = true; });
  }

  IconData _getIcon(String type) => switch (type) {
    'alert' => Icons.warning_amber_rounded,
    'camera' => Icons.videocam,
    'system' => Icons.info_outline,
    'panic' => Icons.emergency,
    _ => Icons.notifications,
  };

  Color _getColor(String type) => switch (type) {
    'alert' => Colors.orange,
    'camera' => AppColors.primaryBlue,
    'system' => Colors.grey,
    'panic' => Colors.red,
    _ => AppColors.primaryBlue,
  };

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: _markAllRead,
              icon: const Icon(Icons.done_all, size: 18),
              label: Text('$unreadCount'),
              style: TextButton.styleFrom(
                foregroundColor: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: isDark ? AppColors.accentCyan : AppColors.primaryBlue,
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationPreferencesScreen())),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notif = _notifications[index];
                final color = _getColor(notif.type);
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 350 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (ctx, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 15 * (1 - v)), child: child)),
                  child: Dismissible(
                    key: Key(notif.id),
                    background: Container(
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Colors.transparent, Color(0xFFE53935)]), borderRadius: BorderRadius.circular(12)),
                      alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => setState(() => _notifications.removeAt(index)),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                      decoration: BoxDecoration(
                        color: notif.isRead ? theme.cardColor : theme.colorScheme.primary.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: notif.isRead ? theme.dividerColor.withValues(alpha: 0.06) : theme.colorScheme.primary.withValues(alpha: 0.1)),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        leading: Container(
                          width: 42, height: 42,
                          decoration: BoxDecoration(gradient: LinearGradient(colors: [color.withValues(alpha: 0.15), color.withValues(alpha: 0.05)]), borderRadius: BorderRadius.circular(12)),
                          child: Icon(_getIcon(notif.type), color: color, size: 20),
                        ),
                        title: Text(notif.title, style: TextStyle(fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold, fontSize: 14)),
                        subtitle: Padding(padding: const EdgeInsets.only(top: 2), child: Text(notif.body, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12))),
                        trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                          Text(notif.time, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey.shade500, fontSize: 11)),
                          if (!notif.isRead) ...[
                            const SizedBox(height: 4),
                            Container(width: 8, height: 8, decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primaryBlue, AppColors.accentCyan]), shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.primaryBlue.withValues(alpha: 0.4), blurRadius: 4)])),
                          ],
                        ]),
                        onTap: () => setState(() => notif.isRead = true),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.grey.withValues(alpha: 0.08)),
      child: Icon(Icons.notifications_off_outlined, size: 52, color: Colors.grey.shade400)),
    const SizedBox(height: 16), const Text('No hay notificaciones'),
  ]));
}

class _MockNotif {
  final String id, title, body, type, time;
  bool isRead;
  _MockNotif({required this.id, required this.title, required this.body, required this.type, required this.time, required this.isRead});
}

/// Preferencias de notificación
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});
  @override
  State<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends State<NotificationPreferencesScreen> {
  bool _intrusion = true, _person = true, _fire = true, _panic = true, _cameraOffline = true, _system = false, _dnd = false;
  TimeOfDay _dndStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _dndEnd = const TimeOfDay(hour: 7, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferencias', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
        const SizedBox(height: 8),
        _sectionTitle('Tipos de alerta', Icons.warning_amber_rounded, Colors.orange),
        const SizedBox(height: 8),
        _groupCard([
          SwitchListTile(title: const Text('Intrusión'), subtitle: const Text('Acceso no autorizado'), value: _intrusion, onChanged: (v) => setState(() => _intrusion = v)),
          SwitchListTile(title: const Text('Persona detectada'), subtitle: const Text('Detección de personas'), value: _person, onChanged: (v) => setState(() => _person = v)),
          SwitchListTile(title: const Text('Incendio'), subtitle: const Text('Detección de fuego/humo'), value: _fire, onChanged: (v) => setState(() => _fire = v)),
          SwitchListTile(title: const Text('Pánico'), subtitle: const Text('Alertas de pánico'), value: _panic, onChanged: (v) => setState(() => _panic = v)),
          SwitchListTile(title: const Text('Cámara desconectada'), subtitle: const Text('Cuando una cámara se desconecta'), value: _cameraOffline, onChanged: (v) => setState(() => _cameraOffline = v)),
          SwitchListTile(title: const Text('Sistema'), subtitle: const Text('Actualizaciones'), value: _system, onChanged: (v) => setState(() => _system = v)),
        ]),
        const SizedBox(height: 20),
        _sectionTitle('No molestar', Icons.do_not_disturb_on_outlined, Colors.red),
        const SizedBox(height: 8),
        _groupCard([
          SwitchListTile(title: const Text('Modo No Molestar'), subtitle: Text(_dnd ? '${_dndStart.format(context)} - ${_dndEnd.format(context)}' : 'Desactivado'), value: _dnd, onChanged: (v) => setState(() => _dnd = v)),
          if (_dnd) ...[
            ListTile(title: const Text('Hora de inicio'), trailing: Text(_dndStart.format(context)), onTap: () async { final t = await showTimePicker(context: context, initialTime: _dndStart); if (t != null) setState(() => _dndStart = t); }),
            ListTile(title: const Text('Hora de fin'), trailing: Text(_dndEnd.format(context)), onTap: () async { final t = await showTimePicker(context: context, initialTime: _dndEnd); if (t != null) setState(() => _dndEnd = t); }),
          ],
        ]),
        const SizedBox(height: 20),
        _sectionTitle('Canales', Icons.send_outlined, AppColors.primaryBlue),
        const SizedBox(height: 8),
        _groupCard([
          const SwitchListTile(title: Text('Push'), subtitle: Text('Notificaciones push'), value: true, onChanged: null),
          SwitchListTile(title: const Text('Correo electrónico'), subtitle: const Text('Resumen por email'), value: false, onChanged: (v) {}),
        ]),
        const SizedBox(height: 30),
      ]),
    );
  }

  Widget _sectionTitle(String t, IconData icon, Color color) => Row(children: [
    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 16, color: color)),
    const SizedBox(width: 8),
    Text(t, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: color)),
  ]);

  Widget _groupCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.08)),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))]),
    child: Column(children: children),
  );
}
