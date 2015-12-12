var Observable = require("FuseJS/Observable");
var Storage = require("FuseJS/Storage");
var HighScore = require("HighScore");

function Run(score)
{
	this.score = Observable(score);

	this.serialize = function(){
		return '{"score" : ' + this.score.value + '}';
	}.bind(this);
}

var previousRuns = Observable();
var highScore = Observable();

function addScore(score)
{
	previousScores.add(new Run(score));

	var bestRun = previousRuns.getAt(0);
	for (var i = 1; i < previousRuns.length; i++){
		if (previousRuns.getAt(i).score.value > bestRun.score.value)
			bestRun = previousRuns.getAt(i);
	}
	highScore.value = bestRun.score.value;

	save();
}

function clearScores()
{
	previousRuns.clear();
	save();
}

HighScore.addedHighScore = addScore;
HighScore.clearHighScore = clearScores();

function save()
{
	var json = "[";
	for (var i = 0; i < previousRuns.length; i++){
		json += previousRuns.getAt(i).serialize();
		if (i != previousRuns.length - 1)
			json += ",";
	}
	json += "]";
	Storage.write("slimballs.highscores", json);
}

function load()
{
	Storage.read("slimballs.highscores").then(function(content){
		var c = JSON.parse(content);
		for (var i = 0; i < c.length; i++){
			var item = c[i];
			var s = new Run(item.score);
			previousRuns.add(s);
		}
	},function(error){
		console.log(error);
	});
}

load();



module.exports = {
	highScore: highScore,
	previousRuns: previousRuns
};
