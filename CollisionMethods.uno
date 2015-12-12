using Uno;
using Uno.Collections;
using Fuse;

public class ContactPoint
{
    float2 Point;
    float2 Normal;

    public ContactPoint(float2 point, float2 normal)
    {
        Point = point;
        Normal = normal;
    }
}

public class CollisionMethods
{
    public static ContactPoint CircleWithCircle(float2 aP, float aR, float2 bP, float bR)
    {
        var toCircle = bP - aP;
        if(Vector.Dot(toCircle,toCircle) > aR*bR)
            return null;

        var dist = Vector.Length(toCircle);
        var normal = (toCircle / dist);
        var contactPoint = aP + normal * (dist - bR);

        return new ContactPoint(contactPoint, normal);
    }

    public static ContactPoint CircleWithWall(float2 aP, float aR, float2 wallPos, float2 wallNormal)
    {
        var toCircle = aP - wallPos;
        var D = Vector.Dot(toCircle, wallNormal);
        if(D > aR)
            return null;

        return new ContactPoint(float2(0,0), wallNormal);
    }
}
