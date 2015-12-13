using Uno;
using Uno.Collections;
using Fuse;
using Fuse.Elements;
using Fuse.Controls;

public class SlimeBall : Panel
{
    const float Radius = 30;
    public ParticleElement MainParticle
    {
        get
        {
            return _particles.Count > 0 ? _particles[0] : null;
        }
    }

    readonly List<ParticleElement> _particles = new List<ParticleElement>();
    readonly Scene _scene;
    readonly SpringPhysics _springPhysics;
    readonly List<Spring> _springs = new List<Spring>();
    readonly float4 _color;

    public SlimeBall(
        Scene scene,
        SpringPhysics springPhysics,
        float2 startingPos = float2(0),
        float4 color = float4(1.f, 0.3f, 1.f, 1.f),
        int numStartingParticles = 3)
    {
        _scene = scene;
        _color = color;
        _springPhysics = springPhysics;

        for (var i = 0; i < numStartingParticles; i++)
        {
            var dummyParticle2 = new Particle()
            {
                Radius = Radius
            };

            var x = Math.Lerp(0, 2 * Math.PI, i / 10.0);
            dummyParticle2.Mass = 10.f;
            dummyParticle2.Position.X = (float)Math.Cos(x) * 1.2f * Radius + startingPos.X;
            dummyParticle2.Position.Y = (float)Math.Sin(x) * 1.2f * Radius + startingPos.Y;
            AddParticle(dummyParticle2);
        }

        scene.OnAfterPhysic += OnUpdate;
    }

    public int GetNumParticles()
    {
        return _particles.Count;
    }

    void OnUpdate(float dt)
    {
        for(var i = 1;i < _particles.Count;++i)
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
        if(MainParticle != null)
        {
            var spring = new Spring(MainParticle.Particle, particle, 0.3f * (MainParticle.Particle.Radius + particle.Radius));
            _springPhysics.AddSpring(spring);
            _springs.Add(spring);
        }

        _particles.Add(CreateParticleElement(particle));
    }

    public ParticleElement CreateParticleElement(Particle particle)
    {
        var particleRenderer = new ParticleRender();
        particleRenderer.Transforms.Add(new Translation());
        particleRenderer.Fill = new Fuse.Drawing.StaticSolidColor(_color);
        particleRenderer.Width = particle.Radius;
        _scene.AddGameObject(particleRenderer);

        return new ParticleElement(particle, particleRenderer);
    }

    public virtual void Kill()
    {
        debug_log "I am dead";
        _scene.OnAfterPhysic -= OnUpdate;
    }

    public void RemoveParticle(Particle particle)
    {
        ParticleElement foundParticle = null;
        foreach(var p in _particles)
        {
            if(p.Particle == particle)
            {
                foundParticle = p;
                break;
            }
        }

        if(foundParticle != null)
        {
            _particles.Remove(foundParticle);
            _scene.RemoveGameObject(foundParticle.Renderer);

            Spring foundSpring = null;
            foreach(var spring in _springs)
            {
                if(spring.P2 == particle)
                {
                    foundSpring = spring;
                    break;
                }
            }

            if(foundSpring != null)
                _springs.Remove(foundSpring);

            if(_particles.Count == 0)
                Kill();
        }
    }

    public IEnumerable<Particle> HitTest(SlimeBall slimeBall)
    {
        var particlesHit = new List<Particle>();
        foreach(var pp1 in _particles)
        {
            var p1 = pp1.Particle;
            foreach(var pp2 in slimeBall._particles)
            {
                var p2 = pp2.Particle;

                if(CollisionMethods.CircleWithCircle(p1.Position, p1.Radius, p2.Position, p2.Radius) != null)
                    particlesHit.Add(p2);
            }
        }

        return particlesHit;
    }
}
