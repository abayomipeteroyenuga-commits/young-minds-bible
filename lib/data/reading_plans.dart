class ReadingPlan {
  const ReadingPlan({required this.id, required this.title, required this.subtitle, required this.days, required this.readings});
  final String id;
  final String title;
  final String subtitle;
  final int days;
  final List<String> readings;
}

const readingPlans = <ReadingPlan>[
  ReadingPlan(id:'start7', title:'Start With Jesus', subtitle:'Meet Jesus through seven key readings.', days:7, readings:['John 1','Mark 1','Matthew 5','Luke 15','John 10','John 14','John 20']),
  ReadingPlan(id:'wisdom7', title:'7 Days of Wisdom', subtitle:'A short journey through Proverbs.', days:7, readings:['Proverbs 1','Proverbs 3','Proverbs 4','Proverbs 8','Proverbs 10','Proverbs 15','Proverbs 16']),
  ReadingPlan(id:'courage7', title:'Courage & Faith', subtitle:'Read about trusting God in difficult moments.', days:7, readings:['Joshua 1','Judges 6','1 Samuel 17','Daniel 3','Daniel 6','Esther 4','Hebrews 11']),
  ReadingPlan(id:'psalms14', title:'14 Days in Psalms', subtitle:'Two weeks of prayer, hope and praise.', days:14, readings:['Psalms 1','Psalms 8','Psalms 19','Psalms 23','Psalms 27','Psalms 34','Psalms 46','Psalms 51','Psalms 91','Psalms 100','Psalms 103','Psalms 121','Psalms 139','Psalms 150']),
];
