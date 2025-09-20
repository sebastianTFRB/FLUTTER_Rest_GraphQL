import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final client = ValueNotifier(
    GraphQLClient(
      link: HttpLink("https://countries.trevorblades.com/"),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(
    GraphQLProvider(
      client: client,
      child: CacheProvider(child: const MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "REST + GraphQL Demo",
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: "/",
      routes: {
        "/": (context) => const RestScreen(),
        "/graphql": (context) => const GraphQLScreen(),
      },
    );
  }
}

/// -------------------- REST --------------------
class RestScreen extends StatefulWidget {
  const RestScreen({super.key});

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  late Future<List<dynamic>> users;

  @override
  void initState() {
    super.initState();
    users = fetchUsers();
  }

  Future<List<dynamic>> fetchUsers() async {
    final response =
        await http.get(Uri.parse("https://jsonplaceholder.typicode.com/users"));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error al cargar usuarios");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("REST: Usuarios"),
        actions: [
          IconButton(
            icon: const Icon(Icons.public),
            onPressed: () => Navigator.pushNamed(context, "/graphql"),
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: users,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No hay datos"));
          }

          final data = snapshot.data!;
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              final user = data[index];
              return ListTile(
                title: Text(user["name"]),
                subtitle: Text(user["email"]),
              );
            },
          );
        },
      ),
    );
  }
}

/// -------------------- GRAPHQL --------------------
class GraphQLScreen extends StatelessWidget {
  const GraphQLScreen({super.key});

  final String query = """
    query {
      countries {
        code
        name
        capital
        emoji
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GraphQL: Países")),
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (result, {fetchMore, refetch}) {
          if (result.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (result.hasException) {
            return Center(child: Text("Error: ${result.exception.toString()}"));
          }

          final countries = result.data?['countries'] as List<dynamic>;

          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: (context, index) {
              final country = countries[index];
              return ListTile(
                leading: Text(country['emoji']),
                title: Text(country['name']),
                subtitle: Text("Capital: ${country['capital'] ?? 'N/A'}"),
                trailing: Text(country['code']),
              );
            },
          );
        },
      ),
    );
  }
}
