using Uno;
using Uno.Collections;
using Fuse;

public class Enemy : SlimeBall
{
    float _moveRadius = 300.f;
    const float Speed = 4000;
    readonly Random _randomGenerator;
    float2 _targetPos;
    readonly Scene _scene;

    public Enemy(
        Scene scene,
        SpringPhysics springPhysics,
        float2 startingPos,
        Random randomGenerator)
        : base(scene, springPhysics, startingPos, float4(0.8f, 0.9f, 0.2f, 1))
    {
        _scene = scene;
        scene.OnAfterPhysic += OnUpdate;
        _randomGenerator = randomGenerator;
    }

    void OnUpdate(float dt)
    {
        if(Vector.Distance(MainParticle.Particle.Position, _targetPos) < 3.)
            _targetPos = CreateTargetPos();

        var toTarget = _targetPos - MainParticle.Particle.Position;
        MainParticle.Particle.Velocity += Vector.Normalize(toTarget) * Speed * (GetNumParticles() / 20.f) * dt;
    }

    public override void Kill()
    {
        base.Kill();
        _scene.OnAfterPhysic -= OnUpdate;
    }

    float2 CreateTargetPos()
    {
        var randAngle = _randomGenerator.NextFloat2() * 2 * (float)Math.PI;
        _moveRadius = _randomGenerator.NextFloat() * 200 + 150;
        return float2(Math.Cos(randAngle.X) * _moveRadius, Math.Sin(randAngle.Y) * _moveRadius);
    }
}
