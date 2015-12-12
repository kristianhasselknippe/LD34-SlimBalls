using Uno;
using Uno.Collections;


public interface PhysicsRule
{
	void Step(float dt);
}

public class SpringPhysics
{
	List<Spring> _springs = new List<Spring>();

}

public class Spring : PhysicsRule
{

	public float Damping { get; set; }
	public float Coef { get; set; }
	public float Length { get; set; }

	Particle P1 { get; set; }
	Particle P2 { get; set; }


	public Spring(Particle b1, Particle b2, float length; float damping = 0.001, float coef = 0.001)
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
		var massRed = GetReducedMass();

		var x = Vector.Length(P1.Position, P2.Position) - Length;

		var f = -((massRed / dt*dt) * Coef) * x - (massRed/dt * Damping);
	}

	public void Step(float dt)
	{
		var f = GetForce();

		P1.Velocity *= dt * f;
		P2.Velocity *= dt * f;
	}

}