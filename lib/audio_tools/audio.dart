import 'package:audio_streamer/audio_streamer.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';

//Example:
//Audio audio = Audio();
//audio.record();
//audio.stop();
//List<double> pcm = audio.getPCM();
//audio.clear();

//Sampling rate is 44,100Hz from using audio_streamer

class Audio {
  AudioStreamer _streamer = AudioStreamer();
  List<double> _audio = [];

  void _onAudio(List<double> buffer) {
    _audio.addAll(buffer);
  }

  void handleError(PlatformException error) {
    print(error.message);
    print(error.details);
  }

  //AudioStreamer.start() method uses stream.listen() which requires a parameter of a function(List)
  void record() async {
    try {
      //_onAudio is the function(List) used by stream.listen()
      //where the List will be populated with data
      _streamer.start(_onAudio, handleError);
    } catch (error) {
      print(error);
    }
  }

  void stop() async {
    await _streamer.stop();
  }

  //returns raw pressure wave values
  List<double> getPCM() {
    return _audio;
  }

  //returns middle raw pressure wave values
  List<double> getMidPCM(@required int samples) {
    int halfSamples = (samples / 2).round();
    int mid = (_audio.length / 2).round();

    return _audio.sublist(mid - halfSamples, mid + halfSamples);
  }

  void clear() {
    _audio = [];
  }

  //get sampling rate
  double get Fs {
    return AudioStreamer.sampleRate.toDouble();
  }
}
