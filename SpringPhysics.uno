using Uno;
using Uno.Collections;


public interface PhysicsRule
{
	void Step(float dt);
}

public class SpringPhysics
{
	List<Spring> _springs = new List<Spring>();

	public void AddSpring(Spring s)
	{
		_springs.Add(s);
	}

	public void RemoveSpring(Spring s)
	{
		if (_springs.Contains(s))
			_springs.Remove(s);
	}

	public void Step(float dt)
	{
		foreach (var s in _springs)
		{
			s.Step(dt);
		}
	}

}

public class Spring : PhysicsRule
{

	public float Damping { get; set; }
	public float Coef { get; set; }
	public float Length { get; set; }

	public Particle P1 { get; set; }
	public Particle P2 { get; set; }


	public Spring(Particle p1, Particle p2, float length, float damping = 0.2f, float coef = 0.01f)
	{
		Damping = damping;
		Coef = coef;
		Length = length;
		P1 = p1;
		P2 = p2;
	}

	float GetReducedMass()
	{
		return (P1.Mass * P2.Mass) / (P2.Mass + P2.Mass);
	}

	float2 GetForce(float dt, float reducedMass, float dist, float2 velocity, float2 betweenNormalized)
	{
		if (dt < 0.0005)
			return float2(0);

		var x = betweenNormalized * (dist - Length);
		var f = -((reducedMass / (dt*dt)) * Coef * x) - ((reducedMass/dt) * Damping * velocity);

		return f;
	}

	public void Step(float dt)
	{
		var mass = GetReducedMass();
		float dist = Vector.Distance(P1.Position, P2.Position);
		float2 between = P2.Position - P1.Position;
		if(dist < 0.001)
		{
			return;
		}

		var normalizedBetween = between / dist;
		P1.ForceAccumulator += GetForce(dt, mass, dist, P1.Velocity, -normalizedBetween);
		P2.ForceAccumulator += GetForce(dt, mass, dist, P2.Velocity, normalizedBetween);
	}

}
