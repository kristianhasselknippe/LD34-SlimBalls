using Uno;
using Fuse;
using Fuse.Scripting;


public class HighScore : NativeModule
{

	NativeEvent _addedHighScore;
	NativeEvent _clearedHighScore;

	static HighScore Instance {get;set;}

	public HighScore()
	{
		_addedHighScore = new NativeEvent("addedHighScore");
		_clearedHighScore = new NativeEvent("clearedHighScore");
		AddMember(_addedHighScore);
		AddMember(_clearedHighScore);

		Instance = this;
	}

	public static void AddHighScore(float score)
	{
		HighScore.Instance._addedHighScore.RaiseAsync(score);
	}

	public static void ClearHighScore()
	{
		if (Instance == null) return;
		HighScore.Instance._clearedHighScore.RaiseAsync();
	}
}