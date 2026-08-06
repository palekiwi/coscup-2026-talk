Output public/demo.mp4

Set FontFamily "JetBrains Mono"
Set FontSize 22
Set LineHeight 1.3
Set Width 1100
Set Height 676
Set Theme "Catppuccin Mocha"
Set Padding 20

Type "cd demo"
Enter
Sleep 500ms

Type "ruby -v"
Enter
Sleep 800ms

Type "pg_config --version"
Enter
Sleep 800ms

Type "nix develop"
Enter
Sleep 2.5s

Type "ruby -v"
Enter
Sleep 800ms

Type "pg_config --version"
Enter
Sleep 800ms

Type "rspec"
Enter
Sleep 8s
