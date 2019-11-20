/*
 * Copyright 2019 The Sylph Authors. All rights reserved.
 *  Sylph runs Flutter integration tests on real devices in the cloud.
 *  Use of this source code is governed by a GPL-style license that can be
 *  found in the LICENSE file.
 */

import 'package:file/memory.dart';
import 'package:mockito/mockito.dart';
import 'package:platform/platform.dart';
import 'package:process/process.dart';
import 'package:reporting/reporting.dart';
import 'package:sylph/src/base/runner/sylph_command.dart';
import 'package:sylph/src/base/runner/sylph_command_runner.dart';
import 'package:test/test.dart';
import 'package:tool_base/tool_base.dart';
import 'package:tool_base_test/tool_base_test.dart';

import '../../src/common_tools.dart';
import '../../src/mocks.dart';
import '../../src/utils.dart';

const String _kFlutterRoot = '/flutter/flutter';
const String _kEngineRoot = '/flutter/engine';
const String _kArbitraryEngineRoot = '/arbitrary/engine';
const String _kProjectRoot = '/project';
const String _kDotPackages = '.packages';

void main() {
  group('SylphCommandRunner', () {
    MemoryFileSystem fs;
    Platform platform;
    SylphCommandRunner runner;
    ProcessManager processManager;
    MockClock clock;
    List<int> mockTimes;

    setUpAll(() {
//      Cache.disableLocking();
    });

    setUp(() {
      fs = MemoryFileSystem();
      fs.directory(_kFlutterRoot).createSync(recursive: true);
      fs.directory(_kProjectRoot).createSync(recursive: true);
      fs.currentDirectory = _kProjectRoot;

      platform = FakePlatform(
        environment: <String, String>{
          'FLUTTER_ROOT': _kFlutterRoot,
        },
        version: '1 2 3 4 5',
      );

      runner = createTestCommandRunner(DummySylphCommand());
      processManager = MockProcessManager();

      clock = MockClock();
      when(clock.now()).thenAnswer((Invocation _) =>
          DateTime.fromMillisecondsSinceEpoch(mockTimes.removeAt(0)));
    });

//    group('run', () {
//      testUsingContext('checks that Flutter installation is up-to-date', () async {
//        final MockFlutterVersion version = FlutterVersion.instance;
//        bool versionChecked = false;
//        when(version.checkFlutterVersionFreshness()).thenAnswer((_) async {
//          versionChecked = true;
//        });
//
//        await runner.run(<String>['dummy']);
//
//        expect(versionChecked, isTrue);
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//      }, initializeFlutterRoot: false);
//
//      testUsingContext('throw tool exit if the version file cannot be written', () async {
//        final MockFlutterVersion version = FlutterVersion.instance;
//        when(version.ensureVersionFile()).thenThrow(const FileSystemException());
//
//        expect(() async => await runner.run(<String>['dummy']), throwsA(isA<ToolExit>()));
//
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//      }, initializeFlutterRoot: false);
//
//      testUsingContext('works if --local-engine is specified and --local-engine-src-path is determined by sky_engine', () async {
//        fs.directory('$_kArbitraryEngineRoot/src/out/ios_debug/gen/dart-pkg/sky_engine/lib/').createSync(recursive: true);
//        fs.directory('$_kArbitraryEngineRoot/src/out/host_debug').createSync(recursive: true);
//        fs.file(_kDotPackages).writeAsStringSync('sky_engine:file://$_kArbitraryEngineRoot/src/out/ios_debug/gen/dart-pkg/sky_engine/lib/');
//        await runner.run(<String>['dummy', '--local-engine=ios_debug']);
//
//        // Verify that this also works if the sky_engine path is a symlink to the engine root.
//        fs.link('/symlink').createSync('$_kArbitraryEngineRoot');
//        fs.file(_kDotPackages).writeAsStringSync('sky_engine:file:///symlink/src/out/ios_debug/gen/dart-pkg/sky_engine/lib/');
//        await runner.run(<String>['dummy', '--local-engine=ios_debug']);
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//      }, initializeFlutterRoot: false);
//
//      testUsingContext('works if --local-engine is specified and --local-engine-src-path is specified', () async {
//        fs.directory('$_kArbitraryEngineRoot/src/out/ios_debug').createSync(recursive: true);
//        fs.directory('$_kArbitraryEngineRoot/src/out/host_debug').createSync(recursive: true);
//        await runner.run(<String>['dummy', '--local-engine-src-path=$_kArbitraryEngineRoot/src', '--local-engine=ios_debug']);
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//      }, initializeFlutterRoot: false);
//
//      testUsingContext('works if --local-engine is specified and --local-engine-src-path is determined by flutter root', () async {
//        fs.directory('$_kEngineRoot/src/out/ios_debug').createSync(recursive: true);
//        fs.directory('$_kEngineRoot/src/out/host_debug').createSync(recursive: true);
//        await runner.run(<String>['dummy', '--local-engine=ios_debug']);
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//      }, initializeFlutterRoot: false);
//    });

    testUsingContext('Doesnt crash on invalid .packages file', () async {
      mockTimes = <int>[1000, 2000];
      fs.file('pubspec.yaml').createSync();
      fs.file('.packages')
        ..createSync()
        ..writeAsStringSync('Not a valid package');

      await runner.run(<String>[DummySylphCommand().name]);
    }, overrides: <Type, Generator>{
      FileSystem: () => fs,
      Platform: () => platform,
      SystemClock: () => clock,
      Usage: () => FakeUsage(),
    }, initializeFlutterRoot: false);

//    group('version', () {
//      testUsingContext('checks that Flutter toJson output reports the flutter framework version', () async {
//        final ProcessResult result = ProcessResult(0, 0, 'random', '0');
//
//        when(processManager.runSync('git log -n 1 --pretty=format:%H'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//        when(processManager.runSync('git rev-parse --abbrev-ref --symbolic @{u}'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//        when(processManager.runSync('git rev-parse --abbrev-ref HEAD'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//        when(processManager.runSync('git ls-remote --get-url master'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//        when(processManager.runSync('git log -n 1 --pretty=format:%ar'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//        when(processManager.runSync('git describe --match v*.*.* --first-parent --long --tags'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//        when(processManager.runSync('git log -n 1 --pretty=format:%ad --date=iso'.split(' '),
//          workingDirectory: Cache.flutterRoot)).thenReturn(result);
//
//        final FakeFlutterVersion version = FakeFlutterVersion();
//
//        // Because the hash depends on the time, we just use the 0.0.0-unknown here.
//        expect(version.toJson()['frameworkVersion'], '0.10.3');
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//        ProcessManager: () => processManager,
//      }, initializeFlutterRoot: false);
//    });

//    group('getRepoPackages', () {
//      setUp(() {
//        fs.directory(fs.path.join(_kFlutterRoot, 'examples'))
//            .createSync(recursive: true);
//        fs.directory(fs.path.join(_kFlutterRoot, 'packages'))
//            .createSync(recursive: true);
//        fs.directory(fs.path.join(_kFlutterRoot, 'dev', 'tools', 'aatool'))
//            .createSync(recursive: true);
//
//        fs.file(fs.path.join(_kFlutterRoot, 'dev', 'tools', 'pubspec.yaml'))
//            .createSync();
//        fs.file(fs.path.join(_kFlutterRoot, 'dev', 'tools', 'aatool', 'pubspec.yaml'))
//            .createSync();
//      });
//
//      testUsingContext('', () {
//        final List<String> packagePaths = runner.getRepoPackages()
//            .map((Directory d) => d.path).toList();
//        expect(packagePaths, <String>[
//          fs.directory(fs.path.join(_kFlutterRoot, 'dev', 'tools', 'aatool')).path,
//          fs.directory(fs.path.join(_kFlutterRoot, 'dev', 'tools')).path,
//        ]);
//      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
//        Platform: () => platform,
//      }, initializeFlutterRoot: false);
//    });

    group('wrapping', () {
      testUsingContext(
          'checks that output wrapping is turned on when writing to a terminal',
          () async {
        mockTimes = <int>[1000, 2000];
        final FakeCommand fakeCommand = FakeCommand();
        runner.addCommand(fakeCommand);
        await runner.run(<String>[fakeCommand.name]);
        expect(fakeCommand.preferences.wrapText, isTrue);
      }, overrides: <Type, Generator>{
        FileSystem: () => fs,
        Stdio: () => FakeStdio(hasFakeTerminal: true),
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      }, initializeFlutterRoot: false);

      testUsingContext(
          'checks that output wrapping is turned off when not writing to a terminal',
          () async {
        mockTimes = <int>[1000, 2000];
        final FakeCommand fakeCommand = FakeCommand();
        runner.addCommand(fakeCommand);
        await runner.run(<String>[fakeCommand.name]);
        expect(fakeCommand.preferences.wrapText, isFalse);
      }, overrides: <Type, Generator>{
        FileSystem: () => fs,
        Stdio: () => FakeStdio(hasFakeTerminal: false),
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      }, initializeFlutterRoot: false);

      testUsingContext(
          'checks that output wrapping is turned off when set on the command line and writing to a terminal',
          () async {
        mockTimes = <int>[1000, 2000];
        final FakeCommand fakeCommand = FakeCommand();
        runner.addCommand(fakeCommand);
        await runner.run(<String>['--no-wrap', fakeCommand.name]);
        expect(fakeCommand.preferences.wrapText, isFalse);
      }, overrides: <Type, Generator>{
        FileSystem: () => fs,
        Stdio: () => FakeStdio(hasFakeTerminal: true),
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      }, initializeFlutterRoot: false);

      testUsingContext(
          'checks that output wrapping is turned on when set on the command line, but not writing to a terminal',
          () async {
        mockTimes = <int>[1000, 2000];
        final FakeCommand fakeCommand = FakeCommand();
        runner.addCommand(fakeCommand);
        await runner.run(<String>['--wrap', fakeCommand.name]);
        expect(fakeCommand.preferences.wrapText, isTrue);
      }, overrides: <Type, Generator>{
        FileSystem: () => fs,
        Stdio: () => FakeStdio(hasFakeTerminal: false),
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      }, initializeFlutterRoot: false);

      testUsingContext('checks that wrap column is set', () async {
        final wrapColumn = 10;
        mockTimes = <int>[1000, 2000];
        final FakeCommand fakeCommand = FakeCommand();
        runner.addCommand(fakeCommand);
        await runner
            .run(<String>['--wrap-column', '$wrapColumn', fakeCommand.name]);
        expect(fakeCommand.preferences.wrapColumn, wrapColumn);
      }, overrides: <Type, Generator>{
        FileSystem: () => fs,
        Stdio: () => FakeStdio(hasFakeTerminal: false),
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      });

      testUsingContext('checks that wrap column is invalid or bad format',
          () async {
        expect(
            () async => await runner
                .run(<String>['--wrap-column', '-1', DummySylphCommand().name]),
            throwsToolExit(
                message:
                    'Argument to --wrap-column must be a positive integer. You supplied -1.'));
        expect(
            () async => await runner
                .run(<String>['--wrap-column', 'xx', DummySylphCommand().name]),
            throwsToolExit(
                message: 'Unable to parse argument --wrap-column=xx'));
      });
    });
    group('bug report', () {
      testUsingContext('checks that bug report is created', () async {
        mockTimes = <int>[1000, 2000];
        await runner.run(<String>['--bug-report', DummySylphCommand().name]);
        await runShutdownHooks();
        expect(testLogger.statusText,
            contains('Bug report written to bugreport_01.zip.\n'));
      }, overrides: <Type, Generator>{
        FileSystem: () => fs,
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      }, initializeFlutterRoot: false);
    });

    group('record/replay', () {
      testUsingContext("'checks that replay is configured", () async {
        mockTimes = <int>[1000, 2000];
        final lfs = LocalFileSystem();
        final recordDir = lfs.systemTempDirectory.path + '/record_dir';
        for (final subDir in ['file', 'platform', 'process']) {
//          lfs.directory(recordDir + '/file').createSync(recursive: true);
          final manifest = lfs.file('$recordDir/$subDir/MANIFEST.txt');
          manifest.createSync(recursive: true);
          subDir == 'platform'
              ? manifest.writeAsStringSync(
                  '{"environment":{"SHELL": "/bin/zsh"}, "script":"", "executableArguments":[]}')
              : manifest.writeAsStringSync('[]');
        }
        await runner.run(
            <String>['--replay-from', recordDir, DummySylphCommand().name]);
        await runShutdownHooks();
        expect(testLogger.statusText, '');
      }, overrides: <Type, Generator>{
//        FileSystem: () => fs,
        SystemClock: () => clock,
        Usage: () => FakeUsage(),
      });
    });
  });
}

class MockProcessManager extends Mock implements ProcessManager {}

//class FakeFlutterVersion extends FlutterVersion {
//  @override
//  String get frameworkVersion => '0.10.3';
//}

class FakeCommand extends SylphCommand {
  OutputPreferences preferences;

  @override
  Future<SylphCommandResult> runCommand() {
    preferences = outputPreferences;
    return Future<SylphCommandResult>.value(
        const SylphCommandResult(ExitStatus.success));
  }

  @override
  String get description => 'A fake command that returns success.';

  @override
  String get name => 'fake';
}

class FakeStdio extends Stdio {
  FakeStdio({this.hasFakeTerminal});

  final bool hasFakeTerminal;

  @override
  bool get hasTerminal => hasFakeTerminal;

  @override
  int get terminalColumns => hasFakeTerminal ? 80 : null;

  @override
  int get terminalLines => hasFakeTerminal ? 24 : null;

  @override
  bool get supportsAnsiEscapes => hasFakeTerminal;
}