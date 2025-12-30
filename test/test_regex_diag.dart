void main() {
  final input = r'\sqrt{144}';
  print('Input: $input (length ${input.length})');
  for (int i = 0; i < input.length; i++) {
    print('Char $i: "${input[i]}" (code: ${input.codeUnitAt(i)})');
  }

  final res = [r'\sqrt', r'\sqrt', r'\\sqrt', r'\\sqrt'];

  for (final r in res) {
    final re = RegExp(r);
    print('Testing regex r"$r": ${re.hasMatch(input)}');
  }
}
