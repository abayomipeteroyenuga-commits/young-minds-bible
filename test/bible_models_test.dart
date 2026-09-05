import 'package:flutter_test/flutter_test.dart';
import 'package:young_minds_bible/models/bible_models.dart';

void main() {
  test('Bible models parse normalized chapter data', () {
    final library = BibleLibrary.fromJson({
      'translation': 'TEST',
      'translation_name': 'Test Bible',
      'books': [
        {
          'name': 'John',
          'chapters': [
            {
              'number': 3,
              'verses': [
                {'number': 16, 'text': 'Sample verse'},
              ],
            },
          ],
        },
      ],
    });
    expect(library.books.single.name, 'John');
    expect(library.books.single.chapters.single.number, 3);
    expect(library.books.single.chapters.single.verses.single.number, 16);
  });
}
