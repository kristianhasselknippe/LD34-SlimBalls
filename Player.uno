using Uno;
using Uno.Collections;
using Fuse;

class Particle
{
    public float2 Position;
    public float2 Velocity;
    public float2 ForceAccumulator;

    public float Mass;
    public float Radius;
}

public class Player
{
    readonly Particle MainParticle;
    readonly List<Particle> _particles = new List<Particle>();
    public Player()
    {
        
    }
}
