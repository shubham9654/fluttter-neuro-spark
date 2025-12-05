import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;

/// Speech to Text Service
class SpeechService {
  static final SpeechService _instance = SpeechService._internal();
  factory SpeechService() => _instance;
  SpeechService._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isInitialized = false;
  bool _isListening = false;
  bool _isStarting = false; // Prevent multiple simultaneous starts
  bool _hasTemporaryNetworkError = false; // Track temporary network errors

  // Callback storage for retry mechanism
  Function(String text)? _onResultCallback;
  Function()? _onDoneCallback;

  /// Initialize speech recognition
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Create status callback that properly tracks listening state
      void statusListener(String status) {
        debugPrint('Speech recognition status: $status');
        if (status == 'listening') {
          _isListening = true;
          _isStarting = false;
          _hasTemporaryNetworkError =
              false; // Reset error flag when listening resumes
        } else if (status == 'done' ||
            status == 'notListening' ||
            status == 'doneNoResult') {
          // Only stop if we don't have a temporary network error
          // Temporary network errors should allow recovery
          if (!_hasTemporaryNetworkError) {
            _isListening = false;
            _isStarting = false;
            debugPrint('Speech recognition stopped normally');
          } else {
            debugPrint(
              'Speech recognition status: $status (ignoring due to temporary network error - will retry)',
            );
            // Don't set _isListening = false, allow it to recover
          }
        }
      }

      // Enhanced error handler that doesn't cancel on temporary network errors
      void errorListener(error) {
        // Access error properties dynamically (errorMsg and permanent)
        final errorMsg = error.errorMsg?.toString() ?? error.toString();
        final permanent =
            error.permanent?.toString() == 'true' || error.permanent == true;

        debugPrint(
          'Speech recognition error: $errorMsg, permanent: $permanent',
        );

        // Only stop on permanent errors or non-network errors
        if (permanent || !errorMsg.contains('network')) {
          _isListening = false;
          _isStarting = false;
          debugPrint('Speech recognition stopped due to error: $errorMsg');
        } else {
          // For temporary network errors, set flag and try to restart
          _hasTemporaryNetworkError = true;
          debugPrint(
            'Temporary network error - speech recognition will retry automatically',
          );
          // Try to restart listening after a short delay
          _retryAfterNetworkError();
        }
      }

      // On web, initialize without permission request (browser handles it)
      if (kIsWeb) {
        _isInitialized = await _speech.initialize(
          onError: errorListener,
          onStatus: statusListener,
        );
        return _isInitialized;
      }

      // Request microphone permission for mobile platforms
      final status = await Permission.microphone.request();
      if (!status.isGranted) {
        debugPrint('Microphone permission denied');
        return false;
      }

      // Initialize speech to text
      _isInitialized = await _speech.initialize(
        onError: errorListener,
        onStatus: statusListener,
      );

      return _isInitialized;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Check if speech recognition is available
  bool get isAvailable => _isInitialized && _speech.isAvailable;

  /// Check if currently listening
  bool get isListening => _isListening;

  /// Retry listening after a temporary network error
  Future<void> _retryAfterNetworkError() async {
    if (!_hasTemporaryNetworkError || !_isInitialized) return;

    // Wait a bit before retrying
    await Future.delayed(const Duration(seconds: 2));

    // Only retry if we still have the error flag and callbacks are set
    if (_hasTemporaryNetworkError && _onResultCallback != null) {
      debugPrint('Retrying speech recognition after network error...');
      try {
        // Cancel current session first
        await _speech.cancel();
        await Future.delayed(const Duration(milliseconds: 500));

        // Restart listening
        final result = await _speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              _onResultCallback?.call(result.recognizedWords);
              _isListening = false;
              _isStarting = false;
              _hasTemporaryNetworkError = false;
              _onDoneCallback?.call();
            } else {
              _onResultCallback?.call(result.recognizedWords);
            }
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 5),
          localeId: 'en_US',
          cancelOnError: false,
          partialResults: true,
        );

        if (result == true || (result == null && kIsWeb)) {
          _hasTemporaryNetworkError = false;
          debugPrint('Successfully retried speech recognition');
        }
      } catch (e) {
        debugPrint('Error retrying speech recognition: $e');
        // If retry fails, stop trying
        _hasTemporaryNetworkError = false;
        _isListening = false;
      }
    }
  }

  /// Start listening for speech
  Future<bool> startListening({
    required Function(String text) onResult,
    Function()? onDone,
  }) async {
    // Prevent multiple simultaneous starts
    if (_isStarting) {
      debugPrint('Speech recognition is already starting, please wait...');
      return false;
    }

    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        return false;
      }
    }

    if (!_speech.isAvailable) {
      debugPrint('Speech recognition not available');
      return false;
    }

    // If already listening, stop first and wait a bit
    if (_isListening) {
      debugPrint('Stopping existing speech recognition session...');
      await stopListening();
      // Wait a moment for the stop to complete
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _isStarting = true;

    try {
      // Store callbacks for retry mechanism
      _onResultCallback = onResult;
      _onDoneCallback = onDone;

      // Start listening - handle nullable return value (listen() returns Future<bool?>)
      // On web, this may return null even when it successfully starts
      // Set cancelOnError to false so temporary network errors don't stop recognition
      final listeningResult = await _speech.listen(
        onResult: (result) {
          if (result.finalResult) {
            onResult(result.recognizedWords);
            _isListening = false;
            _isStarting = false;
            _hasTemporaryNetworkError = false;
            onDone?.call();
          } else {
            // Update text in real-time as user speaks
            onResult(result.recognizedWords);
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(
          seconds: 5,
        ), // Increased pause time for better reliability
        localeId: 'en_US',
        cancelOnError: false, // Don't cancel on temporary errors
        partialResults: true,
      );

      // On web, listen() may return null even when it successfully starts
      // We'll rely on the status callback to set _isListening = true
      // Give it a moment to start and check status
      if (listeningResult == null && kIsWeb) {
        // Wait a bit for the status callback to fire
        await Future.delayed(const Duration(milliseconds: 500));
        // If status callback set _isListening, we're good
        if (_isListening) {
          debugPrint('Speech recognition started successfully (web)');
          return true;
        }
      } else {
        _isListening = listeningResult ?? false;
      }

      if (!_isListening) {
        debugPrint(
          'Failed to start listening - speech recognition returned false or null',
        );
        if (kIsWeb) {
          debugPrint(
            'On web: Make sure microphone permission is granted in browser settings',
          );
        }
        _isStarting = false;
      }

      return _isListening;
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      _isListening = false;
      _isStarting = false;
      return false;
    }
  }

  /// Stop listening
  Future<void> stopListening() async {
    if (_isListening || _isStarting) {
      try {
        await _speech.stop();
      } catch (e) {
        debugPrint('Error stopping speech recognition: $e');
      }
      _isListening = false;
      _isStarting = false;
      _hasTemporaryNetworkError = false;
      _onResultCallback = null;
      _onDoneCallback = null;
    }
  }

  /// Cancel listening
  Future<void> cancel() async {
    if (_isListening || _isStarting) {
      try {
        await _speech.cancel();
      } catch (e) {
        debugPrint('Error canceling speech recognition: $e');
      }
      _isListening = false;
      _isStarting = false;
      _hasTemporaryNetworkError = false;
      _onResultCallback = null;
      _onDoneCallback = null;
    }
  }

  /// Dispose resources
  void dispose() {
    _speech.cancel();
    _isListening = false;
  }
}
