import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:spend_io_app/features/insight/presentation/viewmodels/insight_viewmodel.dart';

class InsightModuleProvider {
  InsightModuleProvider._();

  static List<SingleChildWidget> get providers => [
        ChangeNotifierProvider<InsightViewModel>(
          create: (_) => InsightViewModel(),
        ),
      ];
}
