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
			dummyParticle2.Position.X = (float)Math.Cos(x) * 80;
			dummyParticle2.Position.Y = (float)Math.Sin(x) * 80;
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
		if (PlayerController.HasPosition && Vector.Distance(pointerPos, MainParticle.Particle.Position) > 0.1)
        {
			pointerForce = Vector.Normalize(pointerPos - MainParticle.Particle.Position) * 10000;
	        MainParticle.Particle.Velocity += pointerForce * dt;
        }

        for(var i = 0;i < _particles.Count;++i)
        {
            for(var j = i+1;j < _particles.Count;++j)
            {
                var p1 = _particles[i].Particle;
                var p2 = _particles[j].Particle;

                var toTarget = p2.Position - p1.Position;
                var dist = Vector.Length(toTarget);
                var delta = dist - 40;
                if(dist > 0.5 && delta < 0.)
                {
                    var norm = toTarget / dist;
                    p1.ForceAccumulator += norm * delta * 200;
                    p2.ForceAccumulator -= norm * delta * 200;
                }
            }
        }

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
        if (Vector.Length(p.Velocity) > 1.f)
            p.Position += p.Velocity * dt;// + 0.5f * acc * dt * dt;
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
