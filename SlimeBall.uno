using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Fuse.Controls;

public class SlimeBall : Panel
{
    public readonly ParticleElement MainParticle;
    readonly List<ParticleElement> _particles = new List<ParticleElement>();
    readonly Scene _scene;
    readonly SpringPhysics _springPhysics;
    readonly float4 _color;

    public SlimeBall(
        Scene scene,
        SpringPhysics springPhysics,
        float2 startingPos = float2(0),
        float4 color = float4(1.f, 0.3f, 1.f, 1.f))
    {
        _scene = scene;
        _color = color;
        _springPhysics = springPhysics;
        MainParticle = CreateParticleElement(new Particle()
        {
            Position = startingPos,
            Mass = 10.f
        });

        for (var i = 0; i < 20; i++)
        {
            var dummyParticle2 = new Particle();
            var x = Math.Lerp(0, 2 * Math.PI, i / 10.0);
            dummyParticle2.Mass = 10.f;
            dummyParticle2.Position.X = (float)Math.Cos(x) * 80 + startingPos.X;
            dummyParticle2.Position.Y = (float)Math.Sin(x) * 80 + startingPos.Y;
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
        particleRenderer.Fill = new Fuse.Drawing.StaticSolidColor(_color);
        _scene.AddGameObject(particleRenderer);

        return new ParticleElement(particle, particleRenderer);
    }

    public void RemoveParticle(Particle particle)
    {
        //_particles.Remove(particle);
    }
}
