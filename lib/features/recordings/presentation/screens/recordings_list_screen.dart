import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider para grabaciones mock
final recordingsProvider = FutureProvider((ref) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final now = DateTime.now();
  return List.generate(12, (i) => _MockRecording(
    id: 'rec_$i',
    cameraName: ['Entrada Principal', 'Estacionamiento', 'Pasillo Norte', 'Patio Trasero'][i % 4],
    startTime: now.subtract(Duration(hours: i * 3)),
    duration: Duration(minutes: 5 + (i * 2)),
    eventType: i % 3 == 0 ? 'Movimiento' : i % 3 == 1 ? 'Intrusión' : null,
    thumbnailUrl: 'https://picsum.photos/320/180?random=$i',
  ));
});

class _MockRecording {
  final String id;
  final String cameraName;
  final DateTime startTime;
  final Duration duration;
  final String? eventType;
  final String thumbnailUrl;
  _MockRecording({required this.id, required this.cameraName, required this.startTime, required this.duration, this.eventType, required this.thumbnailUrl});
}

/// Pantalla de listado de grabaciones
class RecordingsListScreen extends ConsumerStatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  ConsumerState<RecordingsListScreen> createState() => _RecordingsListScreenState();
}

class _RecordingsListScreenState extends ConsumerState<RecordingsListScreen> {
  String _selectedFilter = 'Todas';
  final _filters = ['Todas', 'Hoy', '7 días', '30 días'];

  @override
  Widget build(BuildContext context) {
    final recordingsAsync = ref.watch(recordingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grabaciones'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilters(),
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Buscador de grabaciones')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _filters.map((f) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(f),
                  selected: _selectedFilter == f,
                  onSelected: (selected) => setState(() => _selectedFilter = f),
                ),
              )).toList(),
            ),
          ),

          Expanded(
            child: recordingsAsync.when(
              data: (recordings) {
                if (recordings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.videocam_off_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No hay grabaciones'),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recordings.length,
                  itemBuilder: (context, index) {
                    final rec = recordings[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => RecordingPlayerScreen(recordingId: rec.id)),
                          );
                        },
                        child: Row(
                          children: [
                            // Thumbnail
                            Container(
                              width: 120,
                              height: 80,
                              color: Colors.black,
                              child: Stack(
                                children: [
                                  Center(child: Icon(Icons.play_circle_outline, color: Colors.white.withOpacity(0.7), size: 36)),
                                  Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        '${rec.duration.inMinutes}:${(rec.duration.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: const TextStyle(color: Colors.white, fontSize: 11),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Info
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(rec.cameraName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${rec.startTime.day}/${rec.startTime.month} ${rec.startTime.hour}:${rec.startTime.minute.toString().padLeft(2, '0')}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                                    ),
                                    if (rec.eventType != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(rec.eventType!, style: const TextStyle(fontSize: 11, color: Colors.orange)),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(right: 8),
                              child: Icon(Icons.chevron_right, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filtros', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            const Text('Cámara'),
            Wrap(
              spacing: 8,
              children: ['Todas', 'Entrada', 'Estacionamiento', 'Pasillo'].map((c) => 
                FilterChip(label: Text(c), selected: c == 'Todas', onSelected: (_) {})).toList(),
            ),
            const SizedBox(height: 16),
            const Text('Tipo de evento'),
            Wrap(
              spacing: 8,
              children: ['Todos', 'Movimiento', 'Intrusión', 'Manual'].map((c) => 
                FilterChip(label: Text(c), selected: c == 'Todos', onSelected: (_) {})).toList(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Aplicar filtros')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reproductor de grabación
class RecordingPlayerScreen extends StatefulWidget {
  final String recordingId;
  const RecordingPlayerScreen({super.key, required this.recordingId});

  @override
  State<RecordingPlayerScreen> createState() => _RecordingPlayerScreenState();
}

class _RecordingPlayerScreenState extends State<RecordingPlayerScreen> {
  double _position = 0.3;
  bool _playing = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Reproductor'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'clip', child: ListTile(leading: Icon(Icons.content_cut), title: Text('Recortar clip'))),
              const PopupMenuItem(value: 'export', child: ListTile(leading: Icon(Icons.download), title: Text('Exportar'))),
              const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share), title: Text('Compartir'))),
              const PopupMenuItem(value: 'evidence', child: ListTile(leading: Icon(Icons.bookmark), title: Text('Marcar evidencia'))),
              const PopupMenuItem(value: 'tag', child: ListTile(leading: Icon(Icons.label), title: Text('Agregar etiqueta'))),
            ],
            onSelected: (value) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Acción: $value (simulado)')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Video placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.movie_outlined, size: 80, color: Colors.white.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text('Reproducción de grabación', style: TextStyle(color: Colors.white.withOpacity(0.7))),
                  Text('ID: ${widget.recordingId}', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
          ),

          // Controls
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.black87,
            child: Column(
              children: [
                // Timeline
                Row(
                  children: [
                    Text('01:23', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: _position,
                        onChanged: (v) => setState(() => _position = v),
                        activeColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Text('05:00', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ],
                ),
                // Play controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.replay_10, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 48),
                      onPressed: () => setState(() => _playing = !_playing),
                    ),
                    IconButton(
                      icon: const Icon(Icons.forward_10, color: Colors.white, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
