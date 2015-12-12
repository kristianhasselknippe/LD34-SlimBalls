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

class ParticleElement
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

    readonly SpringPhysics _springPhysics;
    public Player(Scene scene, SpringPhysics springPhysics)
    {
        InitializeUX();
        _scene = scene;
        _springPhysics = springPhysics;

        MainParticle = CreateParticleElement(new Particle() { Mass = 10.f });

        var dummyParticle2 = new Particle();
        dummyParticle2.Mass = 10.f;
        dummyParticle2.Position.X = 400;
        dummyParticle2.Position.Y = 50;
        AddParticle(dummyParticle2);

        scene.OnAfterPhysic += OnUpdate;
    }

    void OnUpdate(float dt)
    {
        foreach(var particle in _particles)
        {
            UpdateParticle(dt, particle);
        }
    }

    void UpdateParticle(float dt, ParticleElement particle)
    {
        var translation = (Translation)particle.Renderer.Transforms[0];
        var p = particle.Particle;

        p.Position += p.Velocity * dt;
        p.Velocity += (p.ForceAccumulator / p.Mass) * dt;
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
