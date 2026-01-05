
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo_item.dart';
import '../repositories/todo_repository.dart';
import '../services/data_persistence_service.dart';
import 'user_state.dart';

class TodoState {
  final List<TodoItem> todos;
  final bool isLoading;
  final String? error;

  TodoState({
    this.todos = const [],
    this.isLoading = false,
    this.error,
  });

  TodoState copyWith({
    List<TodoItem>? todos,
    bool? isLoading,
    String? error,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  List<TodoItem> get activeTodos =>
      todos.where((t) => !t.isCompleted).toList();
  
  List<TodoItem> get completedTodos =>
      todos.where((t) => t.isCompleted).toList();
}

class TodoNotifier extends Notifier<TodoState> {
  StreamSubscription<List<TodoItem>>? _streamSubscription;

  @override
  TodoState build() {
    final userId = ref.watch(currentUserIdProvider);
    
    // Clean up previous subscription when provider is disposed or rebuilt
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });

    if (userId != null) {
      // Use microtask to avoid side effects during build, or just start listening
      // Ideally we shouldn't do side effects in build, but setting up a listener is a common pattern if not fully reactive
      // Better pattern: use an effect-style logic
      _setupStream(userId);
    } 
    
    return TodoState(isLoading: userId != null);
  }

  Future<void> _setupStream(String userId) async {
    // Cancel existing subscription to be safe
    await _streamSubscription?.cancel();
    
    // Set loading state initially if not already set (though we did in build)
    // We cannot construct state here synchronously if it's called from build directly efficiently without microtask
    // But since we are in a microtask/async method:
    
    try {
      _streamSubscription = TodoRepository.getTodosStream(userId).listen((todos) {
        state = state.copyWith(todos: todos, isLoading: false);
      }, onError: (e) {
        state = state.copyWith(isLoading: false, error: e.toString());
      });
    } catch (e) {
        // If stream setup fails synchronously
        state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addTodo(String title) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final newItem = TodoItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Optimistic update
    final currentTodos = List<TodoItem>.from(state.todos);
    state = state.copyWith(
      todos: [newItem, ...currentTodos],
    );

    try {
      await DataPersistenceService.saveTodoItem(userId, newItem);
    } catch (e) {
      state = state.copyWith(error: "Failed to save todo");
      // Revert if highly critical, but offline queue handles it usually
    }
  }

  Future<void> toggleTodo(String todoId, bool? value) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null || value == null) return;

    final index = state.todos.indexWhere((t) => t.id == todoId);
    if (index == -1) return;

    final item = state.todos[index];
    final updatedItem = item.copyWith(
      isCompleted: value,
      updatedAt: DateTime.now(),
    );

    // Optimistic update
    final updatedTodos = List<TodoItem>.from(state.todos);
    updatedTodos[index] = updatedItem;
    state = state.copyWith(todos: updatedTodos);

    try {
      await DataPersistenceService.saveTodoItem(userId, updatedItem);
    } catch (e) {
      state = state.copyWith(error: "Failed to update todo");
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    // Optimistic update
    final currentTodos = List<TodoItem>.from(state.todos);
    currentTodos.removeWhere((t) => t.id == todoId);
    state = state.copyWith(todos: currentTodos);

    try {
      await DataPersistenceService.deleteTodoItem(userId, todoId);
    } catch (e) {
      state = state.copyWith(error: "Failed to delete todo");
    }
  }
}

final todoProvider = NotifierProvider<TodoNotifier, TodoState>(TodoNotifier.new);
