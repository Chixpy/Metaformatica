- Fixed `buildall.sh` and call `build.sh` with `bash` instead `sh`. So,
  `pushd` and `popd` works as spected.
- Changed `lib` output directory of the programs to `0Common/lib`,
  so many shared units don't be need to be recompiled fro every program.
- Added change in Logical Presentation when help is shown.
- Programs will create an initial config file on first run.
