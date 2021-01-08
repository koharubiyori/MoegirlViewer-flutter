// 树化
List<Map> _toCommentTree(List data) {
  final roots = data.where((item) => item['parentid'] == '');
  roots.forEach((item) {
    item['children'] = _getChildrenById(item, data);
  });

  return roots.toList();
}

// 获取一条评论下所有回复
List<Map> _getChildrenById(Map root, List data) {
  List<Map> through(dynamic root) {
    final result = <Map>[];
    data.forEach((item) {
      if (root['id'] == item['parentid']) {
        item['children'] = through(item);
        result.add(item);
      }
    });

    return result;
  }

  return through(root);
}

class CommentTree {
  List<Map> data;

  CommentTree(dynamic rawData) {
    data = _toCommentTree(rawData.cast<Map>());
  }

  // 为回复带上回复对象(target)的数据
  static List<Map> withTargetData(List<Map> children, String selfId) {
    return children.map((item) {
      if (item['parentid'] != selfId) {
        item['target'] = children.firstWhere((childItem) => childItem['id'] == item['parentid'], orElse: () => null);
      }
      return item;
    }).toList();
  }

  static List<Map> flattenItem(List<Map> children) {
    return children.fold<List<Map>>(<Map>[], (result, item) {
      final children = item['children'] ?? [];
      item.remove('children');
      return [...result, item, ...flattenItem(children)];
    });
  }

  // 从第二层开始扁平化
  CommentTree flatten() {
    data.forEach((item) => item['children'] = flattenItem(item['children']));
    return this;
  }
}
