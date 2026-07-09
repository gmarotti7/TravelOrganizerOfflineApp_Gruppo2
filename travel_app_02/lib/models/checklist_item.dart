class checklistItem{
  final String id;
  final String title;
  final bool done;

  checklistItem({
    required this.id,
    required this.title,
    this.done = false
  });
}