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
    }

    public void AddGameObject(Element e)
    {
        _gameObjects.Add(e);
        _scenePanel.Children.Add(e);
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
