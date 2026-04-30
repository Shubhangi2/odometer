import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:odometer/db/dao/journey_dao.dart';
import 'package:odometer/provider/journey_provider.dart';

class AppService {
  static List<SingleChildWidget> provideMultiProviders() {
    return [ChangeNotifierProvider(create: (_) => JourneyProvider(dao: JourneyDao()))];
  }
}
