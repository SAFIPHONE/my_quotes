import 'package:my_quotes/db/tables.dart';
import 'package:sqflite/sqlite_api.dart';

import 'package:my_quotes/model/author.dart';
import 'package:my_quotes/model/quote.dart';

class Dao {
  final Database db;

  Dao(this.db);

  Future<Author> addAuthor(Author author) async {
    Map<String, dynamic> row = {
      Tables.authorColumnFirstName: author.firstName,
      Tables.authorColumnLastName: author.lastName
    };

    final id = await db.insert(Tables.authorTableName, row);
    return Author(
      id: id,
      firstName: author.firstName,
      lastName: author.lastName,
    );
  }

  Future<Quote> addQuote(Quote quote) async {
    Map<String, dynamic> row = {
      Tables.quoteColumnAuthorId: quote.author.id,
      Tables.quoteColumnContent: quote.content
    };

    final id = await db.insert(Tables.quoteTableName, row);
    return Quote(
      id: id,
      author: quote.author,
      content: quote.content,
    );
  }

  Future<List<Quote>> getQuotes(int authorId) async {
    if (authorId == null) {
      return getAllQuotes();
    } else {
      return getQuotesWithAuthorId(authorId: authorId);
    }
  }

  Future<List<Quote>> getAllQuotes() async {
    final query = '''
    SELECT ${Tables.quoteColumnId}, ${Tables.quoteColumnContent}, 
    ${Tables.authorTableName}.${Tables.authorColumnID}, ${Tables.authorColumnFirstName}, ${Tables.authorColumnLastName}
    FROM ${Tables.quoteTableName}
    INNER JOIN ${Tables.authorTableName}
    ON ${Tables.quoteTableName}.${Tables.quoteColumnAuthorId} == ${Tables.authorTableName}.${Tables.authorColumnID}
    ''';

    final results = await db.rawQuery(query);

    return results.map(
      (row) {
        final author = Author(
          id: row[Tables.authorColumnID],
          firstName: row[Tables.authorColumnFirstName],
          lastName: row[Tables.authorColumnLastName],
        );

        final quote = Quote(
          id: row[Tables.quoteColumnId],
          author: author,
          content: row[Tables.quoteColumnContent],
        );

        return quote;
      },
    ).toList();
  }

  Future<List<Quote>> getQuotesWithAuthorId({int authorId}) async {
    final query = '''
    SELECT ${Tables.quoteColumnId}, ${Tables.quoteColumnContent}, 
    ${Tables.authorTableName}.${Tables.authorColumnID}, ${Tables.authorColumnFirstName}, ${Tables.authorColumnLastName}
    FROM ${Tables.quoteTableName}
    INNER JOIN ${Tables.authorTableName}
    ON ${Tables.quoteTableName}.${Tables.quoteColumnAuthorId} == ${Tables.authorTableName}.${Tables.authorColumnID} 
    WHERE ${Tables.quoteTableName}.${Tables.quoteColumnAuthorId} == $authorId
    ''';

    final results = await db.rawQuery(query);

    return results.map(
      (row) {
        final author = Author(
          id: row[Tables.authorColumnID],
          firstName: row[Tables.authorColumnFirstName],
          lastName: row[Tables.authorColumnLastName],
        );

        final quote = Quote(
          id: row[Tables.quoteColumnId],
          author: author,
          content: row[Tables.quoteColumnContent],
        );

        return quote;
      },
    ).toList();
  }

  Future<List<Author>> getAllAuthors() async {
    final results = await db.query(Tables.authorTableName);
    return results
        .map(
          (row) => Author(
            id: row[Tables.authorColumnID],
            firstName: row[Tables.authorColumnFirstName],
            lastName: row[Tables.authorColumnLastName],
          ),
        )
        .toList();
  }

  Future<List<Author>> getAllAuthorsOrdered() async {
    final results = await db.query(
      Tables.authorTableName,
      orderBy:
          "${Tables.authorColumnFirstName}, ${Tables.authorColumnLastName}",
    );
    return results
        .map(
          (row) => Author(
            id: row[Tables.authorColumnID],
            firstName: row[Tables.authorColumnFirstName],
            lastName: row[Tables.authorColumnLastName],
          ),
        )
        .toList();
  }

  Future<int> getIdOfAuthorWith({String firstName, String lastName}) async {
    final results = await db.query(
      Tables.authorTableName,
      columns: [Tables.authorColumnID],
      where:
          "${Tables.authorColumnFirstName} = ? AND ${Tables.authorColumnLastName} = ?",
      whereArgs: [firstName, lastName],
    );

    if (results.length == 1) {
      return results[0][Tables.authorColumnID];
    } else {
      return -1;
    }
  }

  Future<Author> editAuthor({
    int authorId,
    String firstName,
    String lastName,
  }) async {
    final Map<String, dynamic> values = {
      Tables.authorColumnFirstName: firstName,
      Tables.authorColumnLastName: lastName,
    };
    final result = await db.update(
      Tables.authorTableName,
      values,
      where: "${Tables.authorColumnID} = ?",
      whereArgs: [authorId],
    );
    if (result == 1) {
      return Author(id: authorId, firstName: firstName, lastName: lastName);
    } else {
      return null;
    }
  }

  Future<Quote> editQuote({
    Quote quote,
    String newContent,
  }) async {
    final Map<String, dynamic> values = {
      Tables.quoteColumnContent: newContent,
    };
    final result = await db.update(
      Tables.quoteTableName,
      values,
      where: "${Tables.quoteColumnId} = ?",
      whereArgs: [quote.id],
    );
    if (result == 1) {
      return Quote(id: quote.id, author: quote.author, content: newContent);
    } else {
      return null;
    }
  }

  Future<void> deleteAuthor({int authorId}) async {
    await deleteQuotesWithAuthor(authorId: authorId);
    await db.delete(
      Tables.authorTableName,
      where: "${Tables.authorColumnID} = ?",
      whereArgs: [authorId],
    );
  }

  Future<void> deleteQuote({int quoteId}) async {
    await db.delete(
      Tables.quoteTableName,
      where: "${Tables.quoteColumnId} = ?",
      whereArgs: [quoteId],
    );
  }

  Future<void> deleteQuotesWithAuthor({int authorId}) async {
    await db.delete(
      Tables.quoteTableName,
      where: "${Tables.quoteColumnAuthorId} = ?",
      whereArgs: [authorId],
    );
  }
}
