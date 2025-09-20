import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/launch.dart';

class GraphQLService {
  final GraphQLClient client;
  GraphQLService(this.client);

  Future<List<Launch>> fetchLaunches({int limit = 10}) async {
    const query = r'''
      query LaunchesPast($limit: Int!) {
        launchesPast(limit: $limit) {
          mission_name
          launch_date_utc
          rocket {
            rocket_name
          }
          links {
            mission_patch_small
          }
        }
      }
    ''';

    final options =
        QueryOptions(document: gql(query), variables: {'limit': limit});
    final result = await client.query(options);

    if (result.hasException) {
      throw Exception('GraphQL error: ${result.exception}');
    }

    final List list = result.data!['launchesPast'];
    return list.map((e) => Launch.fromGraphQL(e)).toList();
  }
}
