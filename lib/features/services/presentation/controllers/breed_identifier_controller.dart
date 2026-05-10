import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/breed_identifier_repository.dart';

class BreedIdentifierState {

  const BreedIdentifierState({
    this.isLoading = false,
    this.result,
    this.error,
    this.selectedImage,
    this.history = const [],
  });
  final bool isLoading;
  final BreedScan? result;
  final String? error;
  final File? selectedImage;
  final List<BreedScan> history;

  BreedIdentifierState copyWith({
    bool? isLoading,
    BreedScan? result,
    String? error,
    File? selectedImage,
    List<BreedScan>? history,
    bool clearResult = false,
    bool clearError = false,
    bool clearImage = false,
  }) {
    return BreedIdentifierState(
      isLoading: isLoading ?? this.isLoading,
      result: clearResult ? null : (result ?? this.result),
      error: clearError ? null : (error ?? this.error),
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      history: history ?? this.history,
    );
  }
}

class BreedIdentifierNotifier extends Notifier<BreedIdentifierState> {
  final _picker = ImagePicker();
  final _repository = breedIdentifierRepository;

  @override
  BreedIdentifierState build() {
    _loadHistory();
    return const BreedIdentifierState();
  }

  Future<void> _loadHistory() async {
    try {
      final history = await _repository.fetchScanHistory();
      state = state.copyWith(history: history);
    } catch (e) {
      // Fail silently for history
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        state = state.copyWith(
          selectedImage: File(image.path),
          clearResult: true,
          clearError: true,
        );
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to pick image: $e');
    }
  }

  Future<void> identify() async {
    if (state.selectedImage == null) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.identifyBreed(state.selectedImage!.path);
      // Save to Supabase
      await _repository.saveScan(result);
      
      state = state.copyWith(
        isLoading: false,
        result: result,
        history: [result, ...state.history].take(10).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Identification failed. Please try again.',
      );
    }
  }

  void reset() {
    state = state.copyWith(
      clearImage: true,
      clearResult: true,
      clearError: true,
      isLoading: false,
    );
  }
}

final breedIdentifierProvider =
    NotifierProvider<BreedIdentifierNotifier, BreedIdentifierState>(
  BreedIdentifierNotifier.new,
);
