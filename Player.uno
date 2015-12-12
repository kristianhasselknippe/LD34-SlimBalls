using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Fuse.Controls;

public class Particle
{
    public float2 Position;
    public float2 Velocity;
    public float2 ForceAccumulator;

    public float Mass;
    public float Radius;

    public override string ToString()
    {
        return "Position: " + Position + "\n"
        + "Velocity: " + Velocity + "\n"
        + "ForceAccumulator: " + ForceAccumulator + "\n"
        + "Mass: " + Mass + "\n"
        + "Radius: " + Radius;
    }
}

public class ParticleElement
{
    public readonly Particle Particle;
    public readonly Element Renderer;

    public ParticleElement(Particle particle, Element renderer)
    {
        Particle = particle;
        Renderer = renderer;
    }
}

public partial class Player : Panel
{
    readonly ParticleElement MainParticle;
    readonly List<ParticleElement> _particles = new List<ParticleElement>();
    readonly Scene _scene;

    Element _element;
    public Element ParticleElement
    {
        get { return _element; }
        set
        {
            _element = value;
        }
    }

	readonly PlayerController PlayerController;

    readonly SpringPhysics _springPhysics;
    public Player(Scene scene, SpringPhysics springPhysics, PlayerController controller)
    {
        InitializeUX();
        _scene = scene;
        _springPhysics = springPhysics;

		PlayerController = controller;

        MainParticle = CreateParticleElement(new Particle() { Mass = 10.f });


		for (var i = 0; i < 20; i++)
		{
			var dummyParticle2 = new Particle();
			var x = Math.Lerp(0, 2 * Math.PI, i / 10.0);
			dummyParticle2.Mass = 10.f;
			dummyParticle2.Position.X = (float)Math.Cos(x) * 400;
			dummyParticle2.Position.Y = (float)Math.Sin(x) * 400;
			AddParticle(dummyParticle2);
		}



        scene.OnAfterPhysic += OnUpdate;
		scene.OnBeforePhysic += OnBefore;
    }

	void OnBefore(float dt)
	{

	}

    void OnUpdate(float dt)
    {
		var pointerPos = PlayerController.PointerPosition;
		var pointerForce = float2(0);
		if (Vector.Distance(pointerPos, MainParticle.Particle.Position) > 0.1)
			pointerForce = Vector.Normalize(pointerPos - MainParticle.Particle.Position) * 1000;

		MainParticle.Particle.Position += pointerForce * dt;

        UpdateParticle(dt, MainParticle);
        foreach(var particle in _particles)
        {
            UpdateParticle(dt, particle);
        }
    }

    void UpdateParticle(float dt, ParticleElement particle)
    {
        var translation = (Translation)particle.Renderer.Transforms[0];
        var p = particle.Particle;

        var acc = p.ForceAccumulator / p.Mass;
        p.Position += p.Velocity * dt + 0.5f * acc * dt * dt;
        p.Velocity += acc * dt;
        p.ForceAccumulator = float2(0);

        translation.X = p.Position.X;
        translation.Y = p.Position.Y;
    }

    public void AddParticle(Particle particle)
    {
        var spring = new Spring(MainParticle.Particle, particle, 40f);
        _springPhysics.AddSpring(spring);
        _particles.Add(CreateParticleElement(particle));

		if (_particles.Count >= 2)
			_springPhysics.AddSpring(new Spring(particle, _particles[_particles.Count - 2].Particle, 80f));
    }

    public ParticleElement CreateParticleElement(Particle particle)
    {
        var particleRenderer = new ParticleRender();
        particleRenderer.Transforms.Add(new Translation());
        _scene.AddGameObject(particleRenderer);

        return new ParticleElement(particle, particleRenderer);
    }

    public void RemoveParticle(Particle particle)
    {
        //_particles.Remove(particle);
    }
}
