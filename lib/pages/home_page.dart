import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/launch.dart';
import '../services/rest_service.dart';
import '../services/graphql_service.dart';
import '../widgets/launch_list.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RestService restService = RestService();
  Future<List<Launch>>? restFuture;
  Future<List<Launch>>? gqlFuture;

  @override
  void initState() {
    super.initState();
    restFuture = restService.fetchLaunches(limit: 10);
    final client = GraphQLProvider.of(context).value;
    gqlFuture = GraphQLService(client).fetchLaunches(limit: 10);
  }

  Future<void> _refresh() async {
    setState(() {
      restFuture = restService.fetchLaunches(limit: 10);
      final client = GraphQLProvider.of(context).value;
      gqlFuture = GraphQLService(client).fetchLaunches(limit: 10);
    });
  }

  Widget _buildFuture(Future<List<Launch>>? future) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: FutureBuilder<List<Launch>>(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) return const Center(child: Text('No data'));
          return LaunchList(launches: data);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    gqlFuture ??=
        GraphQLService(GraphQLProvider.of(context).value).fetchLaunches(limit: 10);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SpaceX Demo"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "REST v3"),
              Tab(text: "GraphQL"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFuture(restFuture),
            _buildFuture(gqlFuture),
          ],
        ),
      ),
    );
  }
}
