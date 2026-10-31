import 'package:equatable/equatable.dart';
import 'leave_item_model.dart';

class LeavePaginationModel extends Equatable {
  final List<LeaveItemModel> items;
  final int totalCount;
  final int currentPage;
  final int totalPages;
  final bool hasNextPage;

  const LeavePaginationModel({
    required this.items,
    required this.totalCount,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory LeavePaginationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const LeavePaginationModel(
        items: [],
        totalCount: 0,
        currentPage: 1,
        totalPages: 1,
        hasNextPage: false,
      );
    }

    dynamic dataList;
    int total = 0;
    int page = 1;
    int limit = 10;
    int totalPages = 1;

    final dataField = json['data'] ?? json['leaves'] ?? json['items'];

    if (dataField is List) {
      dataList = dataField;
      total = json['total'] is num ? (json['total'] as num).toInt() : dataList.length;
      page = json['page'] is num ? (json['page'] as num).toInt() : 1;
      limit = json['limit'] is num ? (json['limit'] as num).toInt() : 10;
    } else if (dataField is Map<String, dynamic>) {
      final innerList = dataField['data'] ??
          dataField['leaves'] ??
          dataField['items'] ??
          dataField['rows'];
      dataList = innerList is List ? innerList : [];

      if (dataField['pagination'] is Map<String, dynamic>) {
        final p = dataField['pagination'] as Map<String, dynamic>;
        total = p['total'] is num ? (p['total'] as num).toInt() : dataList.length;
        page = p['page'] is num ? (p['page'] as num).toInt() : 1;
        limit = p['limit'] is num ? (p['limit'] as num).toInt() : 10;
        totalPages = p['totalPages'] is num ? (p['totalPages'] as num).toInt() : 1;
      } else {
        total = dataField['total'] is num
            ? (dataField['total'] as num).toInt()
            : dataList.length;
        page = dataField['page'] is num
            ? (dataField['page'] as num).toInt()
            : 1;
        limit = dataField['limit'] is num ? (dataField['limit'] as num).toInt() : 10;
        totalPages = limit > 0 ? (total / limit).ceil() : 1;
      }
    } else {
      dataList = [];
    }

    final parsedItems = (dataList as List)
        .whereType<Map<String, dynamic>>()
        .map((e) => LeaveItemModel.fromJson(e))
        .toList();

    if (totalPages <= 0) totalPages = limit > 0 ? (total / limit).ceil() : 1;
    final hasNext = page < totalPages;

    return LeavePaginationModel(
      items: parsedItems,
      totalCount: total,
      currentPage: page,
      totalPages: totalPages > 0 ? totalPages : 1,
      hasNextPage: hasNext,
    );
  }

  @override
  List<Object?> get props => [items, totalCount, currentPage, totalPages, hasNextPage];
}
