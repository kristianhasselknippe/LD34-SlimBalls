using Uno;
using Uno.Collections;
using Fuse;

public class Enemy : SlimeBall
{
    public Enemy(
        Scene scene,
        SpringPhysics springPhysics,
        float2 startingPos)
        : base(scene, springPhysics, startingPos, float4(0.8f,0.9f, 0.2f, 1))
    {}
}
