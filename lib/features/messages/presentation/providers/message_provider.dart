import 'package:xpress_nepal/core/services/api_service.dart';
import 'package:xpress_nepal/features/messages/data/repositories/message_repository_impl.dart';
import 'package:xpress_nepal/features/messages/domain/repositories/message_repository.dart';
import 'package:xpress_nepal/features/messages/presentation/view_model/message_view_model.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';

class MessageProvider {
  static MessageProvider? _instance;

  late final MessageRepository _repository;
  late final MessageViewModel _viewModel;

  MessageProvider._internal();

  static MessageProvider get instance {
    _instance ??= MessageProvider._internal();
    return _instance!;
  }

  Future<void> initialize() async {
    final apiService = ApiService();

    _repository = MessageRepositoryImpl(apiService: apiService);
    _viewModel = MessageViewModel(repository: _repository);

    // Load unread count if user is authenticated
    final authViewModel = AuthProvider.instance.authViewModel;
    if (authViewModel.state.user != null) {
      _viewModel.loadUnreadCount();
    }
  }

  MessageRepository get repository => _repository;
  MessageViewModel get viewModel => _viewModel;
}
