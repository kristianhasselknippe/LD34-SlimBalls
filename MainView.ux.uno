using Fuse;
using Uno;
using Uno.Collections;
using Fuse.Elements;
using Fuse.Controls;

public class Scene
{
    public List<Element> _gameObjects = new List<Element>();

    public Panel _scenePanel;

    public Scene(Panel p)
    {
        _scenePanel = p;
		UpdateManager.AddAction(Update);
    }

    public void AddGameObject(Element e)
    {
        _gameObjects.Add(e);
        _scenePanel.Children.Add(e);
    }

	public event Action<float> OnBeforePhysic;
	public event Action<float> OnAfterPhysic;

	public SpringPhysics SpringPhysics = new SpringPhysics();

	public void Update()
	{
		var dt = Fuse.Time.FrameIntervalFloat;

		if (OnBeforePhysic != null)
			OnBeforePhysic(dt);

		SpringPhysics.Step(dt);

		if (OnAfterPhysic != null)
			OnAfterPhysic(dt);
	}

}

public partial class MainView
{
    public MainView()
    {
        InitializeUX();

        var s = new Scene(scene);
        var player = new Player(s);
        s.AddGameObject(player);
    }
}
