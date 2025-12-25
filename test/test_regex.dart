void main() {
  final input = r'\sqrt{144}';
  final re1 = RegExp(r'\sqrt'); // Regex \sqrt
  final re2 = RegExp(r'\\sqrt'); // Regex \sqrt
  print('Input: $input');
  print('re1 (r"\\sqrt"): ${re1.hasMatch(input)}');
  print('re2 (r"\\\\sqrt"): ${re2.hasMatch(input)}');
  
  final res1 = input.replaceAllMapped(re1, (m) => 'MATCH');
  final res2 = input.replaceAllMapped(re2, (m) => 'MATCH');
  print('Res1: $res1');
  print('Res2: $res2');
}
