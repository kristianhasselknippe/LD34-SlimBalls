using Uno;
using Uno.Collections;
using Fuse;

public class Enemy : SlimeBall
{
    float _moveRadius = 300.f;
    const float Speed = 4000;
    readonly Random _randomGenerator;
    float2 _targetPos;

    public Enemy(
        Scene scene,
        SpringPhysics springPhysics,
        float2 startingPos,
        Random randomGenerator)
        : base(scene, springPhysics, startingPos, float4(0.8f, 0.9f, 0.2f, 1))
    {
        scene.OnAfterPhysic += OnUpdate;
        _randomGenerator = randomGenerator;
    }

    void OnUpdate(float dt)
    {
        if(Vector.Distance(MainParticle.Particle.Position, _targetPos) < 3.)
            _targetPos = CreateTargetPos();

        var toTarget = _targetPos - MainParticle.Particle.Position;
        MainParticle.Particle.Velocity += Vector.Normalize(toTarget) * Speed * dt;
    }

    float2 CreateTargetPos()
    {
        var randAngle = _randomGenerator.NextFloat2() * 2 * (float)Math.PI;
        _moveRadius = _randomGenerator.NextFloat() * 200 + 150;
        return float2(Math.Cos(randAngle.X) * _moveRadius, Math.Sin(randAngle.Y) * _moveRadius);
    }
}
