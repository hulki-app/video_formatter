import 'dart:io';

void main(List<String> arguments) {
  print('Hello world! $arguments');
  Process.run(
    'ffmpeg',
    [
      '-i',
      'example.mkv',
      '-c',
      'copy',
      '-an',
      'example-nosound.mkv',
    ],
  );
}
