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

public class Player
{
    public readonly SlimeBall _slimeBall;
	readonly PlayerController _playerController;
    public Player(Scene scene, SlimeBall slimeBall, PlayerController controller)
    {
        _slimeBall = slimeBall;
		_playerController = controller;
        scene.OnAfterPhysic += OnUpdate;
    }

    void OnUpdate(float dt)
    {
		var pointerPos = _playerController.PointerPosition;
		var pointerForce = float2(0);
		if (_playerController.HasPosition && Vector.Distance(pointerPos, _slimeBall.MainParticle.Particle.Position) > 0.1)
        {
			pointerForce = Vector.Normalize(pointerPos - _slimeBall.MainParticle.Particle.Position) * 10000 * (_slimeBall.GetNumParticles() / 20.f);
	        _slimeBall.MainParticle.Particle.Velocity += pointerForce * dt;
        }
    }

    public void Kill()
    {
        debug_log "Kill me!";
    }

    public void OnHitEnemy(Enemy enemy, Particle particleHit)
    {
        if(enemy.GetNumParticles() > _slimeBall.GetNumParticles())
        {
            Kill();
            return;
        }
        else
        {
            // Steal that shit
            enemy.RemoveParticle(particleHit);
            _slimeBall.AddParticle(particleHit);
        }
    }
}
