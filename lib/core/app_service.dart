import 'package:provider/single_child_widget.dart';

class AppService {
  static List<SingleChildWidget> provideMultiProviders() {
    return [
      // ChangeNotifierProvider(
      //   create: (_) => FoProvider(foDataSource: FoDataSource(apiClient), reportDao: _reportDao),
      // ),
    ];
  }
}
