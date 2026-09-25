import 'dart:ffi';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:rive/rive.dart';
import 'package:rive/src/rive_core/component.dart';
import 'package:rive/src/rive_core/transform_component.dart';
import 'package:rive/src/rive_core/animation/keyframe_double.dart';

const rivPath = 'assets/academe/mascot/animations/pebby.riv';
const outDir = 'build/pebby_rive_frames';
const size = 440.0;

const expectedStates = [
  'idle', 'wave', 'think', 'cheer', 'sleep', 'sad', 'wow', 'determined',
  'confused', 'happy', 'excited', 'laughing', 'proud', 'loved', 'surprised',
  'tired', 'shy', 'focused', 'act_achieved', 'act_highfive', 'act_idea',
  'act_reading', 'act_solving', 'act_studying', 'adaptive', 'chat', 'cta',
  'hero', 'mastery', 'practice', 'upload', 'studying', 'turn_front',
  'turn_back', 'turn_side', 'turn_three_quarter', 'turn_three_quarter_back',
  'cheering', 'peek_left', 'peek_right', 'dissolve_in', 'dissolve_out', 'summon',
  'encourage', 'celebrate_small', 'celebrate_big', 'sleepy',
  'thinking', 'sleeping', 'celebrate', 'cover_eyes',
];

/// ids that reuse another state's animation, so they carry no clip of their own
const aliases = {'thinking': 'think', 'sleeping': 'sleep', 'celebrate': 'celebrate_big'};

/// every id the design system pins down at academe.cc/design/character
const designSystemIds = [
  // expressions, 16 faces
  'happy', 'laughing', 'excited', 'cheering', 'thinking', 'focused', 'confused',
  'surprised', 'proud', 'shy', 'tired', 'determined', 'sad', 'sleeping', 'loved', 'wow',
  // in action, 6 study moments
  'act_reading', 'act_studying', 'act_idea', 'act_solving', 'act_achieved', 'act_highfive',
  // turnaround, 5 angles
  'turn_front', 'turn_three_quarter', 'turn_side', 'turn_back', 'turn_three_quarter_back',
  // motion, the stable state ids
  'idle', 'wave', 'think', 'encourage', 'celebrate_small', 'celebrate_big', 'wow', 'sleepy',
];
const oneShots = ['surprised', 'dissolve_in', 'dissolve_out', 'summon'];
const rigLayers = [
  'body', 'face', 'eyeL', 'eyeR', 'eyeLdot', 'eyeRdot', 'browL', 'browR',
  'mouth', 'tongue', 'tuftL', 'tuftR', 'armL', 'armR', 'footL', 'footR',
  'shadow', 'head', 'motion', 'root',
  'armLUpper', 'armLFore', 'armRUpper', 'armRFore',
];

String? _fw(String name) {
  final d = Directory('build/macos/Build/Products');
  if (!d.existsSync()) return null;
  for (final c in d.listSync().whereType<Directory>()) {
    for (final a in c.listSync().whereType<Directory>()) {
      if (!a.path.endsWith('.app')) continue;
      final f = File('${a.path}/Contents/Frameworks/$name.framework/Versions/A/$name');
      if (f.existsSync()) return f.path;
    }
  }
  return null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final flu = _fw('FlutterMacOS');
  final riv = _fw('rive_common');
  final canRun = flu != null && riv != null;
  if (canRun) {
    DynamicLibrary.open(flu);
    DynamicLibrary.open(riv);
  }
  const skip = 'run `flutter build macos --debug` once so flutter_tester can '
      'dlopen the rive_common plugin';

  late Artboard board;
  setUpAll(() async {
    if (!canRun) return;
    final bytes = await File(rivPath).readAsBytes();
    board = RiveFile.import(ByteData.sublistView(bytes)).mainArtboard;
  });

  test('rig: every named layer, parented through head/motion/root', () {
    expect(board.name, 'Pebby');
    expect(board.width, size);
    expect(board.height, size);
    final comps =
        (board as RuntimeArtboard).objects.whereType<Component>().toList();
    final names = comps.map((c) => c.name).toSet();
    for (final n in rigLayers) {
      expect(names, contains(n), reason: 'rig layer missing: $n');
    }
    Component find(String n) => comps.firstWhere((c) => c.name == n);
    expect(find('motion').parent?.name, 'root');
    expect(find('head').parent?.name, 'motion');
    for (final n in ['face', 'eyeL', 'eyeR', 'eyeLdot', 'eyeRdot', 'browL',
                     'browR', 'mouth', 'tongue']) {
      expect(find(n).parent?.name, 'head', reason: '$n should ride the head');
    }
    for (final n in ['body', 'armL', 'armR', 'footL', 'footR', 'tuftL',
                     'tuftR', 'shadow', 'armLUpper', 'armRUpper']) {
      expect(find(n).parent?.name, 'motion', reason: '$n should sit on motion');
    }
    expect(find('armLFore').parent?.name, 'armLUpper');
    expect(find('armRFore').parent?.name, 'armRUpper');
  }, skip: canRun ? null : skip);

  test('every design-system id is a pose', () {
    for (final id in designSystemIds) {
      expect(expectedStates, contains(id), reason: 'design system id missing: $id');
    }
  }, skip: canRun ? null : skip);

  test('50 poses at 12fps, long loops, one-shots marked', () {
    final anims = board.animations.whereType<LinearAnimation>().toList();
    final names = anims.map((a) => a.name).toList();
    final own = expectedStates.where((s) => !aliases.containsKey(s)).toList();
    expect(names.sublist(0, own.length), own);
    expect(names, contains('idle_static'));
    expect(names, contains('appear_hidden'));
    expect(names, contains('appear_shown'));
    for (final a in anims) {
      expect(a.fps, 12);
      expect(a.duration, greaterThan(0));
      expect(a.keyedObjects, isNotEmpty, reason: '${a.name} has no keys');
    }
    for (final n in oneShots) {
      expect(anims.firstWhere((a) => a.name == n).loop, Loop.oneShot,
          reason: '$n should be a one-shot');
    }
    // the brand rule is not to squash the body: whole-character scale stays
    // within a few percent of 1, however lively the state is
    final objects = (board as RuntimeArtboard).objects.toList();
    int? idOf(String name) {
      for (var i = 0; i < objects.length; i++) {
        final o = objects[i];
        if (o is Component && o.name == name) return i;
      }
      return null;
    }
    final motionId = idOf('motion');
    expect(motionId, isNotNull);
    for (final n in ['cheer', 'excited', 'celebrate_big', 'laughing', 'wow',
                     'surprised', 'act_achieved', 'loved', 'celebrate_small']) {
      final a = anims.firstWhere((x) => x.name == n);
      for (final ko in a.keyedObjects.where((k) => k.objectId == motionId)) {
        for (final kp in ko.keyedProperties) {
          if (kp.propertyKey != 16 && kp.propertyKey != 17) continue;
          for (final kf in kp.keyframes.whereType<KeyFrameDouble>()) {
            expect(kf.value, inInclusiveRange(0.94, 1.07),
                reason: '$n scales the body past the brand limit');
          }
        }
      }
    }
    // the ambient states run long enough not to read as a loop
    for (final n in ['idle', 'sleep', 'tired', 'adaptive', 'hero']) {
      final a = anims.firstWhere((x) => x.name == n);
      expect(a.duration / a.fps, greaterThanOrEqualTo(12.0),
          reason: '$n loop is too short to hide its repeat');
    }
    // no two neighbouring loops share a period, so states never march in step
    final loops = ['idle', 'happy', 'hero', 'adaptive', 'proud'];
    final periods = loops.map((n) =>
        anims.firstWhere((x) => x.name == n).duration).toSet();
    expect(periods.length, loops.length);
  }, skip: canRun ? null : skip);

  test('12fps authoring still moves on every display frame', () {
    final inst = board.instance();
    final ctrl = StateMachineController.fromArtboard(inst, 'PebbySM')!;
    inst.addController(ctrl);
    ctrl.findInput<double>('pose')!.value = 0;
    double headRot() => (inst as RuntimeArtboard)
        .objects
        .whereType<TransformComponent>()
        .firstWhere((o) => o.name == 'head')
        .rotation;
    for (final hz in [60, 120]) {
      inst.advance(0.5);
      final vals = <double>[];
      for (var i = 0; i < hz * 2; i++) {
        inst.advance(1 / hz);
        vals.add(headRot());
      }
      var repeated = 0;
      for (var i = 1; i < vals.length; i++) {
        if ((vals[i] - vals[i - 1]).abs() < 1e-9) repeated++;
      }
      expect(repeated, 0,
          reason: 'a 12fps clip must interpolate on every frame at ${hz}Hz, '
              'not step');
    }
  }, skip: canRun ? null : skip);

  test('turnaround: the face leaves to the left and the rear angles show none',
      () async {
    final inst = board.instance();
    final ctrl = StateMachineController.fromArtboard(inst, 'PebbySM')!;
    inst.addController(ctrl);
    final pose = ctrl.findInput<double>('pose')!;
    double faceX() => (inst as RuntimeArtboard)
        .objects
        .whereType<TransformComponent>()
        .firstWhere((o) => o.name == 'face')
        .x;
    double faceSx() => (inst as RuntimeArtboard)
        .objects
        .whereType<TransformComponent>()
        .firstWhere((o) => o.name == 'face')
        .scaleX;
    final seen = <String, List<double>>{};
    for (final n in ['turn_front', 'turn_three_quarter', 'turn_side',
                     'turn_three_quarter_back', 'turn_back']) {
      pose.value = expectedStates.indexOf(n).toDouble();
      for (var f = 0; f < 60; f++) {
        inst.advance(1 / 60);
      }
      seen[n] = [faceX(), faceSx()];
    }
    expect(seen['turn_three_quarter']![0], lessThan(seen['turn_front']![0] - 10),
        reason: 'at three quarter the face must slide to the left');
    expect(seen['turn_side']![0], lessThan(seen['turn_three_quarter']![0] - 30),
        reason: 'the side view must carry the face further left again');
    expect(seen['turn_side']![1], lessThan(0.3),
        reason: 'the side view is a profile, not a front face offset sideways');
    expect(seen['turn_three_quarter_back']![1], lessThan(0.02),
        reason: 'three quarter back shows no face in the official art');
    expect(seen['turn_back']![1], lessThan(0.02),
        reason: 'back shows no face');
  }, skip: canRun ? null : skip);

  test('the dissolves never let one part show through another', () async {
    // Rive fades each shape separately, so if two overlapping parts are ever
    // translucent at once the overlap doubles its ink and reads as a solid
    // patch sitting inside a ghost. Drawn on a transparent ground, a correct
    // frame has every visible pixel at one alpha.
    for (final pose in ['dissolve_in', 'dissolve_out']) {
      final inst = board.instance();
      final ctrl = StateMachineController.fromArtboard(inst, 'PebbySM')!;
      inst.addController(ctrl);
      ctrl.findInput<double>('pose')!.value =
          expectedStates.indexOf(pose).toDouble();
      for (var i = 0; i < 50; i++) {
        inst.advance(1 / 50);
        final rec = ui.PictureRecorder();
        inst.draw(ui.Canvas(rec));
        final img =
            await rec.endRecording().toImage(size.toInt(), size.toInt());
        final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
        final rgba = data!.buffer.asUint8List();
        final hist = <int, int>{};
        var ink = 0;
        for (var p = 3; p < rgba.length; p += 4 * 7) {
          final a = rgba[p];
          if (a <= 8) continue;
          ink++;
          hist[a] = (hist[a] ?? 0) + 1;
        }
        if (ink < 200) continue;
        var dominant = 0, best = 0;
        hist.forEach((a, n) {
          if (n > best) {
            best = n;
            dominant = a;
          }
        });
        var peak = dominant;
        hist.forEach((a, n) {
          if (n > ink * 0.04 && a > peak) peak = a;
        });
        expect(peak / dominant, lessThan(1.06),
            reason: '$pose frame $i has a region at alpha $peak while the body '
                'is at $dominant: something is showing through');
      }
    }
  }, skip: canRun ? null : skip);

  test('PebbySM: poses, reduceMotion freeze, and the appear dissolve', () async {
    expect(board.animations.whereType<StateMachine>().map((s) => s.name),
        ['PebbySM']);
    final inst = board.instance();
    final ctrl = StateMachineController.fromArtboard(inst, 'PebbySM')!;
    inst.addController(ctrl);
    expect(ctrl.inputs.map((i) => i.name).toList(),
        ['pose', 'reduceMotion', 'appear']);
    final pose = ctrl.findInput<double>('pose')!;
    final reduce = ctrl.findInput<bool>('reduceMotion')!;
    final appear = ctrl.findInput<double>('appear')!;

    void run(int frames) {
      for (var f = 0; f < frames; f++) {
        inst.advance(1 / 60);
      }
    }

    /// Draws on transparent black so alpha is exactly Pebby's ink.
    Future<Uint8List> raw() async {
      final rec = ui.PictureRecorder();
      inst.draw(ui.Canvas(rec));
      final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
      final d = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      return d!.buffer.asUint8List();
    }

    Future<Uint8List> snap({String? save}) async {
      final rec = ui.PictureRecorder();
      final canvas = ui.Canvas(rec);
      canvas.drawRect(const ui.Rect.fromLTWH(0, 0, size, size),
          ui.Paint()..color = const ui.Color(0xFF0C1230));
      inst.draw(canvas);
      final img = await rec.endRecording().toImage(size.toInt(), size.toInt());
      if (save != null) {
        final png = await img.toByteData(format: ui.ImageByteFormat.png);
        await File('$outDir/$save.png').writeAsBytes(png!.buffer.asUint8List());
      }
      final d = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
      return d!.buffer.asUint8List();
    }

    // the shoulder bone drives the arm now, and reads 90 degrees ahead of the
    // pose angle because bones point along +X
    double armDeg() => (inst as RuntimeArtboard)
            .objects
            .whereType<TransformComponent>()
            .firstWhere((c) => c.name == 'armLUpper')
            .rotation *
        180 /
        math.pi;

    run(45);
    expect(armDeg(), greaterThan(190),
        reason: 'entry state should be wave, left arm up');

    Directory(outDir).createSync(recursive: true);
    final shots = <String, Uint8List>{};
    for (var i = 0; i < expectedStates.length; i++) {
      pose.value = i.toDouble();
      run(45);
      shots[expectedStates[i]] = await snap(
          save: '${i.toString().padLeft(2, '0')}_${expectedStates[i]}');
    }
    final idle = shots['idle']!;
    for (final e in shots.entries) {
      if (e.key == 'idle') continue;
      expect(_same(e.value, idle), isFalse,
          reason: '${e.key} renders identically to idle');
    }

    // a looping state must keep changing frame to frame
    pose.value = 0;
    run(60);
    final m1 = await snap();
    run(7);
    expect(_same(m1, await snap()), isFalse, reason: 'idle should never freeze');

    // the peeks really sit against the artboard edge
    pose.value = 0;
    run(60);
    final centredInk = _ink(await raw());
    for (final peek in ['peek_left', 'peek_right']) {
      pose.value = expectedStates.indexOf(peek).toDouble();
      run(110);
      final ink = _ink(await raw());
      expect(ink, lessThan(centredInk * 0.72),
          reason: '\$peek should leave most of Pebby off the edge');
      expect(ink, greaterThan(centredInk * 0.25),
          reason: '\$peek should still show a good half of him');
    }

    // reduceMotion holds a still frame, and releasing it resumes
    pose.value = 0;
    reduce.value = true;
    run(45);
    final frozen = await snap(save: '97_reduce_motion');
    run(150);
    expect(_same(frozen, await snap()), isTrue,
        reason: 'reduceMotion must hold a still frame');
    reduce.value = false;
    pose.value = 3;
    run(30);
    final mv = await snap();
    run(8);
    expect(_same(mv, await snap()), isFalse,
        reason: 'clearing reduceMotion must resume animation');

    // appear drives a real dissolve
    pose.value = 0;
    run(30);
    appear.value = 100;
    run(20);
    final full = _ink(await raw());
    await snap(save: '99_appear_100');
    appear.value = 0;
    run(20);
    expect(_ink(await raw()), 0.0, reason: 'appear=0 must hide Pebby entirely');
    await snap(save: '98_appear_000');
    appear.value = 50;
    run(20);
    final half = _ink(await raw());
    await snap(save: '98_appear_050');
    expect(half, greaterThan(full * 0.25));
    expect(half, lessThan(full * 0.80),
        reason: 'appear=50 should be visibly fainter than appear=100');
  }, skip: canRun ? null : skip);
}

/// Mean alpha across the frame: how much Pebby is actually on screen.
double _ink(Uint8List rgba) {
  var sum = 0;
  for (var i = 3; i < rgba.length; i += 4) {
    sum += rgba[i];
  }
  return sum / (rgba.length / 4) / 255.0;
}

bool _same(Uint8List a, Uint8List b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
