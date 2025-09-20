import 'package:flutter/material.dart';
import '../models/launch.dart';

class LaunchList extends StatelessWidget {
  final List<Launch> launches;
  const LaunchList({super.key, required this.launches});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: launches.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final l = launches[i];
        return ListTile(
          leading: l.patch != null
              ? Image.network(l.patch!, width: 56, height: 56)
              : const Icon(Icons.rocket_launch, size: 40),
          title: Text(l.missionName),
          subtitle: Text(
              '${l.rocketName} • ${l.dateUtc.toLocal().toString().split(".")[0]}'),
        );
      },
    );
  }
}
