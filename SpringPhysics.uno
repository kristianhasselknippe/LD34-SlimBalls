using Uno;
using Uno.Collections;


public interface PhysicsRule
{
	void Step(float dt);
}

public class SpringPhysics
{
	List<Spring> _springs = new List<Spring>();


	public void Step
}

public class Spring : PhysicsRule
{
	Particle _b1;
	Particle _b2;

	public void Step(float dt)
	{

	}

}