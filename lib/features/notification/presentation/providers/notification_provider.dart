import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/notification/data/datasources/notification_remote_datasource_impl.dart';
import 'package:xpress_nepal/features/notification/data/repositories/notification_repository_impl.dart';
import 'package:xpress_nepal/features/notification/domain/repositories/notification_repository.dart';
import 'package:xpress_nepal/features/notification/presentation/view_model/notification_view_model.dart';

class NotificationProvider {
  static NotificationProvider? _instance;

  late final NotificationRepository _notificationRepository;
  late final NotificationViewModel _notificationViewModel;

  NotificationProvider._internal();

  static NotificationProvider get instance {
    _instance ??= NotificationProvider._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    final apiService = ApiService();

    final remoteDataSource = NotificationRemoteDataSourceImpl(
      apiService: apiService,
    );

    _notificationRepository = NotificationRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    _notificationViewModel = NotificationViewModel(
      repository: _notificationRepository,
    );
  }

  NotificationRepository get notificationRepository => _notificationRepository;
  NotificationViewModel get notificationViewModel => _notificationViewModel;
}
