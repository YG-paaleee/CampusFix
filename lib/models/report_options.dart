enum ReportStatus {
  submitted('Submitted'),
  inProgress('In Progress'),
  resolved('Resolved'),
  rejected('Rejected');

  const ReportStatus(this.label);

  final String label;
}

enum ReportUrgency {
  low('Low', 1),
  medium('Medium', 2),
  high('High', 3);

  const ReportUrgency(this.label, this.rank);

  final String label;
  final int rank;
}

enum ReportCategory {
  classroom('Classroom'),
  electrical('Electrical'),
  plumbing('Plumbing'),
  restroom('Restroom'),
  itEquipment('IT Equipment'),
  others('Others');

  const ReportCategory(this.label);

  final String label;
}
