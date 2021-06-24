import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:data/vector.dart';
import 'package:data/type.dart';
import 'package:formant_extractor/audio_tools/audio.dart';
import 'package:formant_extractor/dsp_tools/speech.dart';
import 'package:formant_extractor/dsp_tools/window.dart';

class FormantExtractorScreen extends StatefulWidget {
  @override
  _FormantExtractorScreenState createState() => _FormantExtractorScreenState();
}

class _FormantExtractorScreenState extends State<FormantExtractorScreen> {
  List<double> pcmList = [0.0];
  List<double> formants = [0.0, 0.0];

  bool isRecording = false;
  bool formantsReady = false;
  Audio audio = Audio();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    Text('$formants'),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: MaterialButton(
                  child: Text(
                    isRecording ? 'Stop' : 'Record',
                  ),
                  onPressed: () {
                    switch (isRecording) {
                      case false:
                        audio.clear();
                        audio.record();
                        setState(() {
                          isRecording = true;
                        });
                        break;
                      case true:
                        audio.stop();

                        //Grabs the middle 1024 audio samples
                        List<double> newPCM = audio.getMidPCM(1024);

                        pcmList = newPCM;

                        setState(() {
                          isRecording = false;
                          formantsReady = true;
                        });
                        break;
                    }
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: MaterialButton(
                  child: Text(formantsReady ? 'Get Formants' : '...'),
                  onPressed: () {
                    Vector<double> pcmVector = Window.vectorize(pcmList);

                    Speech speech = Speech(pcmVector, samplingRate: audio.Fs);
                    speech.init();

                    setState(() {
                      formants = speech.formants;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
