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

		debug_log("Added members");

		Evaluated += OnJsInitialized;

		Instance = this;
	}

	void OnJsInitialized(object sender, Uno.EventArgs args)
	{
		debug_log("JS was initialized");
	}

	public static void AddHighScore(float score)
	{
		debug_log("Trying to add highscore");
		HighScore.Instance._addedHighScore.RaiseAsync(score);
	}

	public static void ClearHighScore()
	{
		HighScore.Instance._clearedHighScore.RaiseAsync();
	}
}