class DropdownItem {
  final String id;
  final String name;

  DropdownItem({required this.id, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DropdownItem &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}




// class DropdownItem {
//   final String id;
//   final String name;
//
//   DropdownItem({required this.id, required this.name});
// }
