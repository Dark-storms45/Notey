import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';


// FFI type bindings — must match rnnoise.h exactly

typedef _RnnoiseCreateNative  = Pointer<Void> Function(Pointer<Void>);
typedef _RnnoiseCreateDart    = Pointer<Void> Function(Pointer<Void>);

typedef _RnnoiseDestroyNative = Void     Function(Pointer<Void>);
typedef _RnnoiseDestroyDart   = void     Function(Pointer<Void>);

// rnnoise_process_frame(state, output_pcm, input_pcm) -> voice_activity (float)
typedef _ProcessFrameNative   = Float    Function(Pointer<Void>, Pointer<Float>, Pointer<Float>);
typedef _ProcessFrameDart     = double   Function(Pointer<Void>, Pointer<Float>, Pointer<Float>);



enum AudioOutputFormat { m4a, mp3 }

class NoiseCancellationService {
  // rnnoise only works at 48 kHz, mono, and processes exactly 480 samples per frame
  static const int    _kSampleRate = 48000;
  static const int    _kChannels   = 1;
  static const int    _kFrameSize  = 480;

  late final DynamicLibrary    _lib;
  late final _RnnoiseCreateDart  _rnCreate;
  late final _RnnoiseDestroyDart _rnDestroy;
  late final _ProcessFrameDart   _rnProcessFrame;

  bool _initialized = false;


  // Lifecycle


  /// Must be called once before [processAudio].
  /// Throws [UnsupportedError] if the native library cannot be loaded.
  void initialize() {
    if (_initialized) return;
    try {
      _lib = Platform.isAndroid
          ? DynamicLibrary.open('librnnoise.so')
          : DynamicLibrary.open('librnnoise.dylib');

      _rnCreate = _lib.lookupFunction<_RnnoiseCreateNative, _RnnoiseCreateDart>(
          'rnnoise_create');
      _rnDestroy = _lib.lookupFunction<_RnnoiseDestroyNative, _RnnoiseDestroyDart>(
          'rnnoise_destroy');
      _rnProcessFrame = _lib.lookupFunction<_ProcessFrameNative, _ProcessFrameDart>(
          'rnnoise_process_frame');

      _initialized = true;
    } on ArgumentError catch (e) {
      throw UnsupportedError(
        'Failed to load librnnoise: $e\n'
            'Android: place librnnoise.so in android/app/src/main/jniLibs/<abi>/\n'
            'iOS:     add librnnoise.a to Runner → Frameworks in Xcode.',
      );
    }
  }

  void dispose() => _initialized = false;

  // Public API


  /// Denoises [inputPath] (any format FFmpeg can read: m4a, mp3, wav, …)
  /// and writes the result in [outputFormat] (default: m4a / AAC).
  ///
  /// Returns the path to the denoised output file.
  Future<String> processAudio(
      String inputPath, {
        AudioOutputFormat outputFormat = AudioOutputFormat.m4a,
      }) async {
    if (!_initialized) throw StateError('Call initialize() first.');
    if (!File(inputPath).existsSync()) {
      throw FileSystemException('Input file not found', inputPath);
    }

    final tmp = await getTemporaryDirectory();
    final ts  = DateTime.now().millisecondsSinceEpoch;

    // Step 1 — decode to raw PCM
    final rawPcmPath = '${tmp.path}/rnn_in_$ts.pcm';
    await _decodeToRawPcm(inputPath, rawPcmPath);

    // Step 2 — denoise in-memory with rnnoise
    final denoisedPcmPath = '${tmp.path}/rnn_out_$ts.pcm';
    await _runRnnoise(rawPcmPath, denoisedPcmPath);

    // Step 3 — re-encode to target format
    final ext        = outputFormat == AudioOutputFormat.m4a ? 'm4a' : 'mp3';
    final outputPath = '${tmp.path}/denoised_$ts.$ext';
    await _encodeFromRawPcm(denoisedPcmPath, outputPath, outputFormat);

    // Clean up intermediate PCM files
    await Future.wait([
      File(rawPcmPath).delete().catchError((_) {}),
      File(denoisedPcmPath).delete().catchError((_) {}),
    ]);

    return outputPath;
  }


  // Step 1 — Decode any input format → raw signed-16 PCM at 48 kHz mono


  Future<void> _decodeToRawPcm(String inputPath, String outputPath) async {
    // -ar 48000   resample to 48 kHz (rnnoise requirement)
    // -ac 1       downmix to mono
    // -f s16le    raw signed 16-bit little-endian PCM (no container)
    final cmd =
        '-y -i "$inputPath" -ar $_kSampleRate -ac $_kChannels -f s16le "$outputPath"';

    final session    = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg decode failed (rc=$returnCode):\n$logs');
    }
  }


  // Step 2 — Run rnnoise frame-by-frame on raw PCM


  Future<void> _runRnnoise(String inputPath, String outputPath) async {
    final inputBytes = await File(inputPath).readAsBytes();
    final totalSamples = inputBytes.length ~/ 2;

    // Convert little-endian int16 bytes → normalised float32 samples
    final byteData = inputBytes.buffer.asByteData();
    final floatSamples = Float32List(totalSamples);
    for (var i = 0; i < totalSamples; i++) {
      floatSamples[i] = byteData.getInt16(i * 2, Endian.little) / 32768.0;
    }

    // Allocate native frame buffers (reused across all frames)
    final inBuf  = calloc<Float>(_kFrameSize);
    final outBuf = calloc<Float>(_kFrameSize);

    // Create rnnoise state
    final state = _rnCreate(nullptr);
    if (state.address == 0) {
      calloc.free(inBuf);
      calloc.free(outBuf);
      throw StateError('rnnoise_create() returned null — out of native memory?');
    }

    final outputFloats = Float32List(totalSamples);
    var writeCursor = 0;

    try {
      for (var offset = 0;
      offset + _kFrameSize <= totalSamples;
      offset += _kFrameSize) {
        // Copy one frame into native memory
        for (var i = 0; i < _kFrameSize; i++) {
          inBuf[i] = floatSamples[offset + i];
        }

        // rnnoise_process_frame returns VAD probability (we ignore it here,
        // but you can expose it to mute silence frames if desired)
        _rnProcessFrame(state, outBuf, inBuf);

        // Copy result back to Dart
        for (var i = 0; i < _kFrameSize; i++) {
          outputFloats[writeCursor++] = outBuf[i];
        }
      }
      // Note: samples in the last partial frame (< 480) are dropped.
      // For typical voice recordings this is < 10 ms and inaudible.
    } finally {
      _rnDestroy(state);
      calloc.free(inBuf);
      calloc.free(outBuf);
    }

    // Convert normalised float32 → little-endian int16 bytes
    final outBytes = ByteData(writeCursor * 2);
    for (var i = 0; i < writeCursor; i++) {
      final clamped = outputFloats[i].clamp(-1.0, 1.0);
      outBytes.setInt16(i * 2, (clamped * 32767).round(), Endian.little);
    }

    await File(outputPath).writeAsBytes(outBytes.buffer.asUint8List());
  }

  // -------------------------------------------------------------------------
  // Step 3 — Re-encode raw PCM → m4a (AAC) or mp3
  // -------------------------------------------------------------------------

  Future<void> _encodeFromRawPcm(
      String inputPath,
      String outputPath,
      AudioOutputFormat format,
      ) async {
    // Tell FFmpeg the input is raw s16le PCM at 48 kHz mono (no container).
    // Then encode to the requested format.
    final codecArgs = format == AudioOutputFormat.m4a
        ? '-c:a aac -b:a 128k'   // AAC inside M4A/MP4 container
        : '-c:a libmp3lame -b:a 128k -id3v2_version 3';

    final cmd = '-y '
        '-f s16le -ar $_kSampleRate -ac $_kChannels -i "$inputPath" '
        '$codecArgs '
        '"$outputPath"';

    final session    = await FFmpegKit.execute(cmd);
    final returnCode = await session.getReturnCode();

    if (!ReturnCode.isSuccess(returnCode)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg encode failed (rc=$returnCode):\n$logs');
    }
  }
}