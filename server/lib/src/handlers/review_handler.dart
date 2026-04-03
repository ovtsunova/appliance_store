import 'package:shelf/shelf.dart';

import '../auth/auth_middleware.dart';
import '../common/json_response.dart';
import '../common/request_body.dart';
import '../database/database_service.dart';

class ReviewHandler {
  final DatabaseService database;

  ReviewHandler(this.database);

  Future<Response> getReviewsByProduct(Request request, String productIdRaw) async {
    try {
      final productId = int.parse(productIdRaw);

      final rows = await database.connection.execute(
        r'''
        SELECT
          r.ID_Review AS review_id,
          r.Rating AS rating,
          r.Comment AS comment,
          r.ReviewDate AS review_date,
          u.ID_User AS user_id,
          u.LastName AS last_name,
          u.FirstName AS first_name,
          COALESCE(u.Patronymic, '') AS patronymic
        FROM Reviews r
        JOIN Users u ON u.ID_User = r.User_ID
        WHERE r.Product_ID = $1
        ORDER BY r.ReviewDate DESC
        ''',
        parameters: [productId],
      );

      final result = rows.map((row) {
        final map = row.toColumnMap();
        final patronymic = (map['patronymic'] as String?)?.trim() ?? '';
        final authorName = patronymic.isEmpty
            ? '${map['last_name']} ${map['first_name']}'
            : '${map['last_name']} ${map['first_name']} $patronymic';

        return {
          'id': map['review_id'],
          'rating': map['rating'],
          'comment': map['comment'],
          'reviewDate': map['review_date']?.toString(),
          'user': {
            'id': map['user_id'],
            'name': authorName,
          },
        };
      }).toList();

      return jsonOk(result);
    } catch (e) {
      return jsonServerError(
        'Ошибка загрузки отзывов',
        details: e.toString(),
      );
    }
  }

  Future<Response> createReview(Request request, String productIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final productId = int.parse(productIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final rating = requireInt(body, 'rating', min: 1);
      final comment = requireString(body, 'comment', allowEmpty: true);

      if (rating > 5) {
        return jsonBadRequest('Оценка должна быть от 1 до 5');
      }

      final productRows = await database.connection.execute(
        r'''
        SELECT 1
        FROM Products
        WHERE ID_Product = $1
        LIMIT 1
        ''',
        parameters: [productId],
      );

      if (productRows.isEmpty) {
        return jsonNotFound('Товар не найден');
      }

      final purchaseRows = await database.connection.execute(
        r'''
        SELECT 1
        FROM Orders o
        JOIN OrderDetails od ON od.Order_ID = o.ID_Order
        JOIN OrderStatuses os ON os.ID_Status = o.Status_ID
        WHERE o.User_ID = $1
          AND od.Product_ID = $2
          AND os.StatusName <> 'Отменён'
        LIMIT 1
        ''',
        parameters: [user.userId, productId],
      );

      if (purchaseRows.isEmpty) {
        return jsonBadRequest(
          'Оставить отзыв может только пользователь, купивший этот товар',
        );
      }

      final existingRows = await database.connection.execute(
        r'''
        SELECT 1
        FROM Reviews
        WHERE User_ID = $1 AND Product_ID = $2
        LIMIT 1
        ''',
        parameters: [user.userId, productId],
      );

      if (existingRows.isNotEmpty) {
        return jsonBadRequest('Вы уже оставляли отзыв на этот товар');
      }

      await database.connection.execute(
        r'''
        INSERT INTO Reviews (
          Rating,
          Comment,
          User_ID,
          Product_ID
        )
        VALUES ($1, $2, $3, $4)
        ''',
        parameters: [
          rating,
          comment.isEmpty ? null : comment,
          user.userId,
          productId,
        ],
      );

      return jsonCreated({'message': 'Отзыв успешно добавлен'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> updateReview(Request request, String reviewIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final reviewId = int.parse(reviewIdRaw);
      final rawBody = await request.readAsString();
      final body = await readJsonBody(rawBody);

      final rating = requireInt(body, 'rating', min: 1);
      final comment = requireString(body, 'comment', allowEmpty: true);

      if (rating > 5) {
        return jsonBadRequest('Оценка должна быть от 1 до 5');
      }

      final rows = await database.connection.execute(
        r'''
        SELECT 1
        FROM Reviews
        WHERE ID_Review = $1 AND User_ID = $2
        LIMIT 1
        ''',
        parameters: [reviewId, user.userId],
      );

      if (rows.isEmpty) {
        return jsonNotFound('Отзыв не найден');
      }

      await database.connection.execute(
        r'''
        UPDATE Reviews
        SET
          Rating = $1,
          Comment = $2,
          ReviewDate = CURRENT_TIMESTAMP
        WHERE ID_Review = $3 AND User_ID = $4
        ''',
        parameters: [
          rating,
          comment.isEmpty ? null : comment,
          reviewId,
          user.userId,
        ],
      );

      return jsonOk({'message': 'Отзыв успешно обновлён'});
    } on FormatException catch (e) {
      return jsonBadRequest(e.message);
    } catch (e) {
      return jsonBadRequest(
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Response> deleteReview(Request request, String reviewIdRaw) async {
    try {
      final user = currentUser(request);
      if (user == null) {
        return jsonUnauthorized('Пользователь не авторизован');
      }

      final reviewId = int.parse(reviewIdRaw);

      final result = await database.connection.execute(
        r'''
        DELETE FROM Reviews
        WHERE ID_Review = $1 AND User_ID = $2
        ''',
        parameters: [reviewId, user.userId],
      );

      if (result.affectedRows == 0) {
        return jsonNotFound('Отзыв не найден');
      }

      return jsonOk({'message': 'Отзыв удалён'});
    } catch (e) {
      return jsonBadRequest(
        'Не удалось удалить отзыв',
        details: e.toString(),
      );
    }
  }
}