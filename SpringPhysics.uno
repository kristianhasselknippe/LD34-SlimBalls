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


	public Spring(Particle p1, Particle p2, float length, float damping = 0.0001f, float coef = 0.8f)
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

	float GetForce(float dt)
	{
		if (dt < 0.0005)
			return 0.0f;
		var massRed = GetReducedMass();

		var x = Vector.Distance(P1.Position, P2.Position) - Length;
		var f = -((massRed / dt*dt) * Coef * x) - (massRed/dt * Damping);


		/*debug_log("X: " + x);
		debug_log("MassRed: " + massRed);
		debug_log("DT: " + dt);
		debug_log("F:" + f);*/

		return f;
	}

	public void Step(float dt)
	{
		var f = GetForce(dt);

		var dist = Vector.Distance(P1.Position, P2.Position);
		var dir = float2();
		if (dist > 0.0001)
			dir = Vector.Normalize(P1.Position - P2.Position);

		P1.ForceAccumulator += f * dir;
		P2.ForceAccumulator += f * -dir;

	}

}
