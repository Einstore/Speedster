For those who are wondering how to do code coverage in Swift 5; it's now builtin, you can parse the generated files with llvm;
swift test --enable-code-coverage
#easy access
mv .build/*/*/*.profdata coverage.profdata
mv .build/*/*/*.profraw coverage.profraw

llvm-profdata merge -o coverage.profdata coverage.profraw
llvm-cov report $(swift build --show-bin-path)/Run -instr-profile=coverage.profdata Sources/App
When running on a mac, you should use xcrun to run the llvm-profdata and llvm-cov; e.g. xcrun llvm-profdata merge ...
The last argument is the filter, only show sources in the Sources/App directory
