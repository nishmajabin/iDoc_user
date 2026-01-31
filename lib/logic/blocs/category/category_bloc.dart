import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:idoc_user/data/repostories/category_repository.dart';
import 'package:idoc_user/logic/blocs/category/category_event.dart';
import 'package:idoc_user/logic/blocs/category/category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repository;

  CategoryBloc(this._repository) : super(CategoryInitial()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<SubscribeToCategoriesEvent>(_onSubscribeToCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(CategoryLoading());
    try {
      final categories = await _repository.loadCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      emit(CategoryError('Failed to load categories: $e'));
    }
  }

  Future<void> _onSubscribeToCategories(
    SubscribeToCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    await emit.forEach(
      _repository.categoriesStream(),
      onData: (categories) => CategoryLoaded(categories),
      onError: (error, stackTrace) => CategoryError('Failed to load categories: $error'),
    );
  }
}