class MatchModel {
  final String? id;
  final String team1;
  final String team2;
  final int team1Score;
  final int team2Score;
  final bool isRunning;
  final String winner;

  MatchModel({
    this.id,
    required this.team2,
    required this.team1Score,
    required this.team2Score,
    required this.isRunning,
    required this.winner,
    required this.team1,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json["id"],
      team2: json["team_2"],
      team1Score: json["team_1_score"],
      team2Score: json["team_2_score"],
      isRunning: json["isRunning"],
      winner: json["winner_team"],
      team1: json["team_1"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "team_2": team2,
      "team_1_score": team1Score,
      "team_2_score": team2Score,
      "isRunning": isRunning,
      "winner_team": winner,
      "team_1": team1,
    };
  }
}
