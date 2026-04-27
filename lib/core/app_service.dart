import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:speedometer/db/dao/journey_dao.dart';
import 'package:speedometer/provider/journey_provider.dart';

class AppService {
  static List<SingleChildWidget> provideMultiProviders() {
    return [ChangeNotifierProvider(create: (_) => JourneyProvider(dao: JourneyDao()))];
  }
}
