using Uno;
using Fuse;
using Fuse.Elements;
using Fuse.Input;

public class PlayerController
{

	public float2 PointerPosition { get; set; }
	public bool HasPosition = false;

	Element element;

	public PlayerController(Element elm)
	{
		element = elm;
		Pointer.Pressed.AddHandler(elm, OnPointerPressed);
		Pointer.Moved.AddHandler(elm, OnPointerMoved);
		Pointer.Released.AddHandler(elm, OnPointerReleased);

		PointerPosition = float2();
	}

	int down = -1;
	void OnPointerPressed(object sender, PointerPressedArgs args)
	{
		down = args.PointIndex;
		var sizei = Application.Current.Window.ClientSize;
		var size = float2(sizei.X, sizei.Y);
		//debug_log("ClientSize: " + size);
		PointerPosition = args.WindowPoint - size/2.0f;

		HasPosition = true;
	}

	void OnPointerMoved(object sender, PointerMovedArgs args)
	{
		if (args.PointIndex == down)
		{
			var sizei = Application.Current.Window.ClientSize;
			var size = float2(sizei.X, sizei.Y);
			//debug_log("ClientSize: " + size);
			PointerPosition = args.WindowPoint - size/2.0f;

		}

	}

	void OnPointerReleased(object sender, PointerReleasedArgs args)
	{
		if (args.PointIndex == down)
		{
			down = -1;
			HasPosition = false;

			HighScore.AddHighScore(123);
		}
	}

}