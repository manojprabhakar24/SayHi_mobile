import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
import '../helper/imports/common_import.dart';
import '../manager/player_manager.dart';

class AudioProgressBar extends StatelessWidget {
  final String id;
  final PlayerManager _playerManager = Get.find();

  AudioProgressBar({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    PlayerController controller = PlayerController(); // Initialise

    return Obx(() {
      // return RectangleWaveform(
      //   absolute: false,
      //   isCentered: true,
      //   isRoundedRectangle: true,
      //   maxDuration:
      //       _playerManager.progress.value?.total ?? const Duration(seconds: 10),
      //   elapsedDuration: _playerManager.currentlyPlayingAudio.value?.id == id
      //       ? _playerManager.progress.value?.current ??
      //           const Duration(seconds: 0)
      //       : const Duration(seconds: 0),
      //   samples: [
      //     0.000334539741743356,
      //     0.0008155073737725616,
      //     0.000859332736581564,
      //     0.00882363598793745,
      //     0.008718332275748253,
      //     0.0026952726766467094,
      //     0.010043848305940628,
      //     0.005785253830254078,
      //     0.0005129867349751294,
      //     0.01180714089423418,
      //     0.010026838630437851,
      //     0.0005359557108022273,
      //     0.008173611015081406,
      //     0.009548107162117958,
      //     0.0068194009363651276,
      //     0.000503065821249038,
      //     0.011409325525164604,
      //     0.006654234137386084,
      //     0.009096886962652206,
      //     0.0031717438250780106,
      //     0.01069589052349329,
      //     0.012241747230291367,
      //     0.012367919087409973,
      //     0.003417382948100567,
      //     0.013123719021677971,
      //     0.0005256921285763383,
      //     0.0003902700846083462,
      //     0.005757893435657024,
      //     0.0005418111104518175,
      //     0.0005343228694982827,
      //     0.0004495384346228093,
      //     0.0003393568913452327,
      //     0.0003399818670004606,
      //     0.0004144745762459934,
      //     0.00702504301443696,
      //     0.00037347141187638044,
      //     0.00982236210256815,
      //     0.011189162731170654,
      //     0.011156219989061356,
      //     0.0011637506540864706,
      //     0.010249845683574677,
      //     0.00912818405777216,
      //     0.010305823758244514,
      //     0.004836554639041424,
      //     0.008452271111309528,
      //     0.0012179937912151217,
      //     0.015451265498995781,
      //     0.0008390175644308329,
      //     0.0005328430561348796,
      //     0.0008466881117783487
      //   ],
      //   height: 40,
      //   width: Get.width - (4 * DesignConstants.horizontalPadding),
      // );
      // return AudioFileWaveforms(
      //   size: Size(MediaQuery.of(context).size.width, 100.0),
      //   playerController: controller,
      //   enableSeekGesture: true,
      //   waveformType: WaveformType.fitWidth,
      //   waveformData: [
      //     0.002098237397149205,
      //     0.0018186424858868122,
      //     0.031676363199949265,
      //     0.011073856614530087,
      //     0.0014548578765243292,
      //     0.0015182773349806666,
      //     0.0024125687777996063,
      //     0.0018156523583456874,
      //     0.017495378851890564,
      //     0.0017493696650490165,
      //     0.001999928615987301,
      //     0.0028484768699854612,
      //     0.0019047707319259644,
      //     0.002049669623374939,
      //     0.0023049674928188324,
      //     0.002093550283461809,
      //     0.0022261478006839752,
      //     0.0021796245127916336,
      //     0.0017263606423512101,
      //     0.0013146469136700034,
      //     0.001230272464454174,
      //     0.0011193573009222746,
      //     0.0010679240804165602,
      //     0.0011077625676989555,
      //     0.001172542106360197,
      //     0.001137267448939383,
      //     0.03219274803996086,
      //     0.001960724126547575,
      //     0.02059565670788288,
      //     0.015963904559612274,
      //     0.0011478058295324445,
      //     0.06389107555150986,
      //     0.0026938938535749912,
      //     0.0011756370076909661,
      //     0.0010673693614080548,
      //     0.0011274361750110984,
      //     0.020440449938178062,
      //     0.00893546175211668,
      //     0.001128875883296132,
      //     0.021880751475691795,
      //     0.0014625079929828644,
      //     0.02597033604979515,
      //     0.020958922803401947,
      //     0.00120425911154598,
      //     0.0011288260575383902,
      //     0.0011745650554075837,
      //     0.0011368104023858905,
      //     0.0011720166075974703,
      //     0.0011302486527711153,
      //     0.0014310907572507858
      //   ],
      //   playerWaveStyle: PlayerWaveStyle(
      //     fixedWaveColor: AppColorConstants.themeColor,
      //     liveWaveColor: Colors.blueAccent,
      //     spacing: 6,
      //   ),
      // );
      return ProgressBar(
        thumbColor: AppColorConstants.themeColor.darken(),
        progressBarColor: AppColorConstants.iconColor,
        baseBarColor: AppColorConstants.backgroundColor.lighten(),
        thumbRadius: 8,
        barHeight: 2,
        progress: _playerManager.currentlyPlayingAudio.value?.id == id
            ? _playerManager.progress.value?.current ??
                const Duration(seconds: 0)
            : const Duration(seconds: 0),
        // buffered: value.buffered,
        total:
            _playerManager.progress.value?.total ?? const Duration(seconds: 0),
        timeLabelPadding: 5,
        timeLabelTextStyle: TextStyle(
            fontSize: FontSizes.b4,
            fontWeight: TextWeight.bold,
            color: AppColorConstants.mainTextColor),
        onDragUpdate: (detail) {
          _playerManager.pauseAudio();
          _playerManager
              .updateProgress(Duration(seconds: detail.timeStamp.inSeconds));
        },
        onDragEnd: () {
          // _playerManager.playAudio(audio);
        },
        // onSeek: pageManager.seek,
      );
    });
  }
}
