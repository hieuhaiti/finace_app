///=======================================================================================================================
/// Get transactions by type. return like
/// {averages: [income: 12000, outcome: 7000],
/// details: [
/// year: 2021,
/// yearDetail:[
/// month: 12,
/// monthDetail: [
/// total income: 10000,transactions: [list of all transactions income in that month],
/// total outcome: 5000, transactions: [list of all transactions outcome in that month]],
/// monthDetail: 11,
/// detail: [
/// total income: 20000,transactions: [list of all transactions income in that month],
/// total outcome: 10000, transactions: [list of all transactions outcome in that month]]
/// ...],
/// ...]

///=======================================================================================================================
/// Get transactions by category. return like
/// {averages: [cate1: 500,cate2: 700,...],
/// details:
/// [
/// year: 2021,
/// yearDetail:[
/// month: 12,
/// monthDetail:
/// [cate1: other, total spending: 100, transactions: [list of all transactions other in that month],
/// cate2: food, total spending: 200, transactions: [list of all transactions food in that month],
/// ...],
/// month: 11,
/// monthDetail:
/// [cate1: other, total spending: 100, transactions: [list of all transactions other in that month],
/// cate2: food, total spending: 200, transactions: [list of all transactions food in that month],
/// ...]
/// ...]

///=======================================================================================================================
/// Get transactions by Spending Plan. return like
/// {totals(money saving throught each month): [plan1: 1500,plan2: 1700,...],
/// averages: [plan1: 500,plan2: 700,...],
/// details:
/// year: 2021,
/// yearDetail:[
/// month: 12,
/// monthDetail:
/// [bugdget plan1: 700, total spending: 500, transactions: [list of all transactions plan1 in that month],
/// bugdget plan2: 1000, total spending: 700, transactions: [list of all transactions plan2 in that month],
/// ...],
/// year: 2021,
/// yearDetail:[
/// month: 12,
/// monthDetail:
/// [bugdget plan1: 700, total spending: 500, transactions: [list of all transactions plan1 in that month],
/// bugdget plan2: 1000, total spending: 700, transactions: [list of all transactions plan2 in that month],
/// ...]
///=======================================================================================================================