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
    readonly Particle MainParticle;
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

    public Player(Scene scene)
    {
        InitializeUX();
        _scene = scene;
        var dummyParticle = new Particle();
        dummyParticle.Position.X = 100;
        AddParticle(dummyParticle);

        var dummyParticle2 = new Particle();
        dummyParticle2.Position.X = 0;
        AddParticle(dummyParticle2);

        Update += OnUpdate;
    }

    void OnUpdate(object sender, EventArgs args)
    {
        foreach(var particle in _particles)
        {
            var translation = (Translation)particle.Renderer.Transforms[0];
            translation.X = particle.Particle.Position.X;
            translation.Y = particle.Particle.Position.Y;
        }
    }

    public void AddParticle(Particle particle)
    {
        var particleRenderer = new ParticleRender();
        particleRenderer.Transforms.Add(new Translation());
        _scene.AddGameObject(particleRenderer);

        _particles.Add(new ParticleElement(particle, particleRenderer));
    }

    public void RemoveParticle(Particle particle)
    {
        //_particles.Remove(particle);
    }
}
