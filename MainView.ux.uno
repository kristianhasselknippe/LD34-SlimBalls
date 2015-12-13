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

    public void RemoveGameObject(Element e)
    {
        _gameObjects.Remove(e);
        _scenePanel.Children.Remove(e);
    }

	public event Action<float> OnBeforePhysic;
	public event Action<float> OnAfterPhysic;

	public readonly SpringPhysics SpringPhysics = new SpringPhysics();

    public CollisionManager CollisionManager;

	public void Update()
	{
		var dt = Fuse.Time.FrameIntervalFloat;

		if (OnBeforePhysic != null)
			OnBeforePhysic(dt);

		SpringPhysics.Step(dt);

		if (OnAfterPhysic != null)
			OnAfterPhysic(dt);

        if(CollisionManager != null)
            CollisionManager.Update();
	}
}

public partial class MainView
{
    public MainView()
    {
        InitializeUX();

        var s = new Scene(scene);
		var controller = new PlayerController(pointerPanel);

        List<Enemy> enemies = new List<Enemy>();
        var player = new Player(s, new SlimeBall(s, s.SpringPhysics, float2(0), float4(1.f, 0.3f, 1.f, 1.f), 1), controller);
        var randGen = new Random(1337);

        for(var i = 0;i < 20;++i)
        {
            var enemy = new Enemy(s, s.SpringPhysics, (randGen.NextFloat2() - 0.5f) * 1200, randGen.NextInt(1, 4), randGen);
            enemies.Add(enemy);
        }
        s.CollisionManager = new CollisionManager(player, enemies, bloom);
    }
}

class CollisionManager
{
    readonly Player _player;
    readonly List<Enemy> _enemies;
    readonly Fuse.Effects.Bloom _bloom;
    float _fadeEnd;

    public CollisionManager(Player player, List<Enemy> enemies, Fuse.Effects.Bloom bloom)
    {
        _player = player;
        _enemies = enemies;
        _bloom = bloom;
    }

    public void Update()
    {
        if((float)Fuse.Time.FrameTime < _fadeEnd)
            _bloom.Strength = 2.f * Math.Sin((float)Math.PI * 0.5f * (1.0f - ((_fadeEnd - (float)Fuse.Time.FrameTime) / 2.f)) + (float)Math.PI * 0.5f);
        else
            _bloom.Strength = 0.f;

        foreach(var enemy in _enemies)
        {
            var particlesHit = _player._slimeBall.HitTest(enemy);

            // We may only take one per frame else the whole system will be degenerated into a big mess.
            if(particlesHit.Count() > 0)
            {
                _fadeEnd = (float)Fuse.Time.FrameTime + 2.f;
                _player.OnHitEnemy(enemy, particlesHit.First());
            }
        }
    }
}
