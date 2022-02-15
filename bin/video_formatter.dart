import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';

Future<void> main() async {
  exitCode = 2;

  stdout.writeln("Convert videos to hulki's applications");

  final resourcesDirectory = Directory('res/');
  if (!resourcesDirectory.existsSync()) {
    exitCode = 3;
    stdout.writeln(
      'No resources were found in the expected path: ${resourcesDirectory.path}. '
      'Try to provide at least one video to be formatted and try again.',
    );
  }

  final outputDirectory = Directory('output/');
  if (outputDirectory.existsSync()) {
    stdout.writeln('Deleting old generated output...');
    outputDirectory.deleteSync(recursive: true);
  }
  outputDirectory.createSync();

  final stopwatch = Stopwatch()..start();

  stdout.writeln();
  stdout.writeln('Formatting videos:');

  final files = resourcesDirectory.listSync();
  final quantity = files.length;

  for (final file in files) {
    stdout.writeln('[${files.indexOf(file) + 1}/$quantity] Processing video ${basename(file.path)}...');
    stdout.writeln('Command: ffmpeg -i ${file.path} -preset veryslow -vf scale=720:-1,setsar=1:1 -crf 18 -r 30 -an ${outputDirectory.path}${basenameWithoutExtension(file.path)}.mp4');
    stdout.writeln();

    await Process.run(
      'ffmpeg',
      [
        '-i',
        file.path,
        '-preset', // Prefers to wait a little bit in order to compress as much as possible.
        'veryslow',
        '-vf', // Sets a simple video filter, re-sizing but keeping the original aspect ratio.
        'scale=720:-1,setsar=1:1',
        '-crf', // Sets a constant rate factor, which can be set as 0-51, being 18 a reasonable factor.
        '18',
        '-r', // Sets 30 frames per second.
        '30',
        '-an', // By the end, removes the audio.
        '${outputDirectory.path}${basenameWithoutExtension(file.path)}.mp4',
      ],
      runInShell: true,
    );
    // TODO(victor-tinoco): Add watermark overlay.
    // -i logo.png -filter_complex "overlay=24:H-h-24"
  }

  stopwatch.stop();

  final timeSpent = stopwatch.elapsed.inSeconds;
  stdout.writeln('Videos formatted successfully! ($quantity video${quantity == 1 ? '' : 's'})"');
  stdout.writeln('Time spent: $timeSpent seconds. Mean: an average of ${timeSpent / files.length} seconds per video.');
}
